import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session_model.dart';

class SessionSnapshot {
  const SessionSnapshot({required this.session, required this.generation});

  final AuthSessionModel session;
  final String generation;
}

abstract class SessionStore {
  Future<void> save(AuthSessionModel session);

  Future<AuthSessionModel?> read();

  Future<SessionSnapshot?> capture();

  Future<void> clear();

  Future<bool> replaceIfCurrent(
    AuthSessionModel expected,
    AuthSessionModel replacement,
  );

  Future<bool> replaceSnapshotIfCurrent(
    SessionSnapshot expected,
    AuthSessionModel replacement,
  );

  Future<bool> clearIfCurrent(AuthSessionModel expected);

  // Explicit account exit must also clear tokens rotated during that exit.
  Future<bool> clearAccountIfCurrent(String userId);

  Future<bool> clearSnapshotIfCurrent(SessionSnapshot snapshot);
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const String _sessionKey = 'carenet.session.v1';
  static const int _schemaVersion = 2;
  static const String _accessTokenKey = 'carenet.accessToken';
  static const String _refreshTokenKey = 'carenet.refreshToken';
  static const String _tokenTypeKey = 'carenet.tokenType';
  static const String _expiresInKey = 'carenet.expiresIn';
  static const String _userIdKey = 'carenet.user.id';
  static const String _userEmailKey = 'carenet.user.email';
  static const String _userRoleKey = 'carenet.user.role';
  static const String _userStatusKey = 'carenet.user.status';
  static const String _userEmailVerifiedKey = 'carenet.user.emailVerified';

  final FlutterSecureStorage _storage;
  final Random _random = Random.secure();
  Future<void> _pending = Future<void>.value();

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  @override
  Future<void> save(AuthSessionModel session) =>
      _serialize(() => _saveUnlocked(session, _newGeneration()));

