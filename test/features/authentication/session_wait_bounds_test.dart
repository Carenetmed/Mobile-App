import 'dart:async';
import 'dart:convert';

import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../notifications/notification_test_fakes.dart';

const _key = 'carenet.session.v1';
const _timeout = Duration(milliseconds: 20);

final _safeFailure = throwsA(
  isA<AuthFailure>()
      .having((f) => f.type, 'type', AuthFailureType.network)
      .having(
        (f) => f.message,
        'message',
        'Unable to read saved session. Please try again.',
      )
      .having((f) => f.statusCode, 'statusCode', isNull)
      .having((f) => f.shouldClearSession, 'shouldClearSession', false),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final capture in [false, true]) {
    test(
      'hung ${capture ? 'capture' : 'read'} bounds wait and recovers',
      () async {
        final storage = _ControlledStorage();
        final store = SecureSessionStore(
          storage: storage,
          readTimeout: _timeout,
        );
        await store.save(notificationTestSession());
        final persisted = storage.values[_key];
        final gate = Completer<void>();
        storage.readGate = gate;
        await expectLater(
          capture ? store.capture() : store.read(),
          _safeFailure,
        );
        expect(storage.values[_key], persisted);
        gate.complete();
        storage.readGate = null;
        expect((await store.capture())?.session.user.id, 'user-1');
      },
    );

    test(
      'late ${capture ? 'capture' : 'read'} error is observed and sanitized',
      () async {
        final storage = _ControlledStorage();
        final store = SecureSessionStore(
          storage: storage,
          readTimeout: _timeout,
        );
        await store.save(notificationTestSession());
        final persisted = storage.values[_key];
        final gate = Completer<void>();
        storage.readGate = gate;
        await expectLater(
          capture ? store.capture() : store.read(),
          _safeFailure,
        );
        storage.readGate = null;
        gate.completeError(StateError('private platform token detail'));
        // flutter_test reports any unhandled asynchronous error as a test failure.
        expect((await store.capture())?.session.user.id, 'user-1');
        expect(storage.values[_key], persisted);
      },
    );

    test(
      'queued ${capture ? 'capture' : 'read'} timeout does not release write queue',
      () async {
        final storage = _ControlledStorage();
        final store = SecureSessionStore(
          storage: storage,
          readTimeout: _timeout,
        );
        final gate = Completer<void>();
        storage.writeGate = gate;
        final first = store.save(notificationTestSession());
        await storage.writeStarted.future;
        await expectLater(
          capture ? store.capture() : store.read(),
          _safeFailure,
        );
        final second = store.save(notificationTestSession(userId: 'newer'));
        await Future<void>.delayed(Duration.zero);
        expect(storage.writes, 1);
        expect(storage.reads, 0);
        storage.writeGate = null;
        gate.complete();
        await first;
        await second;
        expect(storage.maxActiveWrites, 1);
        expect((await store.read())?.user.id, 'newer');
      },
    );

    test(
      '${capture ? 'capture' : 'read'} sanitizes immediate errors without clearing',
      () async {
        final storage = _ControlledStorage();
        final store = SecureSessionStore(storage: storage);
        await store.save(notificationTestSession());
        final persisted = storage.values[_key];
        storage.failRead = true;
        await expectLater(
          capture ? store.capture() : store.read(),
          _safeFailure,
        );
        expect(storage.values[_key], persisted);
        storage.failRead = false;
        expect((await store.read())?.user.id, 'user-1');
      },
    );
  }

  test('secure reads default to five seconds', () {
    expect(SecureSessionStore().readTimeout, const Duration(seconds: 5));
  });

  test(
    'timed out native read keeps later writes queued until actual completion',
    () async {
      final storage = _ControlledStorage();
      final store = SecureSessionStore(storage: storage, readTimeout: _timeout);
      final gate = Completer<void>();
      storage.readGate = gate;
      await expectLater(store.read(), _safeFailure);
      final save = store.save(notificationTestSession(userId: 'newer'));
      await Future<void>.delayed(Duration.zero);
      expect(storage.writes, 0);
      storage.readGate = null;
      gate.complete();
      await save;
      expect((await store.read())?.user.id, 'newer');
    },
  );

  test(
    'queued stale owned save performs zero writes and preserves prior generation',
    () async {
      final storage = _ControlledStorage();
      final store = SecureSessionStore(storage: storage);
      await store.save(notificationTestSession());
      final previous = await store.capture();
      final gate = Completer<void>();
      storage.readGate = gate;
      storage.readStarted = Completer<void>();
      final blocking = store.capture();
      await storage.readStarted.future;
      var current = true;
      final owned = store.saveIfOwned(
        notificationTestSession(userId: 'stale'),
        () => current,
      );
      current = false;
      storage.readGate = null;
      gate.complete();
      await blocking;
      expect(await owned, isNull);
      expect(storage.writes, 1);
      expect((await store.capture())?.generation, previous?.generation);
    },
  );

  test('owned commit returns its new persisted generation', () async {
    final storage = _ControlledStorage();
    final store = SecureSessionStore(storage: storage);
    await store.save(notificationTestSession());
    final previous = await store.capture();
    final saved = await store.saveIfOwned(
      notificationTestSession(userId: 'owned'),
      () => true,
    );
    expect(saved?.generation, isNot(previous?.generation));
    expect(saved?.generation, (await store.capture())?.generation);
    expect(saved?.session.user.id, 'owned');
  });

  test(
    'ownership lost in flight rolls back own generation before newer queued save',
    () async {
      final storage = _ControlledStorage();
      final store = SecureSessionStore(storage: storage);
      final gate = Completer<void>();
      storage.writeGate = gate;
      var current = true;
      final owned = store.saveIfOwned(notificationTestSession(), () => current);
      await storage.writeStarted.future;
      current = false;
      final newer = store.save(notificationTestSession(userId: 'newer'));
      storage.writeGate = null;
      gate.complete();
      expect(await owned, isNull);
      await newer;
      expect((await store.read())?.user.id, 'newer');
      expect(storage.maxActiveWrites, 1);
    },
  );

  test(
    'ownership lost during cleanup rolls back own committed generation',
    () async {
      final storage = _ControlledStorage();
      final store = SecureSessionStore(storage: storage);
      var current = true;
      storage.onLegacyDelete = () => current = false;
      expect(
        await store.saveIfOwned(notificationTestSession(), () => current),
        isNull,
      );
      expect(await store.capture(), isNull);
    },
  );

  test(
    'conditional prewrite failure preserves previous valid record',
    () async {
      final storage = _ControlledStorage();
      final store = SecureSessionStore(storage: storage);
      await store.save(notificationTestSession());
      final previous = storage.values[_key];
      storage.failBeforeWrite = true;
      await expectLater(
        store.saveIfOwned(
          notificationTestSession(userId: 'failed'),
          () => true,
        ),
        throwsStateError,
      );
      expect(storage.values[_key], previous);
    },
  );

  test(
    'conditional postwrite error rolls back own generation and propagates failure',
    () async {
      final storage = _ControlledStorage()..failAfterWrite = true;
      final store = SecureSessionStore(storage: storage);
      // Only fail the session write, so rollback itself can complete.
      await expectLater(
        store.saveIfOwned(notificationTestSession(), () => true),
        throwsStateError,
      );
      expect(await store.capture(), isNull);
    },
  );

  test(
    'conditional cleanup error rolls back own generation and propagates failure',
    () async {
      final storage = _ControlledStorage()..failLegacyDeleteOnce = true;
      final store = SecureSessionStore(storage: storage);
      await expectLater(
        store.saveIfOwned(notificationTestSession(), () => true),
        throwsStateError,
      );
      expect(await store.capture(), isNull);
    },
  );

  test(
    'partial conditional write cannot claim success or verified cleanup',
    () async {
      final storage = _ControlledStorage();
      final store = SecureSessionStore(storage: storage);
      storage.afterWrite = () {
        storage.values[_key] = '{partial';
        throw StateError('partial write');
      };
      await expectLater(
        store.saveIfOwned(notificationTestSession(), () => true),
        throwsFormatException,
      );
      expect(storage.values[_key], '{partial');
      // Normal recovery rejects incomplete bytes; the owned rollback did not
      // assume that an unreadable record belonged to it.
      expect(await store.capture(), isNull);
    },
  );

  test(
    'rollback inspection failure cannot claim an owned write was cleared',
    () async {
      final storage = _ControlledStorage();
      final store = SecureSessionStore(storage: storage);
      storage.afterWrite = () {
        storage.failRead = true;
        throw StateError('write result uncertain');
      };
      await expectLater(
        store.saveIfOwned(notificationTestSession(), () => true),
        throwsStateError,
      );
      expect(
        jsonDecode(storage.values[_key]!)['session']['user']['id'],
        'user-1',
      );
      storage.failRead = false;
      expect((await store.read())?.user.id, 'user-1');
    },
  );

  test(
    'internal conditional reads remain raw and keep their queue ownership',
    () async {
      final storage = _ControlledStorage();
      final store = SecureSessionStore(storage: storage, readTimeout: _timeout);
      await store.save(notificationTestSession());
      final snapshot = (await store.capture())!;
      final gate = Completer<void>();
      storage.readGate = gate;
      final clearing = store.clearSnapshotIfCurrent(snapshot);
      await expectLater(store.capture(), _safeFailure);
      expect(storage.writes, 1);
      storage.readGate = null;
      gate.complete();
      expect(await clearing, isTrue);
      expect(await store.capture(), isNull);
    },
  );

  test(
    'rollback preserves a different generation observed after write error',
    () async {
      final storage = _ControlledStorage();
      final store = SecureSessionStore(storage: storage);
      await store.save(notificationTestSession(userId: 'newer'));
      final newer = storage.values[_key]!;
      storage.afterWrite = () {
        storage.values[_key] = newer;
        throw StateError('write result uncertain');
      };
      await expectLater(
        store.saveIfOwned(notificationTestSession(), () => true),
        throwsStateError,
      );
      expect(storage.values[_key], newer);
    },
  );

  test(
    'rollback failure reports failure rather than claiming session cleared',
    () async {
      final storage = _ControlledStorage();
      final store = SecureSessionStore(storage: storage);
      var current = true;
      storage.afterWrite = () {
        current = false;
        storage.failBeforeWrite = true;
      };
      await expectLater(
        store.saveIfOwned(notificationTestSession(), () => current),
        throwsStateError,
      );
      expect(
        jsonDecode(storage.values[_key]!)['session']['user']['id'],
        'user-1',
      );
    },
  );

  for (final store in <SessionStore>[
    InMemorySessionStore(),
    InMemoryNotificationSessionStore(),
  ]) {
    test(
      '${store.runtimeType} owned save is atomic with a fresh generation',
      () async {
        await store.save(notificationTestSession());
        final previous = await store.capture();
        expect(
          await store.saveIfOwned(
            notificationTestSession(userId: 'stale'),
            () => false,
          ),
          isNull,
        );
        expect((await store.capture())?.generation, previous?.generation);
        final saved = await store.saveIfOwned(
          notificationTestSession(userId: 'owned'),
          () => true,
        );
        expect(saved?.generation, isNot(previous?.generation));
        expect((await store.capture())?.generation, saved?.generation);
        expect((await store.read())?.user.id, 'owned');
      },
    );
  }
}

