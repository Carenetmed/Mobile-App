import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/auth_api_client.dart';
import 'package:app_t/features/Notifications/domain/services/notification_session_lifecycle.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notification_test_fakes.dart';

void main() {
  test(
    'successful login binds notification lifecycle after session storage',
    () async {
      final store = InMemoryNotificationSessionStore();
      final lifecycle = _RecordingLifecycle();
      final repository = _repository(store, lifecycle);

      final session = await repository.login(
        email: 'patient@example.com',
        password: 'CareNet@123',
      );

      expect((await store.read())?.user.id, 'user-1');
      expect(lifecycle.authenticated, [session]);
    },
  );

  test(
    'notification registration failure never invalidates successful login',
    () async {
      final store = InMemoryNotificationSessionStore();
      final lifecycle = _RecordingLifecycle(failAuthentication: true);

      final session = await _repository(
        store,
        lifecycle,
      ).login(email: 'patient@example.com', password: 'CareNet@123');

      expect(session.user.id, 'user-1');
      expect((await store.read())?.accessToken, 'access-token');
    },
  );

  test(
    'logout unbinds notification installation before clearing session',
    () async {
      final session = notificationTestSession();
      final store = InMemoryNotificationSessionStore(session);
      final lifecycle = _RecordingLifecycle();

      await _repository(store, lifecycle).logout();

      expect(lifecycle.loggedOut, [session]);
      expect(await store.read(), isNull);
    },
  );

  test(
    'unauthorized account refresh unbinds installation before session clear',
    () async {
      final session = notificationTestSession();
      final store = InMemoryNotificationSessionStore(session);
      final lifecycle = _RecordingLifecycle();
      final repository = AccountRepository(
        apiClient: AuthApiClient(
          config: const CareNetApiConfig(baseUrl: 'https://api.carenet.test'),
          dio: Dio()..httpClientAdapter = _UnauthorizedAdapter(),
        ),
        sessionStore: store,
        notificationLifecycle: lifecycle,
      );

      await expectLater(repository.currentAccount(), throwsA(isA<Exception>()));

      expect(lifecycle.loggedOut, [session]);
      expect(await store.read(), isNull);
    },
  );
}

AuthRepository _repository(
  InMemoryNotificationSessionStore store,
  NotificationSessionLifecycle lifecycle,
) {
  return AuthRepository(
    apiClient: AuthApiClient(
      config: const CareNetApiConfig(baseUrl: 'https://api.carenet.test'),
      dio: Dio()..httpClientAdapter = _AuthAdapter(),
    ),
    sessionStore: store,
    notificationLifecycle: lifecycle,
  );
}

class _RecordingLifecycle implements NotificationSessionLifecycle {
  _RecordingLifecycle({this.failAuthentication = false});

  final bool failAuthentication;
  final List<AuthSessionModel> authenticated = <AuthSessionModel>[];
  final List<AuthSessionModel> loggedOut = <AuthSessionModel>[];

  @override
  Future<void> beforeLogout(AuthSessionModel session) async {
    loggedOut.add(session);
  }

  @override
  Future<void> afterAccountDeletion(AuthSessionModel session) async {
    loggedOut.add(session);
  }

  @override
  Future<void> onAuthenticatedSession(AuthSessionModel session) async {
    authenticated.add(session);
    if (failAuthentication) throw StateError('FCM unavailable');
  }
}

class _AuthAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body =
        options.path.endsWith('/auth/login')
            ? <String, dynamic>{
              'accessToken': 'access-token',
              'refreshToken': 'refresh-token',
              'tokenType': 'Bearer',
              'expiresIn': 900,
              'user': <String, dynamic>{
                'id': 'user-1',
                'email': 'patient@example.com',
                'role': 'PATIENT',
                'status': 'ACTIVE',
                'emailVerified': true,
              },
            }
            : <String, dynamic>{};
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _UnauthorizedAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{'message': 'Unauthorized'}),
      401,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