  Future<void> _saveUnlocked(
    AuthSessionModel session,
    String generation,
  ) async {
    _validate(session);
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode(<String, dynamic>{
        'schemaVersion': _schemaVersion,
        'generation': generation,
        'session': session.toJson(),
      }),
    );
    await _clearLegacy();
  }

  @override
  Future<AuthSessionModel?> read() => _serialize(() async {
    return (await _readSnapshotUnlocked())?.session;
  });

  @override
  Future<SessionSnapshot?> capture() => _serialize(_readSnapshotUnlocked);

  Future<SessionSnapshot?> _readSnapshotUnlocked() async {
    final encoded = await _storage.read(key: _sessionKey);
    if (encoded != null) {
      dynamic decoded;
      try {
        decoded = jsonDecode(encoded);
      } catch (_) {
        await _clearUnlocked();
        return null;
      }
      if (decoded is Map<String, dynamic> &&
          decoded['schemaVersion'] == _schemaVersion &&
          decoded['cleared'] == true) {
        await _clearLegacy();
        await _storage.delete(key: _sessionKey);
        return null;
      }
      if (decoded is! Map<String, dynamic> ||
          decoded['session'] is! Map<String, dynamic>) {
        await _clearUnlocked();
        return null;
      }
      late final AuthSessionModel session;
      try {
        session = AuthSessionModel.fromJson(
          decoded['session'] as Map<String, dynamic>,
        );
        _validate(session);
      } catch (_) {
        await _clearUnlocked();
        return null;
      }
      final version = decoded['schemaVersion'];
      if (version == 1) {
        final generation = _newGeneration();
        await _saveUnlocked(session, generation);
        return SessionSnapshot(session: session, generation: generation);
      }
      final generation = decoded['generation'];
      if (version != _schemaVersion ||
          generation is! String ||
          generation.trim().isEmpty) {
        await _clearUnlocked();
        return null;
      }
      return SessionSnapshot(session: session, generation: generation);
    }

    // Separate legacy keys cannot prove common account provenance.
    await _clearLegacy();
    return null;
  }

  @override
  Future<void> clear() => _serialize(_clearUnlocked);

  Future<void> _clearUnlocked() async {
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode(<String, dynamic>{
        'schemaVersion': _schemaVersion,
        'cleared': true,
      }),
    );
    await _clearLegacy();
    await _storage.delete(key: _sessionKey);
  }

  @override
  Future<bool> replaceIfCurrent(
    AuthSessionModel expected,
    AuthSessionModel replacement,
  ) => _serialize(() async {
    final snapshot = await _readSnapshotUnlocked();
    if (!_sameSession(snapshot?.session, expected)) return false;
    await _saveUnlocked(replacement, snapshot!.generation);
    return true;
  });

  @override
  Future<bool> replaceSnapshotIfCurrent(
    SessionSnapshot expected,
    AuthSessionModel replacement,
  ) => _serialize(() async {
    final current = await _readSnapshotUnlocked();
    if (!_sameSnapshot(current, expected)) return false;
    await _saveUnlocked(replacement, expected.generation);
    return true;
  });

  @override
  Future<bool> clearIfCurrent(AuthSessionModel expected) =>
      _serialize(() async {
        final snapshot = await _readSnapshotUnlocked();
        if (!_sameSession(snapshot?.session, expected)) return false;
        await _clearUnlocked();
        return true;
      });

  @override
  Future<bool> clearAccountIfCurrent(String userId) => _serialize(() async {
    final snapshot = await _readSnapshotUnlocked();
    if (snapshot == null || snapshot.session.user.id != userId) return false;
    await _clearUnlocked();
    return true;
  });

  @override
  Future<bool> clearSnapshotIfCurrent(SessionSnapshot expected) =>
      _serialize(() async {
        final current = await _readSnapshotUnlocked();
        if (current == null ||
            current.generation != expected.generation ||
            current.session.user.id != expected.session.user.id) {
          return false;
        }
        await _clearUnlocked();
        return true;
      });

  Future<void> _clearLegacy() async {
    await Future.wait(<Future<void>>[
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _tokenTypeKey),
      _storage.delete(key: _expiresInKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _userRoleKey),
      _storage.delete(key: _userStatusKey),
      _storage.delete(key: _userEmailVerifiedKey),
    ]);
  }

  void _validate(AuthSessionModel session) {
    if (session.accessToken.trim().isEmpty ||
        session.refreshToken.trim().isEmpty ||
        session.user.id.trim().isEmpty ||
        session.user.email.trim().isEmpty ||
        session.user.role.trim().isEmpty ||
        session.user.status.trim().isEmpty) {
      throw const FormatException('Incomplete authenticated session.');
    }
  }

  String _newGeneration() =>
      List<int>.generate(
        16,
        (_) => _random.nextInt(256),
      ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

class InMemorySessionStore implements SessionStore {
  AuthSessionModel? _session;
  String? _generation;
  int _generationCounter = 0;

  @override
  Future<void> save(AuthSessionModel session) async {
    _session = session;
    _generation = '${++_generationCounter}';
  }

  @override
  Future<AuthSessionModel?> read() async => _session;

  @override
  Future<SessionSnapshot?> capture() async {
    final session = _session;
    final generation = _generation;
    if (session == null || generation == null) return null;
    return SessionSnapshot(session: session, generation: generation);
  }

  @override
  Future<void> clear() async {
    _session = null;
    _generation = null;
  }

  @override
  Future<bool> replaceIfCurrent(
    AuthSessionModel expected,
    AuthSessionModel replacement,
  ) async {
    if (!_sameSession(_session, expected)) return false;
    _session = replacement;
    return true;
  }

  @override
  Future<bool> replaceSnapshotIfCurrent(
    SessionSnapshot expected,
    AuthSessionModel replacement,
  ) async {
    if (_generation != expected.generation ||
        !_sameSession(_session, expected.session)) {
      return false;
    }
    _session = replacement;
    return true;
  }

  @override
  Future<bool> clearIfCurrent(AuthSessionModel expected) async {
    if (!_sameSession(_session, expected)) return false;
    _session = null;
    _generation = null;
    return true;
  }

  @override
  Future<bool> clearAccountIfCurrent(String userId) async {
    if (_session == null || _session!.user.id != userId) return false;
    _session = null;
    _generation = null;
    return true;
  }

  @override
  Future<bool> clearSnapshotIfCurrent(SessionSnapshot snapshot) async {
    if (_generation != snapshot.generation ||
        _session?.user.id != snapshot.session.user.id) {
      return false;
    }
    _session = null;
    _generation = null;
    return true;
  }
}

bool _sameSession(AuthSessionModel? current, AuthSessionModel expected) =>
    current != null &&
    current.user.id == expected.user.id &&
    current.accessToken == expected.accessToken &&
    current.refreshToken == expected.refreshToken;

bool _sameSnapshot(SessionSnapshot? current, SessionSnapshot expected) =>
    current != null &&
    current.generation == expected.generation &&
    current.session.user.id == expected.session.user.id &&
    _sameSession(current.session, expected.session);
