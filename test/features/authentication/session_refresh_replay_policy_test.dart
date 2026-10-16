import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/network/carenet_http_client.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/services/auth_api_client.dart';
import 'package:app_t/features/Authentication/data/services/session_refresh_coordinator.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GET is refreshed and replayed once', () async {
    final harness = await _ReplayHarness.create();

    final response = await harness.dio.get<dynamic>(
      'https://api.example.test/patients/me',
      options: _authenticatedOptions('GET'),
    );

    expect(response.statusCode, 200);
    expect(harness.adapter.refreshCalls, 1);
    expect(harness.adapter.protectedRequests, hasLength(2));
  });

  test('concurrent GET 401 responses share one blocked refresh', () async {
    final harness = await _ReplayHarness.create();
    final gate = Completer<void>();
    harness.adapter.refreshGate = gate;
    addTearDown(() {
      if (!gate.isCompleted) gate.complete();
    });
    final first = harness.dio.get<dynamic>(
      'https://api.example.test/patients/first',
      options: _authenticatedOptions('GET'),
    );
    final second = harness.dio.get<dynamic>(
      'https://api.example.test/patients/second',
      options: _authenticatedOptions('GET'),
    );
    await harness.adapter.refreshStarted.future.timeout(
      const Duration(seconds: 2),
    );
    await harness.adapter.initialPairSeen.future.timeout(
      const Duration(seconds: 2),
    );
    expect(harness.adapter.refreshCalls, 1);
    gate.complete();
    final responses = await Future.wait([first, second]);
    expect(responses.map((response) => response.statusCode), everyElement(200));
    expect(harness.adapter.refreshCalls, 1);
    expect(harness.adapter.protectedRequests, hasLength(4));
    for (final path in ['/patients/first', '/patients/second']) {
      expect(
        harness.adapter.protectedRequests.where((r) => r.path == path),
        hasLength(2),
      );
    }
  });

  test(
    'cancelling one shared-refresh caller never replays its transport',
    () async {
      final harness = await _ReplayHarness.create();
      final gate = Completer<void>();
      harness.adapter.refreshGate = gate;
      addTearDown(() {
        if (!gate.isCompleted) gate.complete();
      });
      final cancel = CancelToken();
      final cancelled = harness.dio.get<dynamic>(
        'https://api.example.test/patients/first',
        options: _authenticatedOptions('GET'),
        cancelToken: cancel,
      );
      final cancellation = expectLater(
        cancelled,
        throwsA(
          isA<DioException>().having(
            (error) => error.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );
      final remaining = harness.dio.get<dynamic>(
        'https://api.example.test/patients/second',
        options: _authenticatedOptions('GET'),
      );
      await harness.adapter.refreshStarted.future.timeout(
        const Duration(seconds: 2),
      );
      await harness.adapter.initialPairSeen.future.timeout(
        const Duration(seconds: 2),
      );
      cancel.cancel('Test cancellation');
      await cancellation;
      gate.complete();
      expect((await remaining).statusCode, 200);
      expect(harness.adapter.refreshCalls, 1);
      expect(harness.adapter.protectedRequests, hasLength(3));
      expect(
        harness.adapter.protectedRequests.where(
          (r) => r.path == '/patients/first',
        ),
        hasLength(1),
      );
      expect(
        harness.adapter.protectedRequests.where(
          (r) => r.path == '/patients/second',
        ),
        hasLength(2),
      );
    },
  );

  test(
    '401 from a prior login is not replayed after same-account relogin',
    () async {
      final harness = await _ReplayHarness.create();
      harness.adapter.beforeProtectedResponse =
          () => harness.store.save(
            _session('new-login-access', 'new-login-refresh'),
          );

      await expectLater(
        harness.dio.get<dynamic>(
          'https://api.example.test/patients/me',
          options: _authenticatedOptions('GET'),
        ),
        throwsA(isA<DioException>()),
      );

      expect(harness.adapter.refreshCalls, 0);
      expect(harness.adapter.protectedRequests, hasLength(1));
      expect((await harness.store.read())?.accessToken, 'new-login-access');
    },
  );

  test('POST without an idempotency key is not replayed', () async {
    final harness = await _ReplayHarness.create();

    await expectLater(
      harness.dio.post<dynamic>(
        'https://api.example.test/appointments',
        data: <String, Object>{'value': 'same'},
        options: _authenticatedOptions('POST'),
      ),
      throwsA(isA<DioException>()),
    );

    expect(harness.adapter.refreshCalls, 0);
    expect(harness.adapter.protectedRequests, hasLength(1));
  });

  test(
    'idempotency header alone does not opt a mutation into replay',
    () async {
      final harness = await _ReplayHarness.create();

      await expectLater(
        harness.dio.post<dynamic>(
          'https://api.example.test/unverified-mutation',
          data: <String, Object>{'value': 'same'},
          options: _authenticatedOptions(
            'POST',
            headers: const <String, String>{'Idempotency-Key': 'opaque-key'},
          ),
        ),
        throwsA(isA<DioException>()),
      );

      expect(harness.adapter.refreshCalls, 0);
      expect(harness.adapter.protectedRequests, hasLength(1));
    },
  );

  test('keyed replayable POST preserves key and body on one retry', () async {
    final harness = await _ReplayHarness.create();
    const key = 'booking-attempt-8c27';
    final body = <String, Object>{
      'professionalProfileId': 'professional-42',
      'requestedStartAt': '2026-10-08T10:00:00.000Z',
      'durationMinutes': 30,
    };

    final response = await harness.dio.post<dynamic>(
      'https://api.example.test/appointments',
      data: body,
      options: _authenticatedOptions(
        'POST',
        headers: const <String, String>{'Idempotency-Key': key},
        replaySafe: true,
      ),
    );

    expect(response.statusCode, 200);
    expect(harness.adapter.refreshCalls, 1);
    expect(harness.adapter.protectedRequests, hasLength(2));
    expect(
      harness.adapter.protectedRequests.map((request) => request.method),
      everyElement('POST'),
    );
    expect(
      harness.adapter.protectedRequests.map((request) => request.key),
      everyElement(key),
    );
    expect(
      harness.adapter.protectedRequests.map((request) => request.body),
      everyElement(body),
    );
  });

  test(
    'a replayed request that also returns 401 reaches the one-retry ceiling',
    () async {
      final harness = await _ReplayHarness.create(retryStatusCode: 401);

      await expectLater(
        harness.dio.get<dynamic>(
          'https://api.example.test/patients/me',
          options: _authenticatedOptions('GET'),
        ),
        throwsA(isA<DioException>()),
      );

      expect(harness.adapter.refreshCalls, 1);
      expect(harness.adapter.protectedRequests, hasLength(2));
    },
  );

  test('keyed stream body is not replayed', () async {
    final harness = await _ReplayHarness.create();
    final stream = Stream<List<int>>.value(<int>[1, 2, 3]);

    await expectLater(
      harness.dio.post<dynamic>(
        'https://api.example.test/upload',
        data: stream,
        options: _authenticatedOptions(
          'POST',
          headers: const <String, String>{
            'Idempotency-Key': 'stream-attempt-1',
          },
          replaySafe: true,
        ),
      ),
      throwsA(isA<DioException>()),
    );

    expect(harness.adapter.refreshCalls, 0);
    expect(harness.adapter.protectedRequests, hasLength(1));
  });

  test('keyed FormData body is not replayed', () async {
    final harness = await _ReplayHarness.create();
    final form = FormData.fromMap(<String, Object>{'name': 'report'});

    await expectLater(
      harness.dio.post<dynamic>(
        'https://api.example.test/upload',
        data: form,
        options: _authenticatedOptions(
          'POST',
          headers: const <String, String>{'Idempotency-Key': 'form-attempt-1'},
          replaySafe: true,
        ),
      ),
      throwsA(isA<DioException>()),
    );

    expect(harness.adapter.refreshCalls, 0);
    expect(harness.adapter.protectedRequests, hasLength(1));
  });
}

Options _authenticatedOptions(
  String method, {
  Map<String, String> headers = const <String, String>{},
  bool replaySafe = false,
}) => Options(
  method: method,
  extra: <String, dynamic>{
    SessionRefreshInterceptor.replaySafeExtraKey: replaySafe,
  },
  headers: <String, String>{
    'Authorization': 'Bearer expired-access',
    ...headers,
  },
);

String? _idempotencyKey(RequestOptions request) {
  for (final entry in request.headers.entries) {
    if (entry.key.toLowerCase() == 'idempotency-key') {
      return entry.value as String?;
    }
  }
  return null;
}

class _ReplayHarness {
  _ReplayHarness(this.dio, this.adapter, this.store);

  final Dio dio;
  final _ReplayAdapter adapter;
  final InMemorySessionStore store;

  static Future<_ReplayHarness> create({int retryStatusCode = 200}) async {
    final store = InMemorySessionStore();
    await store.save(_session('expired-access', 'refresh-token'));
    final dio = CareNetHttpClient.create();
    final adapter = _ReplayAdapter(retryStatusCode: retryStatusCode);
    dio.httpClientAdapter = adapter;
    final api = AuthApiClient(
      config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
      dio: dio,
    );
    final coordinator = SessionRefreshCoordinator(
      apiClient: api,
      sessionStore: store,
    );
    dio.interceptors.add(
      SessionRefreshInterceptor(dio: dio, coordinator: coordinator),
    );
    addTearDown(() => dio.close(force: true));
    return _ReplayHarness(dio, adapter, store);
  }
}

class _ReplayAdapter implements HttpClientAdapter {
  _ReplayAdapter({required this.retryStatusCode});

  final int retryStatusCode;
  int refreshCalls = 0;
  Completer<void>? refreshGate;
  final refreshStarted = Completer<void>();
  final initialPairSeen = Completer<void>();
  final List<_RecordedRequest> protectedRequests = <_RecordedRequest>[];
  Future<void> Function()? beforeProtectedResponse;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path == '/auth/refresh') {
      refreshCalls++;
      if (!refreshStarted.isCompleted) refreshStarted.complete();
      await refreshGate?.future;
      return _json(_session('rotated-access', 'rotated-refresh').toJson(), 200);
    }

    protectedRequests.add(
      _RecordedRequest(
        path: options.uri.path,
        method: options.method,
        key: _idempotencyKey(options),
        body:
            options.data is Map || options.data is List
                ? jsonDecode(jsonEncode(options.data))
                : options.data,
      ),
    );
    if (protectedRequests.length >= 2 && !initialPairSeen.isCompleted) {
      initialPairSeen.complete();
    }
    final beforeResponse = beforeProtectedResponse;
    beforeProtectedResponse = null;
    await beforeResponse?.call();
    final isRetry = options.headers['Authorization'] == 'Bearer rotated-access';
    final status = isRetry ? retryStatusCode : 401;
    return _json(<String, Object>{'ok': true}, status);
  }

  ResponseBody _json(Map<String, dynamic> value, int status) =>
      ResponseBody.fromString(
        jsonEncode(value),
        status,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        },
      );
}

class _RecordedRequest {
  const _RecordedRequest({
    required this.path,
    required this.method,
    required this.key,
    this.body,
  });

  final String path;
  final String method;
  final String? key;
  final Object? body;
}

AuthSessionModel _session(String accessToken, String refreshToken) =>
    AuthSessionModel.fromJson(<String, dynamic>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'user': <String, dynamic>{
        'id': 'patient-1',
        'email': 'patient@example.test',
        'role': 'PATIENT',
        'status': 'ACTIVE',
        'emailVerified': true,
      },
    });
