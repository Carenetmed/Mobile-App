import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/auth_api_client.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Notifications/domain/services/notification_session_lifecycle.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth infrastructure boundary', () {
    test('API config trims trailing slash and reports missing config', () {
      const missing = CareNetApiConfig(baseUrl: '');
      const configured = CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080/');

      expect(missing.isConfigured, isFalse);
      expect(missing.normalizedBaseUrl, isNull);
      expect(configured.isConfigured, isTrue);
      expect(configured.normalizedBaseUrl, 'http://127.0.0.1:8080');
    });

    test('client fails closed when backend base URL is missing', () async {
      final client = AuthApiClient(
        config: const CareNetApiConfig(baseUrl: ''),
        dio: Dio(),
      );

      expect(
        () => client.login(email: 'patient@example.com', password: 'secret123'),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.type,
            'type',
            AuthFailureType.missingConfiguration,
          ),
        ),
      );
    });

    test(
      'protected calls send bearer auth only and never cookie auth',
      () async {
        final adapter = _FakeAdapter(
          responseJson: <String, dynamic>{
            'id': 'user-1',
            'email': 'patient@example.com',
            'role': 'PATIENT',
            'status': 'ACTIVE',
            'emailVerified': false,
          },
        );
        final dio = Dio()..httpClientAdapter = adapter;
        final client = AuthApiClient(
          config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
          dio: dio,
        );

        await client.me(accessToken: 'access-token');

        expect(adapter.lastOptions?.uri.toString(), endsWith('/auth/me'));
        expect(
          adapter.lastOptions?.headers['Authorization'],
          'Bearer access-token',
        );
        expect(adapter.lastOptions?.headers.containsKey('Cookie'), isFalse);
      },
    );

    test('session store saves, reads, and clears session state', () async {
      final store = InMemorySessionStore();
      final session = _session(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
      );

      await store.save(session);
      expect((await store.read())?.refreshToken, 'refresh-1');

      await store.clear();
      expect(await store.read(), isNull);
    });

    test('repository stores rotated tokens after refresh', () async {
      final store = InMemorySessionStore();
      await store.save(
        _session(accessToken: 'old-access', refreshToken: 'old-refresh'),
      );
      final adapter = _FakeAdapter(
        responseJson: _sessionJson(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        ),
      );
      final repository = AuthRepository(
        apiClient: AuthApiClient(
          config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
          dio: Dio()..httpClientAdapter = adapter,
        ),
        sessionStore: store,
      );

      await repository.refresh();

      final stored = await store.read();
      expect(stored?.accessToken, 'new-access');
      expect(stored?.refreshToken, 'new-refresh');
      expect(adapter.lastOptions?.data, <String, dynamic>{
        'refreshToken': 'old-refresh',
      });
    });

    test('concurrent refresh calls share one token rotation', () async {
      final store = InMemorySessionStore();
      await store.save(
        _session(accessToken: 'old-access', refreshToken: 'old-refresh'),
      );
      final response = Completer<ResponseBody>();
      final adapter = _FakeAdapter(
        responseJson: const <String, dynamic>{},
        responseCompleter: response,
      );
      final repository = AuthRepository(
        apiClient: AuthApiClient(
          config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
          dio: Dio()..httpClientAdapter = adapter,
        ),
        sessionStore: store,
      );

      final first = repository.refresh();
      final second = repository.refresh();
      for (
        var attempt = 0;
        attempt < 10 && adapter.fetchCalls == 0;
        attempt++
      ) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(adapter.fetchCalls, 1);
      response.complete(
        ResponseBody.fromString(
          jsonEncode(
            _sessionJson(
              accessToken: 'new-access',
              refreshToken: 'new-refresh',
            ),
          ),
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        ),
      );

      final sessions = await Future.wait([first, second]);
      expect(sessions.map((session) => session.accessToken), <String>[
        'new-access',
        'new-access',
      ]);
      expect(adapter.fetchCalls, 1);
    });

    test('late refresh cannot restore a cleared session', () async {
      final store = InMemorySessionStore();
      await store.save(_session(accessToken: 'old', refreshToken: 'old-key'));
      final response = Completer<ResponseBody>();
      final adapter = _FakeAdapter(
        responseJson: const <String, dynamic>{},
        responseCompleter: response,
      );
      final repository = AuthRepository(
        apiClient: AuthApiClient(
          config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
          dio: Dio()..httpClientAdapter = adapter,
        ),
        sessionStore: store,
      );

      final refresh = repository.refresh();
      while (adapter.fetchCalls == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      await store.clear();
      response.complete(
        _responseBody(
          _sessionJson(accessToken: 'late', refreshToken: 'rotated'),
        ),
      );

      await expectLater(refresh, throwsA(isA<AuthFailure>()));
      expect(await store.read(), isNull);
    });

    test('late rejected refresh cannot clear a replacement account', () async {
      final store = InMemorySessionStore();
      await store.save(_session(accessToken: 'old', refreshToken: 'old-key'));
      final response = Completer<ResponseBody>();
      final adapter = _FakeAdapter(
        responseJson: const <String, dynamic>{},
        responseCompleter: response,
      );
      final repository = AuthRepository(
        apiClient: AuthApiClient(
          config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
          dio: Dio()..httpClientAdapter = adapter,
        ),
        sessionStore: store,
      );

      final refresh = repository.refresh();
      while (adapter.fetchCalls == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      final replacement = AuthSessionModel.fromJson({
        ..._sessionJson(accessToken: 'new', refreshToken: 'new-key'),
        'user': {
          ..._sessionJson(accessToken: 'new', refreshToken: 'new-key')['user']
              as Map<String, dynamic>,
          'id': 'user-2',
        },
      });
      await store.save(replacement);
      response.complete(
        _responseBody(<String, dynamic>{'message': 'Unauthorized'}, 401),
      );

      await expectLater(refresh, throwsA(isA<AuthFailure>()));
      expect((await store.read())?.user.id, 'user-2');
    });

    test(
      'account repository clears session on unauthorized current account',
      () async {
        final store = InMemorySessionStore();
        await store.save(
          _session(accessToken: 'expired', refreshToken: 'refresh'),
        );
        final repository = AccountRepository(
          apiClient: AuthApiClient(
            config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
            dio:
                Dio()
                  ..httpClientAdapter = _FakeAdapter(
                    statusCode: 401,
                    responseJson: <String, dynamic>{'message': 'Unauthorized'},
                  ),
          ),
          sessionStore: store,
        );

        await expectLater(
          repository.currentAccount(),
          throwsA(
            isA<AuthFailure>().having(
              (failure) => failure.type,
              'type',
              AuthFailureType.unauthorized,
            ),
          ),
        );
        expect(await store.read(), isNull);
      },
    );

    test(
      'password reset confirm sends newPassword and clears session',
      () async {
        final store = InMemorySessionStore();
        await store.save(
          _session(
            accessToken: 'stored-access',
            refreshToken: 'stored-refresh',
          ),
        );
        final adapter = _FakeAdapter(responseJson: <String, dynamic>{});
        final repository = AuthRepository(
          apiClient: AuthApiClient(
            config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
            dio: Dio()..httpClientAdapter = adapter,
          ),
          sessionStore: store,
        );

        await repository.confirmPasswordReset(
          token: 'opaque-reset-token',
          password: 'CareNet@123',
        );

        expect(
          adapter.lastOptions?.uri.toString(),
          endsWith('/auth/password-reset/confirm'),
        );
        expect(adapter.lastOptions?.data, <String, dynamic>{
          'token': 'opaque-reset-token',
          'newPassword': 'CareNet@123',
        });
        expect(await store.read(), isNull);
      },
    );

    test(
      'account deletion sends reauthentication and clears session',
      () async {
        final store = InMemorySessionStore();
        await store.save(
          _session(
            accessToken: 'account-access',
            refreshToken: 'account-refresh',
          ),
        );
        final adapter = _FakeAdapter(
          responseJson: <String, dynamic>{
            'accountStatus': 'DELETED',
            'deletionRequestedAt': '2026-09-26T12:00:00.000Z',
            'retentionStatus': 'RETAINED_UNDER_POLICY',
            'sessionsRevoked': true,
          },
        );
        final lifecycle = _AccountDeletionLifecycle();
        final repository = AccountRepository(
          apiClient: AuthApiClient(
            config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
            dio: Dio()..httpClientAdapter = adapter,
          ),
          sessionStore: store,
          notificationLifecycle: lifecycle,
        );

        final receipt = await repository.requestAccountDeletion(
          password: 'CareNet@123',
        );

        expect(
          adapter.lastOptions?.uri.toString(),
          endsWith('/auth/account-deletion/request'),
        );
        expect(
          adapter.lastOptions?.headers['Authorization'],
          'Bearer account-access',
        );
        expect(adapter.lastOptions?.data, <String, dynamic>{
          'password': 'CareNet@123',
          'confirmation': 'DELETE',
        });
        expect(receipt.isValid, isTrue);
        expect(await store.read(), isNull);
        expect(lifecycle.afterDeletionCalls, 1);
        expect(lifecycle.beforeLogoutCalls, 0);
      },
    );
  });
}

