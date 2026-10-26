import 'dart:async';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/services/auth_api_client.dart';
import 'package:app_t/features/Authentication/data/services/session_refresh_coordinator.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Messaging/data/repositories/messaging_repository.dart';
import 'package:app_t/features/Messaging/data/services/messaging_api_client.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_session_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _Store store;
  late _Api api;
  late SessionRefreshCoordinator coordinator;
  late StoredMessagingRealtimeSessionProvider provider;

  setUp(() async {
    store = _Store();
    api = _Api();
    coordinator = SessionRefreshCoordinator(
      apiClient: api,
      sessionStore: store,
    );
    provider = StoredMessagingRealtimeSessionProvider(coordinator: coordinator);
    await store.save(_session());
  });

  test(
    'repository projects captured generation and preserves HTTP fields',
    () async {
      final repository = MessagingRepository(
        apiClient: MessagingApiClient(
          config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
        ),
        sessionStore: store,
      );
      final session = await repository.requireSession();
      expect(session.generation, (await store.capture())!.generation);
      expect(
        session.realtimeIdentity!.matches((await provider.read())!.identity),
        true,
      );
      expect(session.userId, 'user');
      expect(session.role, 'PATIENT');
      expect(session.accessToken, 'old');
      await store.clear();
      await expectLater(
        repository.requireSession(),
        throwsA(isA<AuthFailure>()),
      );
    },
  );

  test('legacy projection does not invent realtime authority', () {
    expect(MessagingSession(_session()).realtimeIdentity, isNull);
  });

  for (final role in ['PATIENT', 'PROFESSIONAL']) {
    test('reads active $role with stored generation', () async {
      await store.save(_session(role: role));
      final credentials = (await provider.read())!;
      expect(credentials.identity.role, role);
      expect(
        credentials.identity.generation,
        (await store.capture())!.generation,
      );
      expect(credentials.accessToken, 'old');
    });
  }

  for (final session in [
    _session(role: 'UNKNOWN'),
    _session(status: 'INACTIVE'),
    _session(user: ''),
    _session(token: ''),
    _session(token: ' padded '),
  ]) {
    test('rejects invalid session ${session.toJson()}', () async {
      await store.save(session);
      expect(await provider.read(), isNull);
    });
  }

  test('missing session reads null', () async {
    await store.clear();
    expect(await provider.read(), isNull);
  });

  for (final change in ['logout', 'generation', 'account', 'role']) {
    test('$change rejects refresh before network', () async {
      final expected = (await provider.read())!;
      if (change == 'logout') {
        await store.clear();
      } else if (change == 'role') {
        await store.replaceSnapshotIfCurrent(
          (await store.capture())!,
          _session(role: 'PROFESSIONAL'),
        );
      } else {
        await store.save(
          _session(user: change == 'account' ? 'other' : 'user'),
        );
      }
      expect(await provider.refresh(expected), isNull);
      expect(api.calls, 0);
    });
  }

  test('already rotated token returns current without network', () async {
    final expected = (await provider.read())!;
    await store.replaceSnapshotIfCurrent(
      (await store.capture())!,
      _session(token: 'rotated'),
    );
    expect((await provider.refresh(expected))!.accessToken, 'rotated');
    expect(api.calls, 0);
  });

  test('concurrent adapter and HTTP refresh share coordinator owner', () async {
    final expected = (await provider.read())!;
    final snapshot = (await store.capture())!;
    api.gate = Completer<AuthSessionModel>();
    final first = provider.refresh(expected);
    await api.started.future;
    final second = provider.refresh(expected);
    final http = coordinator.refresh(expectedSnapshot: snapshot);
    api.gate!.complete(_session(token: 'fresh'));
    expect((await first)!.accessToken, 'fresh');
    expect((await second)!.accessToken, 'fresh');
    expect((await http).accessToken, 'fresh');
    expect(api.calls, 1);
  });

  for (final change in ['account', 'generation', 'logout', 'role']) {
    test('late $change cannot return old credentials', () async {
      final expected = (await provider.read())!;
      api.gate = Completer<AuthSessionModel>();
      final pending = provider.refresh(expected);
      await api.started.future;
      if (change == 'logout') {
        await store.clear();
      } else if (change == 'role') {
        coordinator.onAuthenticated = (_) async {
          await store.replaceSnapshotIfCurrent(
            (await store.capture())!,
            _session(role: 'PROFESSIONAL'),
          );
        };
      } else {
        await store.save(
          _session(user: change == 'account' ? 'other' : 'user'),
        );
      }
      api.gate!.complete(_session(token: 'fresh'));
      expect(await pending, isNull);
    });
  }

  test('authoritative refresh 401 returns null', () async {
    final expected = (await provider.read())!;
    api.failure = const AuthFailure(
      type: AuthFailureType.unauthorized,
      message: 'Expired',
      statusCode: 401,
    );
    expect(await provider.refresh(expected), isNull);
  });

  test('transient storage failures propagate from read and refresh', () async {
    final expected = (await provider.read())!;
    store.failure = StateError('storage unavailable');
    await expectLater(provider.read(), throwsA(same(store.failure)));
    await expectLater(provider.refresh(expected), throwsA(same(store.failure)));
    expect(api.calls, 0);
  });

  test('transient refresh failure preserves session and propagates', () async {
    final expected = (await provider.read())!;
    api.failure = const AuthFailure(
      type: AuthFailureType.network,
      message: 'Offline',
    );
    await expectLater(provider.refresh(expected), throwsA(same(api.failure)));
    expect((await provider.read())!.accessToken, 'old');
  });
}

class _Store extends InMemorySessionStore {
  Object? failure;
  @override
  Future<SessionSnapshot?> capture() async {
    if (failure != null) throw failure!;
    return super.capture();
  }
}

class _Api extends AuthApiClient {
  _Api()
    : super(
        config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
      );
  int calls = 0;
  final started = Completer<void>();
  Completer<AuthSessionModel>? gate;
  AuthFailure? failure;

  @override
  Future<AuthSessionModel> refresh({required String refreshToken}) async {
    calls++;
    if (!started.isCompleted) started.complete();
    if (failure != null) throw failure!;
    return gate?.future ?? _session(token: 'fresh');
  }
}

AuthSessionModel _session({
  String role = 'PATIENT',
  String status = 'ACTIVE',
  String user = 'user',
  String token = 'old',
}) => AuthSessionModel.fromJson({
  'accessToken': token,
  'refreshToken': 'refresh',
  'user': {
    'id': user,
    'email': 'user@example.test',
    'role': role,
    'status': status,
    'emailVerified': true,
  },
});
