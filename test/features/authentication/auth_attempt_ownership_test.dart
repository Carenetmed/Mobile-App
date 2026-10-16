import 'dart:async';
import 'dart:convert';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/auth_api_client.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_session.dart';
import 'package:app_t/features/Notifications/domain/services/notification_session_lifecycle.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final firstMethod in _Method.values) {
    for (final secondMethod in _Method.values) {
      test(
        '$firstMethod late response cannot overwrite newer $secondMethod success',
        () async {
          final h = _Harness();
          final first = _outcome(h.begin(firstMethod));
          final second = h.begin(secondMethod);
          h.api.calls[1].complete(_session('B'));
          expect((await second).user.id, 'B');
          final snapshot = await h.store.capture();

          h.api.calls[0].complete(_session('A'));
          expect(await first, isA<AuthFailure>());
          expect((await h.store.capture())?.generation, snapshot?.generation);
          expect((await h.store.read())?.user.id, 'B');
          expect(h.lifecycle.authenticated, ['B']);
          expect(h.api.calls, hasLength(2));
        },
      );
    }
  }

  test(
    'same-account later login remains authoritative over older tokens',
    () async {
      final h = _Harness();
      final old = _outcome(h.begin(_Method.login));
      final fresh = h.begin(_Method.login);
      h.api.calls[1].complete(_session('same', token: 'fresh'));
      await fresh;
      final snapshot = await h.store.capture();
      h.api.calls[0].complete(_session('same', token: 'old'));

      expect(await old, isA<AuthFailure>());
      expect((await h.store.read())?.accessToken, 'fresh-access');
      expect((await h.store.capture())?.generation, snapshot?.generation);
      expect(h.lifecycle.authenticated, ['same']);
    },
  );

  for (final existing in [false, true]) {
    test(
      'logout invalidates pending login with existing session $existing',
      () async {
        final h = _Harness();
        if (existing) await h.store.save(_session('existing'));
        final pending = _outcome(h.begin(_Method.login));
        await h.repository.logout();
        expect(await h.store.read(), isNull);
        h.api.calls.single.complete(_session('A'));

        expect(await pending, isA<AuthFailure>());
        expect(await h.store.read(), isNull);
        expect(h.lifecycle.authenticated, isEmpty);
        expect(h.api.logoutCalls, existing ? 1 : 0);
      },
    );
  }

  test(
    'newer backend rejection never revives older successful response',
    () async {
      final h = _Harness();
      final older = _outcome(h.begin(_Method.login));
      final newer = _outcome(h.begin(_Method.google));
      const rejected = AuthFailure(
        type: AuthFailureType.invalidCredentials,
        message: 'Fixture rejection',
        statusCode: 401,
      );
      h.api.calls[1].completeError(rejected);
      expect(await newer, same(rejected));
      h.api.calls[0].complete(_session('A'));

      expect(await older, isA<AuthFailure>());
      expect(await h.store.read(), isNull);
      expect(h.lifecycle.authenticated, isEmpty);
    },
  );

  test(
    'password reset confirmation invalidates pending login and retains clear contract',
    () async {
      final h = _Harness();
      await h.store.save(_session('existing'));
      final pending = _outcome(h.begin(_Method.login));
      await h.repository.confirmPasswordReset(
        token: 'fixture',
        password: 'fixture',
      );
      h.api.calls.single.complete(_session('A'));

      expect(await pending, isA<AuthFailure>());
      expect(await h.store.read(), isNull);
      expect(h.api.resetConfirmCalls, 1);
      expect(h.lifecycle.beforeLogoutAccounts, ['existing']);
    },
  );

  test(
    'request-only password reset does not supersede a pending login',
    () async {
      final h = _Harness();
      final pending = h.begin(_Method.login);
      await h.repository.requestPasswordReset(email: 'fixture@example.test');
      h.api.calls.single.complete(_session('A'));

      expect((await pending).user.id, 'A');
      expect((await h.store.read())?.user.id, 'A');
    },
  );

  test(
    'queued native write checks ownership inside the real store queue',
    () async {
      final native = _NativeStorage()..blockNextWrite = true;
      final store = SecureSessionStore(storage: native);
      final blockedSeed = store.save(_session('seed'));
      await native.writeStarted.future;
      final h = _Harness(store: store);
      final old = _outcome(h.begin(_Method.login));
      h.api.calls[0].complete(_session('A'));
      await _turns();
      final newer = h.begin(_Method.google);
      h.api.calls[1].complete(_session('B'));
      native.releaseWrite.complete();
      await blockedSeed;

      expect(await old, isA<AuthFailure>());
      expect((await newer).user.id, 'B');
      expect(native.writtenAccounts, isNot(contains('A')));
      expect((await store.read())?.user.id, 'B');
      expect(h.lifecycle.authenticated, ['B']);
    },
  );

  test(
    'inflight native write loses ownership then rolls back before newer commit',
    () async {
      final native = _NativeStorage()..blockNextWrite = true;
      final store = SecureSessionStore(storage: native);
      final h = _Harness(store: store);
      final old = _outcome(h.begin(_Method.login));
      h.api.calls[0].complete(_session('A'));
      await native.writeStarted.future;
      final newer = h.begin(_Method.register);
      h.api.calls[1].complete(_session('B'));
      native.releaseWrite.complete();

      expect(await old, isA<AuthFailure>());
      expect((await newer).user.id, 'B');
      expect((await store.read())?.user.id, 'B');
      expect(h.lifecycle.authenticated, ['B']);
    },
  );

  for (final sameAccount in [false, true]) {
    test(
      'supersession during notification cannot clear newer generation same account $sameAccount',
      () async {
        final lifecycle = _Lifecycle()..blockedAccount = 'A';
        final h = _Harness(lifecycle: lifecycle);
        final old = _outcome(h.begin(_Method.login));
        h.api.calls[0].complete(_session('A', token: 'old'));
        await lifecycle.blockStarted.future;
        final newer = h.begin(_Method.login);
        h.api.calls[1].complete(
          _session(sameAccount ? 'A' : 'B', token: 'fresh'),
        );
        // Only the first notification is blocked.
        await newer;
        final committed = await h.store.capture();
        lifecycle.releaseBlock.complete();

        expect(await old, isA<AuthFailure>());
        expect((await h.store.capture())?.generation, committed?.generation);
        expect((await h.store.read())?.accessToken, 'fresh-access');
      },
    );
  }

  test('logout during notification prevents late successful return', () async {
    final lifecycle = _Lifecycle()..blockedAccount = 'A';
    final h = _Harness(lifecycle: lifecycle);
    final old = _outcome(h.begin(_Method.login));
    h.api.calls.single.complete(_session('A'));
    await lifecycle.blockStarted.future;
    await h.repository.logout();
    lifecycle.releaseBlock.complete();

    expect(await old, isA<AuthFailure>());
    expect(await h.store.read(), isNull);
  });

  testWidgets(
    'API caller timeout rejects late authority without duplicate API calls',
    (tester) async {
      final h = _Harness(timeout: const Duration(milliseconds: 100));
      final pending = _outcome(h.begin(_Method.login));
      await tester.pump(const Duration(milliseconds: 101));
      expect(await pending, _networkFailure);
      h.api.calls.single.complete(_session('A'));
      await tester.pump();

      expect(await h.store.read(), isNull);
      expect(h.lifecycle.authenticated, isEmpty);
      expect(h.api.calls, hasLength(1));
    },
  );

  testWidgets('older timeout does not invalidate a newer pending attempt', (
    tester,
  ) async {
    final h = _Harness(timeout: const Duration(milliseconds: 100));
    final old = _outcome(h.begin(_Method.login));
    await tester.pump(const Duration(milliseconds: 60));
    final newer = h.begin(_Method.google);
    await tester.pump(const Duration(milliseconds: 41));
    expect(await old, _networkFailure);
    h.api.calls[1].complete(_session('B'));
    await tester.pump();
    expect((await newer).user.id, 'B');
    h.api.calls[0].complete(_session('A'));
    await tester.pump();

    expect((await h.store.read())?.user.id, 'B');
    expect(h.lifecycle.authenticated, ['B']);
  });

  testWidgets(
    'timeout during native save keeps raw queue and rolls back late write',
    (tester) async {
      final native = _NativeStorage()..blockNextWrite = true;
      final store = SecureSessionStore(storage: native);
      final h = _Harness(
        store: store,
        timeout: const Duration(milliseconds: 100),
      );
      final old = _outcome(h.begin(_Method.login));
      h.api.calls.single.complete(_session('A'));
      await tester.pump();
      expect(native.writeStarted.isCompleted, isTrue);
      await tester.pump(const Duration(milliseconds: 101));
      expect(await old, _networkFailure);
      final newer = h.begin(_Method.google);
      h.api.calls[1].complete(_session('B'));
      await tester.pump();
      expect(native.writtenAccounts, isEmpty);
      native.releaseWrite.complete();
      await tester.pump();
      expect((await newer).user.id, 'B');

      expect((await store.read())?.user.id, 'B');
      expect(h.lifecycle.authenticated, ['B']);
      expect(h.api.calls, hasLength(2));
    },
  );

  testWidgets(
    'notification timeout starts exact-snapshot cleanup before callback settles',
    (tester) async {
      final lifecycle = _Lifecycle()..blockedAccount = 'A';
      final h = _Harness(
        lifecycle: lifecycle,
        timeout: const Duration(milliseconds: 100),
      );
      final old = _outcome(h.begin(_Method.login));
      h.api.calls.single.complete(_session('A'));
      await tester.pump();
      expect(lifecycle.blockStarted.isCompleted, isTrue);
      await tester.pump(const Duration(milliseconds: 101));
      expect(await old, _networkFailure);
      expect(await h.store.read(), isNull);
      final newer = h.begin(_Method.login);
      h.api.calls[1].complete(_session('B'));
      await tester.pump();
      await newer;
      final snapshot = await h.store.capture();
      lifecycle.releaseBlock.completeError(
        StateError('private callback error'),
      );
      await tester.pump();

      expect((await h.store.capture())?.generation, snapshot?.generation);
      expect((await h.store.read())?.user.id, 'B');
    },
  );

  testWidgets(
    'older callback timeout cannot clear newer committed generation',
    (tester) async {
      final lifecycle = _Lifecycle()..blockedAccount = 'A';
      final h = _Harness(
        lifecycle: lifecycle,
        timeout: const Duration(milliseconds: 100),
      );
      final old = _outcome(h.begin(_Method.login));
      h.api.calls.single.complete(_session('A'));
      await tester.pump();
      final newer = h.begin(_Method.google);
      h.api.calls[1].complete(_session('B'));
      await tester.pump();
      await newer;
      final snapshot = await h.store.capture();
      await tester.pump(const Duration(milliseconds: 101));
      expect(await old, _networkFailure);
      expect((await h.store.capture())?.generation, snapshot?.generation);
      lifecycle.releaseBlock.complete();
      await tester.pump();
      expect((await h.store.read())?.user.id, 'B');
    },
  );

  testWidgets(
    'timed-out callback cleanup errors are observed without claiming storage removal',
    (tester) async {
      final lifecycle = _Lifecycle()..blockedAccount = 'A';
      final store = _CleanupFailingStore();
      final h = _Harness(
        store: store,
        lifecycle: lifecycle,
        timeout: const Duration(milliseconds: 100),
      );
      final pending = _outcome(h.begin(_Method.login));
      h.api.calls.single.complete(_session('A'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 101));
      expect(await pending, _networkFailure);
      expect((await store.read())?.user.id, 'A');
      expect(store.clearAttempts, 1);
      lifecycle.releaseBlock.complete();
      await tester.pump();
      expect(store.clearAttempts, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('default auth caller budget is sixty seconds', (tester) async {
    final h = _Harness();
    Object? result;
    final pending = _outcome(h.begin(_Method.register)).then((value) {
      result = value;
    });
    await tester.pump(const Duration(seconds: 59));
    expect(result, isNull);
    await tester.pump(const Duration(seconds: 1));
    await pending;
    expect(result, _networkFailure);
    h.api.calls.single.complete(_session('A'));
    await tester.pump();
    expect(await h.store.read(), isNull);
    expect(h.api.calls, hasLength(1));
  });

  test(
    'storage write errors are normalized without raw details or notifications',
    () async {
      final h = _Harness(store: _FailingStore());
      final pending = _outcome(h.begin(_Method.login));
      h.api.calls.single.complete(_session('A'));

      final error = await pending;
      expect(error, _networkFailure);
      expect(error.toString(), isNot(contains('private')));
      expect(h.lifecycle.authenticated, isEmpty);
    },
  );

  test(
    'failed logout storage clear does not report successful logout',
    () async {
      final store = _FailingStore()..failClear = true;
      await store.save(_session('existing'));
      final h = _Harness(store: store);

      await expectLater(h.repository.logout(), throwsA(_networkFailure));
      expect((await store.read())?.user.id, 'existing');
    },
  );

  test(
    'optional notification failure still permits current committed authentication',
    () async {
      final h = _Harness(lifecycle: _Lifecycle()..failNotification = true);
      final pending = h.begin(_Method.login);
      h.api.calls.single.complete(_session('A'));

      expect((await pending).user.id, 'A');
      expect((await h.store.read())?.user.id, 'A');
    },
  );

  test(
    'server session role is preserved rather than derived from register input',
    () async {
      final h = _Harness();
      final pending = h.begin(_Method.register);
      final serverSession = AuthSessionModel.fromJson({
        ..._session('A').toJson(),
        'user': {
          ..._session('A').toJson()['user'] as Map<String, dynamic>,
          'role': 'PROFESSIONAL',
        },
      });
      h.api.calls.single.complete(serverSession);
      expect((await pending).user.role, 'PROFESSIONAL');
      expect((await h.store.read())?.user.role, 'PROFESSIONAL');
    },
  );

  for (final exit in _Exit.values) {
    testWidgets(
      '$exit bounds raw clear wait without claiming removal or clearing newer login',
      (tester) async {
        final store = _BlockedClearStore();
        await store.save(_session('same', token: 'same'));
        final h = _Harness(
          store: store,
          timeout: const Duration(milliseconds: 100),
        );
        final pending = _voidOutcome(_exit(h.repository, exit));
        await tester.pump();
        expect(store.clearStarted.isCompleted, isTrue);
        final oldGeneration = (await store.capture())?.generation;
        await tester.pump(const Duration(milliseconds: 101));
        expect(await pending, _networkFailure);
        expect((await store.capture())?.generation, oldGeneration);
        expect(store.clearAttempts, 1);

        final newer = h.begin(_Method.login);
        // Identical account and tokens still belong to a fresh generation.
        h.api.calls.single.complete(_session('same', token: 'same'));
        await tester.pump();
        await newer;
        final fresh = await store.capture();
        expect(fresh?.generation, isNot(oldGeneration));
        store.releaseClear.complete();
        await tester.pump();
        expect((await store.capture())?.generation, fresh?.generation);
        expect(store.clearAttempts, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '$exit observes late raw clear errors and preserves newer login',
      (tester) async {
        final store = _BlockedClearStore();
        await store.save(_session('existing'));
        final h = _Harness(
          store: store,
          timeout: const Duration(milliseconds: 100),
        );
        final pending = _voidOutcome(_exit(h.repository, exit));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 101));
        expect(await pending, _networkFailure);
        expect((await store.read())?.user.id, 'existing');
        final newer = h.begin(_Method.google);
        h.api.calls.single.complete(_session('B'));
        await tester.pump();
        await newer;
        final fresh = await store.capture();
        store.releaseClear.completeError(
          StateError('private late clear error'),
        );
        await tester.pump();

        expect((await store.capture())?.generation, fresh?.generation);
        expect((await store.read())?.user.id, 'B');
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '$exit timeout never releases the real secure-store clear queue',
      (tester) async {
        final native = _NativeStorage();
        final store = SecureSessionStore(storage: native);
        await store.save(_session('existing'));
        native.blockNextWrite = true;
        final h = _Harness(
          store: store,
          timeout: const Duration(milliseconds: 100),
        );
        final pending = _voidOutcome(_exit(h.repository, exit));
        await tester.pump();
        expect(native.writeStarted.isCompleted, isTrue);
        await tester.pump(const Duration(milliseconds: 101));
        expect(await pending, _networkFailure);
        expect(native.writtenAccounts, ['existing']);
        final newer = h.begin(_Method.login);
        h.api.calls.single.complete(_session('B'));
        await tester.pump();
        expect(native.writtenAccounts, ['existing']);
        native.releaseWrite.complete();
        await tester.pump();
        expect((await newer).user.id, 'B');
        expect((await store.read())?.user.id, 'B');
        expect(h.lifecycle.authenticated, ['B']);
      },
    );

    for (final lateError in [false, true]) {
      testWidgets(
        '$exit raw API timeout preserves new owner and observes late error $lateError',
        (tester) async {
          final h = _Harness(timeout: const Duration(milliseconds: 100));
          await h.store.save(_session('same', token: 'same'));
          final older = _outcome(h.begin(_Method.login));
          h.api.exitGate = Completer<void>();
          final pending = _voidOutcome(_exit(h.repository, exit));
          await tester.pump();
          expect(h.api.logoutCalls + h.api.resetConfirmCalls, 1);
          await tester.pump(const Duration(milliseconds: 60));
          final newer = _outcome(h.begin(_Method.register));
          await tester.pump(const Duration(milliseconds: 41));
          expect(await pending, _networkFailure);
          expect(await older, _networkFailure);
          h.api.calls[1].complete(_session('same', token: 'same'));
          await tester.pump();
          expect(await newer, isA<AuthSession>());
          final fresh = await h.store.capture();
          h.api.calls[0].complete(_session('older'));
          if (lateError) {
            h.api.exitGate!.completeError(StateError('private late API error'));
          } else {
            h.api.exitGate!.complete();
          }
          await tester.pump();
          expect((await h.store.capture())?.generation, fresh?.generation);
          expect(h.lifecycle.authenticated, ['same']);
          expect(h.api.logoutCalls + h.api.resetConfirmCalls, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

final _networkFailure = isA<AuthFailure>()
    .having((error) => error.type, 'type', AuthFailureType.network)
    .having((error) => error.shouldClearSession, 'shouldClearSession', isFalse);

enum _Method { login, register, google }

enum _Exit { logout, reset }

Future<void> _exit(AuthRepository repository, _Exit exit) =>
    exit == _Exit.logout
        ? repository.logout()
        : repository.confirmPasswordReset(
          token: 'fixture',
          password: 'fixture',
        );

Future<Object?> _voidOutcome(Future<void> future) async {
  try {
    await future;
    return null;
  } catch (error) {
    return error;
  }
}

Future<Object> _outcome(Future<AuthSession> future) async {
  try {
    return await future;
  } catch (error) {
    return error;
  }
}

Future<void> _turns() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _Harness {
  _Harness({
    SessionStore? store,
    _Lifecycle? lifecycle,
    Duration timeout = const Duration(seconds: 60),
  }) : store = store ?? InMemorySessionStore(),
       lifecycle = lifecycle ?? _Lifecycle() {
    repository = AuthRepository(
      apiClient: api,
      sessionStore: this.store,
      notificationLifecycle: this.lifecycle,
      authCallerTimeout: timeout,
    );
  }
  final SessionStore store;
  final _Lifecycle lifecycle;
  final api = _Api();
  late final AuthRepository repository;
  Future<AuthSession> begin(_Method method) {
    switch (method) {
      case _Method.login:
        return repository.login(
          email: 'fixture@example.test',
          password: 'fixture',
        );
      case _Method.register:
        return repository.register(
          email: 'fixture@example.test',
          password: 'fixture',
          role: 'PATIENT',
        );
      case _Method.google:
        return repository.googleSignIn(idToken: 'fixture');
    }
  }
}

class _Api extends AuthApiClient {
  _Api()
    : super(config: const CareNetApiConfig(baseUrl: 'https://fixture.invalid'));
  final calls = <Completer<AuthSessionModel>>[];
  int logoutCalls = 0;
  int resetConfirmCalls = 0;
  Completer<void>? exitGate;
  Future<AuthSessionModel> _pending() {
    final call = Completer<AuthSessionModel>();
    calls.add(call);
    return call.future;
  }

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) => _pending();
  @override
  Future<AuthSessionModel> register({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic> profile = const {},
  }) => _pending();
  @override
  Future<AuthSessionModel> googleSignIn({
    required String idToken,
    String? role,
  }) => _pending();
  @override
  Future<void> logout({required String refreshToken}) async {
    logoutCalls++;
    await exitGate?.future;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {}
  @override
  Future<void> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    resetConfirmCalls++;
    await exitGate?.future;
  }
}

class _Lifecycle implements NotificationSessionLifecycle {
  final authenticated = <String>[];
  final beforeLogoutAccounts = <String>[];
  String? blockedAccount;
  bool failNotification = false;
  final blockStarted = Completer<void>();
  final releaseBlock = Completer<void>();
  @override
  Future<void> onAuthenticatedSession(AuthSessionModel session) async {
    authenticated.add(session.user.id);
    if (failNotification) throw StateError('private notification error');
    if (session.user.id == blockedAccount && !blockStarted.isCompleted) {
      blockStarted.complete();
      await releaseBlock.future;
    }
  }

  @override
  Future<void> beforeLogout(AuthSessionModel session) async {
    beforeLogoutAccounts.add(session.user.id);
  }

  @override
  Future<void> afterAccountDeletion(AuthSessionModel session) async {}
}

class _FailingStore extends InMemorySessionStore {
  bool failClear = false;
  @override
  Future<SessionSnapshot?> saveIfOwned(
    AuthSessionModel session,
    bool Function() isCurrent,
  ) async {
    throw StateError('private storage failure');
  }

  @override
  Future<bool> clearSnapshotIfCurrent(SessionSnapshot snapshot) async {
    if (failClear) throw StateError('private storage failure');
    return super.clearSnapshotIfCurrent(snapshot);
  }
}

class _CleanupFailingStore extends InMemorySessionStore {
  int clearAttempts = 0;
  @override
  Future<bool> clearSnapshotIfCurrent(SessionSnapshot snapshot) async {
    clearAttempts++;
    throw StateError('private cleanup failure');
  }
}

class _BlockedClearStore extends InMemorySessionStore {
  final clearStarted = Completer<void>();
  final releaseClear = Completer<void>();
  int clearAttempts = 0;
  @override
  Future<bool> clearSnapshotIfCurrent(SessionSnapshot snapshot) async {
    clearAttempts++;
    if (!clearStarted.isCompleted) clearStarted.complete();
    await releaseClear.future;
    return super.clearSnapshotIfCurrent(snapshot);
  }
}

AuthSessionModel _session(String account, {String? token}) =>
    AuthSessionModel.fromJson({
      'accessToken': '${token ?? account}-access',
      'refreshToken': '${token ?? account}-refresh',
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'user': {
        'id': account,
        'email': '$account@example.test',
        'role': 'PATIENT',
        'status': 'ACTIVE',
        'emailVerified': true,
      },
    });

class _NativeStorage extends FlutterSecureStorage {
  final values = <String, String>{};
  final writtenAccounts = <String>[];
  bool blockNextWrite = false;
  final writeStarted = Completer<void>();
  final releaseWrite = Completer<void>();
  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];
  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (blockNextWrite) {
      blockNextWrite = false;
      writeStarted.complete();
      await releaseWrite.future;
    }
    if (value == null) {
      values.remove(key);
      return;
    }
    values[key] = value;
    final record = jsonDecode(value) as Map<String, dynamic>;
    if (record['session'] case final Map<String, dynamic> session) {
      writtenAccounts.add(
        (session['user'] as Map<String, dynamic>)['id'] as String,
      );
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }
}
