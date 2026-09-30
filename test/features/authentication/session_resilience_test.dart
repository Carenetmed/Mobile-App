import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/network/carenet_http_client.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/services/auth_api_client.dart';
import 'package:app_t/features/Authentication/data/services/session_refresh_coordinator.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test('shared HTTP client applies bounded transport timeouts', () {
    final dio = CareNetHttpClient.create();

    expect(dio.options.connectTimeout, CareNetHttpClient.connectTimeout);
    expect(dio.options.sendTimeout, CareNetHttpClient.sendTimeout);
    expect(dio.options.receiveTimeout, CareNetHttpClient.receiveTimeout);
  });

  test(
    'secure session persists one versioned record and restores it',
    () async {
      const storage = FlutterSecureStorage();
      final store = SecureSessionStore(storage: storage);
      final session = _session('access-1', 'refresh-1');

      await store.save(session);

      final values = await storage.readAll();
      expect(values.keys, unorderedEquals(<String>['carenet.session.v1']));
      expect(jsonDecode(values.values.single), <String, dynamic>{
        'schemaVersion': 1,
        'session': session.toJson(),
      });
      expect((await store.read())?.accessToken, 'access-1');
    },
  );

  test('secure session rejects a stale conditional replacement', () async {
    final store = SecureSessionStore();
    final previous = _session('old-access', 'old-refresh');
    final replacement = _session('new-access', 'new-refresh');
    await store.save(previous);
    await store.clear();

    expect(await store.replaceIfCurrent(previous, replacement), isFalse);
    expect(await store.read(), isNull);

    await store.save(replacement);
    expect(await store.clearIfCurrent(previous), isFalse);
    expect((await store.read())?.accessToken, 'new-access');
  });

  test(
    'corrupt or incomplete session record fails closed and clears',
    () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        'carenet.session.v1': jsonEncode(<String, dynamic>{
          'schemaVersion': 1,
          'session': <String, dynamic>{
            'accessToken': 'access',
            'refreshToken': 'refresh',
            'user': <String, dynamic>{'id': 'user-1'},
          },
        }),
      });
      const storage = FlutterSecureStorage();
      final store = SecureSessionStore(storage: storage);

      expect(await store.read(), isNull);
      expect(await storage.readAll(), isEmpty);
    },
  );

  test('legacy complete session migrates atomically', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'carenet.accessToken': 'old-access',
      'carenet.refreshToken': 'old-refresh',
      'carenet.tokenType': 'Bearer',
      'carenet.expiresIn': '900',
      'carenet.user.id': 'user-1',
      'carenet.user.email': 'patient@example.com',
      'carenet.user.role': 'PATIENT',
      'carenet.user.status': 'ACTIVE',
      'carenet.user.emailVerified': 'true',
    });
    const storage = FlutterSecureStorage();
    final store = SecureSessionStore(storage: storage);

    expect((await store.read())?.refreshToken, 'old-refresh');
    expect(
      (await storage.readAll()).keys,
      unorderedEquals(<String>['carenet.session.v1']),
    );
  });

  test(
    '401 refreshes once and retries with the rotated access token',
    () async {
      final store = InMemorySessionStore();
      await store.save(_session('expired-access', 'refresh-1'));
      final adapter = _RefreshRoutingAdapter();
      final dio = CareNetHttpClient.create()..httpClientAdapter = adapter;
      final authClient = AuthApiClient(
        config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
        dio: dio,
      );
      final coordinator = SessionRefreshCoordinator(
        apiClient: authClient,
        sessionStore: store,
      );
      dio.interceptors.add(
        SessionRefreshInterceptor(dio: dio, coordinator: coordinator),
      );

      final response = await dio.get<Map<String, dynamic>>(
        'https://api.example.test/patients/me',
        options: Options(
          headers: const <String, String>{
            'Authorization': 'Bearer expired-access',
          },
        ),
      );

      expect(response.data, <String, dynamic>{'id': 'patient-1'});
      expect(adapter.refreshCalls, 1);
      expect(adapter.protectedCalls, 2);
      expect((await store.read())?.accessToken, 'rotated-access');
    },
  );
}

AuthSessionModel _session(String accessToken, String refreshToken) {
  return AuthSessionModel.fromJson(<String, dynamic>{
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': 'Bearer',
    'expiresIn': 900,
    'user': <String, dynamic>{
      'id': 'user-1',
      'email': 'patient@example.com',
      'role': 'PATIENT',
      'status': 'ACTIVE',
      'emailVerified': true,
    },
  });
}

class _RefreshRoutingAdapter implements HttpClientAdapter {
  int refreshCalls = 0;
  int protectedCalls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path == '/auth/refresh') {
      refreshCalls += 1;
      return _json(_session('rotated-access', 'refresh-2').toJson(), 200);
    }

    protectedCalls += 1;
    if (options.headers['Authorization'] == 'Bearer rotated-access') {
      return _json(<String, dynamic>{'id': 'patient-1'}, 200);
    }
    return _json(<String, dynamic>{'message': 'Unauthorized'}, 401);
  }

  ResponseBody _json(Map<String, dynamic> body, int statusCode) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
