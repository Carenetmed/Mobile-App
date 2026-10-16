import 'dart:convert';

import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _sessionKey = 'carenet.session.v1';
const _legacyAccessKey = 'carenet.accessToken';

final _safeReadFailure = throwsA(
  isA<AuthFailure>()
      .having((failure) => failure.type, 'type', AuthFailureType.network)
      .having((failure) => failure.message, 'message',
          'Unable to read saved session. Please try again.')
      .having((failure) => failure.statusCode, 'statusCode', isNull)
      .having((failure) => failure.shouldClearSession, 'shouldClearSession', false),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'mixed legacy accounts are discarded without reading individual fields',
    () async {
      final storage = _FaultStorage()..values.addAll(_mixedLegacy());

      expect(await SecureSessionStore(storage: storage).capture(), isNull);
      expect(storage.readKeys, [_sessionKey]);
      expect(storage.values, isEmpty);
      expect(await SecureSessionStore(storage: storage).read(), isNull);
    },
  );

  test(
    'legacy cleanup failure cannot resurrect remaining legacy fields on recreation',
    () async {
      final storage =
          _FaultStorage()
            ..values.addAll(_mixedLegacy())
            ..failDeleteKey = _legacyAccessKey;

      await expectLater(
        SecureSessionStore(storage: storage).read(),
        _safeReadFailure,
      );
      expect(storage.values[_legacyAccessKey], isNotNull);
      await expectLater(
        SecureSessionStore(storage: storage).capture(),
        _safeReadFailure,
      );
      expect(storage.values.containsKey(_sessionKey), isFalse);

      storage.failDeleteKey = null;
      expect(await SecureSessionStore(storage: storage).read(), isNull);
      expect(storage.values, isEmpty);
    },
  );

  test(
    'failure before first envelope write never promotes legacy data',
    () async {
      final storage =
          _FaultStorage()
            ..values.addAll(_mixedLegacy())
            ..writeFault = _WriteFault.before;
      await expectLater(
        SecureSessionStore(storage: storage).save(_session('new')),
        throwsStateError,
      );
      expect(storage.values.containsKey(_sessionKey), isFalse);

      storage.writeFault = null;
      expect(await SecureSessionStore(storage: storage).read(), isNull);
      expect(storage.values, isEmpty);
    },
  );

  test(
    'failure before replacement write preserves the prior valid v2 envelope',
    () async {
      final storage = _FaultStorage();
      final store = SecureSessionStore(storage: storage);
      await store.save(_session('previous'));
      final previous = storage.values[_sessionKey];
      storage.writeFault = _WriteFault.before;

      await expectLater(store.save(_session('new')), throwsStateError);
      expect(storage.values[_sessionKey], previous);
      final recovered = await SecureSessionStore(storage: storage).capture();
      expect(recovered?.session.toJson(), _session('previous').toJson());
    },
  );

  test(
    'partial envelope write fails closed on recreation without legacy fallback',
    () async {
      final storage =
          _FaultStorage()
            ..values.addAll(_mixedLegacy())
            ..writeFault = _WriteFault.partial;
      await expectLater(
        SecureSessionStore(storage: storage).save(_session('new')),
        throwsStateError,
      );
      expect(
        () => jsonDecode(storage.values[_sessionKey]!),
        throwsFormatException,
      );

      storage.writeFault = null;
      expect(await SecureSessionStore(storage: storage).capture(), isNull);
      expect(storage.values, isEmpty);
    },
  );

  test(
    'complete envelope surviving a write error is preserved on recreation',
    () async {
      final storage =
          _FaultStorage()
            ..values.addAll(_mixedLegacy())
            ..writeFault = _WriteFault.after;
      await expectLater(
        SecureSessionStore(storage: storage).save(_session('new')),
        throwsStateError,
      );

      final recovered = await SecureSessionStore(storage: storage).capture();
      expect(recovered?.session.toJson(), _session('new').toJson());
      expect(recovered?.generation, isNotEmpty);
    },
  );

  test(
    'postwrite legacy cleanup failure preserves the new v2 session and generation',
    () async {
      final storage =
          _FaultStorage()
            ..values.addAll(_mixedLegacy())
            ..failDeleteKey = _legacyAccessKey;
      final store = SecureSessionStore(storage: storage);
      await expectLater(store.save(_session('new')), throwsStateError);
      final persisted = storage.values[_sessionKey];
      expect(storage.values[_legacyAccessKey], isNotNull);

      final recreated = SecureSessionStore(storage: storage);
      final recovered = await recreated.capture();
      expect(recovered?.session.toJson(), _session('new').toJson());
      expect(storage.values[_sessionKey], persisted);
      expect((await recreated.capture())?.generation, recovered?.generation);

      storage.failDeleteKey = null;
      await recreated.clear();
      expect(await SecureSessionStore(storage: storage).read(), isNull);
      expect(storage.values, isEmpty);
    },
  );

  test(
    'v1 envelope migration survives postwrite cleanup failure without mixing legacy fields',
    () async {
      final storage =
          _FaultStorage()
            ..values.addAll(_mixedLegacy())
            ..values[_sessionKey] = jsonEncode({
              'schemaVersion': 1,
              'session': _session('envelope').toJson(),
            })
            ..failDeleteKey = _legacyAccessKey;
      await expectLater(
        SecureSessionStore(storage: storage).capture(),
        _safeReadFailure,
      );

      final recovered = await SecureSessionStore(storage: storage).capture();
      expect(recovered?.session.toJson(), _session('envelope').toJson());
      expect(recovered?.generation, isNotEmpty);
      expect(jsonDecode(storage.values[_sessionKey]!)['schemaVersion'], 2);
    },
  );

  for (final failedKey in [_legacyAccessKey, _sessionKey]) {
    test(
      'clear tombstone survives failed deletion of $failedKey and recreation',
      () async {
        final storage = _FaultStorage();
        await SecureSessionStore(storage: storage).save(_session('new'));
        storage.values.addAll(_mixedLegacy());
        storage.failDeleteKey = failedKey;

        await expectLater(
          SecureSessionStore(storage: storage).clear(),
          throwsStateError,
        );
        expect(jsonDecode(storage.values[_sessionKey]!), {
          'schemaVersion': 2,
          'cleared': true,
        });
        await expectLater(
          SecureSessionStore(storage: storage).read(),
          _safeReadFailure,
        );
        expect(jsonDecode(storage.values[_sessionKey]!)['cleared'], isTrue);

        storage.failDeleteKey = null;
        expect(await SecureSessionStore(storage: storage).capture(), isNull);
        expect(storage.values, isEmpty);
        expect(await SecureSessionStore(storage: storage).read(), isNull);
      },
    );
  }

  test(
    'failed tombstone write reports failure and cannot claim prior session was cleared',
    () async {
      final storage = _FaultStorage();
      final store = SecureSessionStore(storage: storage);
      await store.save(_session('previous'));
      storage.writeFault = _WriteFault.before;

      await expectLater(store.clear(), throwsStateError);
      expect(
        (await SecureSessionStore(storage: storage).read())?.toJson(),
        _session('previous').toJson(),
      );
      storage.writeFault = null;
      await store.clear();
      expect(await SecureSessionStore(storage: storage).read(), isNull);
    },
  );

  test(
    'partial tombstone write is rejected on recreation without legacy resurrection',
    () async {
      final storage = _FaultStorage();
      await SecureSessionStore(storage: storage).save(_session('new'));
      storage.values.addAll(_mixedLegacy());
      storage.writeFault = _WriteFault.partial;
      await expectLater(
        SecureSessionStore(storage: storage).clear(),
        throwsStateError,
      );

      storage.writeFault = null;
      expect(await SecureSessionStore(storage: storage).read(), isNull);
      expect(storage.values, isEmpty);
    },
  );
}