class _ControlledStorage extends FlutterSecureStorage {
  final values = <String, String>{};
  Completer<void>? readGate;
  Completer<void>? writeGate;
  final writeStarted = Completer<void>();
  Completer<void> readStarted = Completer<void>();
  bool failRead = false;
  bool failBeforeWrite = false;
  bool failAfterWrite = false;
  bool failLegacyDeleteOnce = false;
  void Function()? afterWrite;
  void Function()? onLegacyDelete;
  int reads = 0;
  int writes = 0;
  int activeWrites = 0;
  int maxActiveWrites = 0;

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    reads++;
    if (!readStarted.isCompleted) readStarted.complete();
    if (readGate case final gate?) await gate.future;
    if (failRead) throw StateError('private platform token detail');
    return values[key];
  }

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
    writes++;
    activeWrites++;
    if (activeWrites > maxActiveWrites) maxActiveWrites = activeWrites;
    if (!writeStarted.isCompleted) writeStarted.complete();
    try {
      if (writeGate case final gate?) await gate.future;
      if (failBeforeWrite) throw StateError('write failed before commit');
      if (value == null) {
        values.remove(key);
      } else {
        values[key] = value;
      }
      final callback = afterWrite;
      afterWrite = null;
      callback?.call();
      if (failAfterWrite) {
        failAfterWrite = false;
        throw StateError('write failed after commit');
      }
    } finally {
      activeWrites--;
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
    if (key != _key) {
      onLegacyDelete?.call();
      if (failLegacyDeleteOnce) {
        failLegacyDeleteOnce = false;
        throw StateError('legacy cleanup failed');
      }
    }
    values.remove(key);
  }
}
