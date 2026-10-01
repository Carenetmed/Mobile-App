import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/network/carenet_http_client.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/data/services/auth_api_client.dart';
import 'package:app_t/features/Authentication/data/services/session_refresh_coordinator.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'new account refresh does not inherit the previous account rejection',
    () async {
      final oldRefreshStarted = Completer<void>();
      final oldRefreshResponse = Completer<ResponseBody>();
      final newProtectedStarted = Completer<void>();
      var refreshCalls = 0;
      final harness = await _harness((options) async {
        if (options.uri.path == '/auth/refresh') {
          refreshCalls++;
          if ((options.data as Map)['refreshToken'] == 'first-refresh') {
            oldRefreshStarted.complete();
            return oldRefreshResponse.future;
          }
          return _json(_session('second', rotated: true).toJson(), 200);
        }
        if (options.headers['Authorization'] ==
            'Bearer second-rotated-access') {
          return _json(
            _session('second').toJson()['user'] as Map<String, dynamic>,
            200,
          );
        }
        if (options.headers['Authorization'] == 'Bearer second-access') {
          newProtectedStarted.complete();
        }
        return _json({}, 401);
      });
      final oldRejected = expectLater(
        harness.coordinator.refresh(),
        throwsA(isA<AuthFailure>()),
      );
      await oldRefreshStarted.future;
      await harness.store.save(_session('second'));
      final currentRequest = harness.account.currentAccount();
      final currentSuccess = expectLater(
        currentRequest,
        completion(isA<Object>()),
      );
      await newProtectedStarted.future;
      await Future<void>.delayed(Duration.zero);
      oldRefreshResponse.complete(_json({}, 401));
      await oldRejected;
      await currentSuccess;
      expect((await currentRequest).id, 'second');
      expect(
        (await harness.store.read())?.accessToken,
        'second-rotated-access',
      );
      expect(refreshCalls, 2);
    },
  );
  test(
    'network failure on the retried request preserves rotated session',
    () async {
      final harness = await _harness((options) async {
        if (options.uri.path == '/auth/refresh') {
          return _json(_session('first', rotated: true).toJson(), 200);
        }
        if (options.headers['Authorization'] == 'Bearer first-rotated-access') {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }
        return _json({}, 401);
      });
      await expectLater(
        harness.account.currentAccount(),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.type,
            'type',
            AuthFailureType.network,
          ),
        ),
      );
      expect((await harness.store.read())?.accessToken, 'first-rotated-access');
    },
  );
  for (final serverFailure in [false, true]) {
    test(
      '${serverFailure ? 'server' : 'network'} refresh failure preserves session and classification',
      () async {
        var refreshCalls = 0;
        final harness = await _harness((options) async {
          if (options.uri.path == '/auth/refresh') {
            refreshCalls++;
            if (serverFailure) return _json({}, 503);
            throw DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            );
          }
          return _json({}, 401);
        });
        await expectLater(
          harness.account.currentAccount(),
          throwsA(
            isA<AuthFailure>().having(
              (failure) => failure.type,
              'type',
              serverFailure ? AuthFailureType.server : AuthFailureType.network,
            ),
          ),
        );
        expect((await harness.store.read())?.user.id, 'first');
        expect(refreshCalls, 1);
      },
    );
  }

  test(
    'protected 403 is permission denial without token refresh or sign-out',
    () async {
      var refreshCalls = 0;
      final harness = await _harness((options) async {
        if (options.uri.path == '/auth/refresh') refreshCalls++;
        return _json({}, 403);
      });
      await expectLater(
        harness.account.currentAccount(),
        throwsA(
          isA<AuthFailure>()
              .having(
                (failure) => failure.type,
                'type',
                AuthFailureType.forbidden,
              )
              .having(
                (failure) => failure.message,
                'message',
                isNot(contains('sign in')),
              ),
        ),
      );
      expect(refreshCalls, 0);
      expect((await harness.store.read())?.user.id, 'first');
    },
  );

  for (final status in [200, 401]) {
    test('late $status response cannot cross an account switch', () async {
      final started = Completer<void>();
      final response = Completer<ResponseBody>();
      var refreshCalls = 0;
      var protectedCalls = 0;
      final harness = await _harness((options) async {
        if (options.uri.path == '/auth/refresh') {
          refreshCalls++;
          return _json(_session('second').toJson(), 200);
        }
        protectedCalls++;
        started.complete();
        return response.future;
      });
      final rejected = expectLater(
        harness.account.currentAccount(),
        throwsA(isA<AuthFailure>()),
      );
      await started.future;
      await harness.store.save(_session('second'));
      response.complete(
        _json(
          _session('first').toJson()['user'] as Map<String, dynamic>,
          status,
        ),
      );
      await rejected;
      expect(refreshCalls, 0);
      expect(protectedCalls, 1);
      expect((await harness.store.read())?.user.id, 'second');
    });
  }

  test('late 401 reuses an already rotated same-account token', () async {
    final started = Completer<void>();
    final response = Completer<ResponseBody>();
    var refreshCalls = 0;
    var protectedCalls = 0;
    final harness = await _harness((options) async {
      if (options.uri.path == '/auth/refresh') {
        refreshCalls++;
        return _json(_session('first', rotated: true).toJson(), 200);
      }
      protectedCalls++;
      if (options.headers['Authorization'] == 'Bearer first-rotated-access') {
        return _json(
          _session('first').toJson()['user'] as Map<String, dynamic>,
          200,
        );
      }
      started.complete();
      return response.future;
    });
    final request = harness.account.currentAccount();
    await started.future;
    await harness.store.save(_session('first', rotated: true));
    response.complete(_json({}, 401));
    expect((await request).id, 'first');
    expect(refreshCalls, 0);
    expect(protectedCalls, 2);
  });

  test('authoritative refresh rejection clears its current session', () async {
    final harness = await _harness((options) async => _json({}, 403));
    await expectLater(
      harness.coordinator.refresh(),
      throwsA(
        isA<AuthFailure>().having(
          (failure) => failure.type,
          'type',
          AuthFailureType.unauthorized,
        ),
      ),
    );
    expect(await harness.store.read(), isNull);
  });
}

Future<_Harness> _harness(
  Future<ResponseBody> Function(RequestOptions) route,
) async {
  final store = InMemorySessionStore();
  await store.save(_session('first'));
  final dio = CareNetHttpClient.create()..httpClientAdapter = _Adapter(route);
  addTearDown(() => dio.close(force: true));
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
  return _Harness(
    store,
    coordinator,
    AccountRepository(apiClient: api, sessionStore: store),
  );
}

class _Harness {
  const _Harness(this.store, this.coordinator, this.account);
  final InMemorySessionStore store;
  final SessionRefreshCoordinator coordinator;
  final AccountRepository account;
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.route);
  final Future<ResponseBody> Function(RequestOptions) route;
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => route(options);
}

ResponseBody _json(Map<String, dynamic> value, int status) =>
    ResponseBody.fromString(
      jsonEncode(value),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

AuthSessionModel _session(String id, {bool rotated = false}) =>
    AuthSessionModel.fromJson({
      'accessToken': '$id-${rotated ? 'rotated-' : ''}access',
      'refreshToken': '$id-${rotated ? 'rotated-' : ''}refresh',
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'user': {
        'id': id,
        'email': '$id@example.test',
        'role': 'PATIENT',
        'status': 'ACTIVE',
        'emailVerified': true,
      },
    });