AuthSessionModel _session(String account) => AuthSessionModel.fromJson({
  'accessToken': '$account-access',
  'refreshToken': '$account-refresh',
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

Map<String, String> _mixedLegacy() => {
  _legacyAccessKey: 'first-access',
  'carenet.refreshToken': 'second-refresh',
  'carenet.tokenType': 'Bearer',
  'carenet.expiresIn': '900',
  'carenet.user.id': 'third-account',
  'carenet.user.email': 'third@example.test',
  'carenet.user.role': 'PATIENT',
  'carenet.user.status': 'ACTIVE',
  'carenet.user.emailVerified': 'true',
};

enum _WriteFault { before, partial, after }

// Shared persisted bytes outlive each store; faults model plugin boundaries only.
class _FaultStorage extends FlutterSecureStorage {
  final values = <String, String>{};
  final readKeys = <String>[];
  _WriteFault? writeFault;
  String? failDeleteKey;

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
    readKeys.add(key);
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
    if (writeFault == _WriteFault.before) {
      throw StateError('Injected write failure');
    }
    if (value == null) {
      values.remove(key);
    } else {
      values[key] =
          writeFault == _WriteFault.partial
              ? value.substring(0, value.length ~/ 2)
              : value;
    }
    if (writeFault != null) throw StateError('Injected write failure');
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
    if (key == failDeleteKey) throw StateError('Injected delete failure');
    values.remove(key);
  }
}
