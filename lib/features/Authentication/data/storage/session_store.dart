import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session_model.dart';

abstract class SessionStore {
  Future<void> save(AuthSessionModel session);

  Future<AuthSessionModel?> read();

  Future<void> clear();

  Future<bool> replaceIfCurrent(
    AuthSessionModel expected,
    AuthSessionModel replacement,
  );

  Future<bool> clearIfCurrent(AuthSessionModel expected);
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const String _sessionKey = 'carenet.session.v1';
  static const int _schemaVersion = 1;
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
  Future<void> _pending = Future<void>.value();

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  @override
  Future<void> save(AuthSessionModel session) =>
      _serialize(() => _saveUnlocked(session));

  Future<void> _saveUnlocked(AuthSessionModel session) async {
    _validate(session);
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode(<String, dynamic>{
        'schemaVersion': _schemaVersion,
        'session': session.toJson(),
      }),
    );
    await _clearLegacy();
  }

  @override
  Future<AuthSessionModel?> read() => _serialize(_readUnlocked);

  Future<AuthSessionModel?> _readUnlocked() async {
    final encoded = await _storage.read(key: _sessionKey);
    if (encoded != null) {
      try {
        final decoded = jsonDecode(encoded);
        if (decoded is! Map<String, dynamic> ||
            decoded['schemaVersion'] != _schemaVersion ||
            decoded['session'] is! Map<String, dynamic>) {
          await _clearUnlocked();
          return null;
        }
        final session = AuthSessionModel.fromJson(
          decoded['session'] as Map<String, dynamic>,
        );
        _validate(session);
        return session;
      } catch (_) {
        await _clearUnlocked();
        return null;
      }
    }

    final legacy = await _readLegacy();
    if (legacy == null) return null;
    await _saveUnlocked(legacy);
    return legacy;
  }

  Future<AuthSessionModel?> _readLegacy() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (accessToken == null || refreshToken == null) {
      await _clearLegacy();
      return null;
    }

    final expiresInText = await _storage.read(key: _expiresInKey);
    final session = AuthSessionModel.fromJson(<String, dynamic>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': await _storage.read(key: _tokenTypeKey) ?? 'Bearer',
      'expiresIn': int.tryParse(expiresInText ?? '') ?? 0,
      'user': <String, dynamic>{
        'id': await _storage.read(key: _userIdKey) ?? '',
        'email': await _storage.read(key: _userEmailKey) ?? '',
        'role': await _storage.read(key: _userRoleKey) ?? '',
        'status': await _storage.read(key: _userStatusKey) ?? '',
        'emailVerified':
            (await _storage.read(key: _userEmailVerifiedKey)) == 'true',
      },
    });
    try {
      _validate(session);
      return session;
    } catch (_) {
      await _clearLegacy();
      return null;
    }
  }

  @override
  Future<void> clear() => _serialize(_clearUnlocked);

  Future<void> _clearUnlocked() async {
    await _storage.delete(key: _sessionKey);
    await _clearLegacy();
  }

  @override
  Future<bool> replaceIfCurrent(
    AuthSessionModel expected,
    AuthSessionModel replacement,
  ) => _serialize(() async {
    final current = await _readUnlocked();
    if (!_sameSession(current, expected)) return false;
    await _saveUnlocked(replacement);
    return true;
  });

  @override
  Future<bool> clearIfCurrent(AuthSessionModel expected) =>
      _serialize(() async {
        final current = await _readUnlocked();
        if (!_sameSession(current, expected)) return false;
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
}

class InMemorySessionStore implements SessionStore {
  AuthSessionModel? _session;

  @override
  Future<void> save(AuthSessionModel session) async {
    _session = session;
  }

  @override
  Future<AuthSessionModel?> read() async => _session;

  @override
  Future<void> clear() async {
    _session = null;
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
  Future<bool> clearIfCurrent(AuthSessionModel expected) async {
    if (!_sameSession(_session, expected)) return false;
    _session = null;
    return true;
  }
}

bool _sameSession(AuthSessionModel? current, AuthSessionModel expected) =>
    current != null &&
    current.user.id == expected.user.id &&
    current.accessToken == expected.accessToken &&
    current.refreshToken == expected.refreshToken;
