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
  });
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
  _FakeAdapter({required this.responseJson, this.statusCode = 200});

  final Map<String, dynamic> responseJson;
  final int statusCode;
  RequestOptions? lastOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
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
