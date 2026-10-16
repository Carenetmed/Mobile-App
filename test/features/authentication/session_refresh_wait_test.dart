import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/network/carenet_http_client.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/services/auth_api_client.dart';
import 'package:app_t/features/Authentication/data/services/session_refresh_coordinator.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher get _safeWaitFailure => isA<AuthFailure>()
    .having((e) => e.type, 'type', AuthFailureType.network)
    .having((e) => e.statusCode, 'statusCode', isNull)
    .having((e) => e.shouldClearSession, 'clears session', false)
    .having(
      (e) => e.message,
      'message',
      'Could not finish refreshing your session. Please try again.',
    );

void main() {
  test('refresh rejects nonpositive caller budgets', () {
    for (final timeout in [Duration.zero, const Duration(milliseconds: -1)]) {
      expect(
        () => SessionRefreshCoordinator(
          apiClient: _Api(),
          sessionStore: InMemorySessionStore(),
          callerTimeout: timeout,
        ),
        throwsArgumentError,
      );
    }
  });

  testWidgets('default refresh caller deadline is sixty seconds', (
    tester,
  ) async {
    final api = _Api()..gate = Completer<AuthSessionModel>();
    final store = InMemorySessionStore();
    await store.save(_session('old'));
    final coordinator = SessionRefreshCoordinator(
      apiClient: api,
      sessionStore: store,
    );
    var finished = false;
    final outcome = expectLater(
      coordinator.refresh().whenComplete(() => finished = true),
      throwsA(_safeWaitFailure),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 59));
    expect(finished, false);
    await tester.pump(const Duration(seconds: 1));
    await outcome;
    expect(api.calls, 1);
    expect((await store.read())?.accessToken, 'old-access');
    api.gate!.complete(_session('rotated'));
    await tester.pump();
    expect((await store.read())?.accessToken, 'rotated-access');
  });

  test(
    'timed-out callers retain one refresh while persistence is unresolved',
    () async {
      final store = _BlockedReplacementStore();
      await store.save(_session('old'));
      final api = _Api();
      final coordinator = SessionRefreshCoordinator(
        apiClient: api,
        sessionStore: store,
        callerTimeout: const Duration(milliseconds: 25),
      );
      final first = expectLater(
        coordinator.refresh(),
        throwsA(_safeWaitFailure),
      );
      await store.started.future.timeout(const Duration(seconds: 2));
      await first;
      await expectLater(coordinator.refresh(), throwsA(_safeWaitFailure));
      expect(api.calls, 1);
      expect(store.replacements, 1);
      expect((await store.read())?.accessToken, 'old-access');
      store.release.complete();
      await store.finished.future.timeout(const Duration(seconds: 2));
      expect(
        (await coordinator.requireSession()).accessToken,
        'rotated-access',
      );
      expect(api.calls, 1);
    },
  );

  test(
    'late refresh persistence cannot replace or clear a newer account',
    () async {
      final store = _BlockedReplacementStore();
      await store.save(_session('old'));
      final api = _Api();
      final coordinator = SessionRefreshCoordinator(
        apiClient: api,
        sessionStore: store,
        callerTimeout: const Duration(milliseconds: 25),
      );
      var notifications = 0;
      coordinator.onAuthenticated = (_) async {
        notifications++;
      };
      final outcome = expectLater(
        coordinator.refresh(),
        throwsA(_safeWaitFailure),
      );
      await store.started.future.timeout(const Duration(seconds: 2));
      await outcome;
      await store.save(_session('new', user: 'patient-new'));
      final newer = await store.capture();
      store.release.complete();
      await store.finished.future.timeout(const Duration(seconds: 2));
      await Future<void>.delayed(Duration.zero);
      expect((await store.capture())?.generation, newer!.generation);
      expect((await store.read())?.user.id, 'patient-new');
      expect(notifications, 0);
      expect(api.calls, 1);
    },
  );

  test(
    'late backend rejection is observed without erasing a newer login',
    () async {
      final api = _Api()..gate = Completer<AuthSessionModel>();
      final store = InMemorySessionStore();
      await store.save(_session('old'));
      final coordinator = SessionRefreshCoordinator(
        apiClient: api,
        sessionStore: store,
        callerTimeout: const Duration(milliseconds: 25),
      );
      await expectLater(coordinator.refresh(), throwsA(_safeWaitFailure));
      await store.save(_session('new', user: 'patient-new'));
      api.gate!.completeError(
        const AuthFailure(
          type: AuthFailureType.unauthorized,
          message: 'Rejected',
          statusCode: 401,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect((await store.read())?.user.id, 'patient-new');
      expect(api.calls, 1);
    },
  );

  test(
    'interceptor returns a safe error without replay after refresh wait timeout',
    () async {
      final store = _BlockedReplacementStore();
      await store.save(_session('old'));
      final api = _Api();
      final coordinator = SessionRefreshCoordinator(
        apiClient: api,
        sessionStore: store,
        callerTimeout: const Duration(milliseconds: 25),
      );
      final dio = CareNetHttpClient.create();
      final adapter = _ProtectedAdapter();
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        SessionRefreshInterceptor(dio: dio, coordinator: coordinator),
      );
      addTearDown(() => dio.close(force: true));
      await expectLater(
        dio.get<dynamic>(
          'https://api.example.test/patients/me',
          options: Options(headers: {'Authorization': 'Bearer old-access'}),
        ),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'safe error',
            _safeWaitFailure,
          ),
        ),
      );
      expect(adapter.calls, 1);
      expect(api.calls, 1);
      store.release.complete();
      await store.finished.future.timeout(const Duration(seconds: 2));
      await Future<void>.delayed(Duration.zero);
      expect(adapter.calls, 1);
    },
  );
}

class _Api extends AuthApiClient {
  _Api()
    : super(
        config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
      );
  int calls = 0;
  Completer<AuthSessionModel>? gate;
  @override
  Future<AuthSessionModel> refresh({required String refreshToken}) async {
    calls++;
    return gate?.future ?? _session('rotated');
  }
}

class _BlockedReplacementStore extends InMemorySessionStore {
  final started = Completer<void>();
  final release = Completer<void>();
  final finished = Completer<void>();
  int replacements = 0;
  @override
  Future<bool> replaceSnapshotIfCurrent(
    SessionSnapshot expected,
    AuthSessionModel replacement,
  ) async {
    replacements++;
    if (!started.isCompleted) started.complete();
    await release.future;
    try {
      return await super.replaceSnapshotIfCurrent(expected, replacement);
    } finally {
      if (!finished.isCompleted) finished.complete();
    }
  }
}

class _ProtectedAdapter implements HttpClientAdapter {
  int calls = 0;
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(
      jsonEncode({'error': 'expired'}),
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

AuthSessionModel _session(String prefix, {String user = 'patient-old'}) =>
    AuthSessionModel.fromJson({
      'accessToken': '$prefix-access',
      'refreshToken': '$prefix-refresh',
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'user': {
        'id': user,
        'email': '$user@example.test',
        'role': 'PATIENT',
        'status': 'ACTIVE',
        'emailVerified': true,
      },
    });