class _AccountDeletionLifecycle implements NotificationSessionLifecycle {
  int beforeLogoutCalls = 0;
  int afterDeletionCalls = 0;

  @override
  Future<void> afterAccountDeletion(AuthSessionModel session) async {
    afterDeletionCalls += 1;
  }

  @override
  Future<void> beforeLogout(AuthSessionModel session) async {
    beforeLogoutCalls += 1;
  }

  @override
  Future<void> onAuthenticatedSession(AuthSessionModel session) async {}
}

AuthSessionModel _session({
  required String accessToken,
  required String refreshToken,
}) {
  return AuthSessionModel.fromJson(
    _sessionJson(accessToken: accessToken, refreshToken: refreshToken),
  );
}

Map<String, dynamic> _sessionJson({
  required String accessToken,
  required String refreshToken,
}) {
  return <String, dynamic>{
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': 'Bearer',
    'expiresIn': 900,
    'user': <String, dynamic>{
      'id': 'user-1',
      'email': 'patient@example.com',
      'role': 'PATIENT',
      'status': 'ACTIVE',
      'emailVerified': false,
    },
  };
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({
    required this.responseJson,
    this.statusCode = 200,
    this.responseCompleter,
  });

  final Map<String, dynamic> responseJson;
  final int statusCode;
  final Completer<ResponseBody>? responseCompleter;
  RequestOptions? lastOptions;
  int fetchCalls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCalls += 1;
    lastOptions = options;
    final completer = responseCompleter;
    if (completer != null) {
      return completer.future;
    }
    final body = jsonEncode(responseJson);
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}

ResponseBody _responseBody(Map<String, dynamic> body, [int status = 200]) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
