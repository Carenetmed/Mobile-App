import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session_model.dart';

abstract class SessionStore {
  Future<void> save(AuthSessionModel session);

  Future<AuthSessionModel?> read();

  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  const SecureSessionStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

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

  @override
  Future<void> save(AuthSessionModel session) async {
    // Encrypted Android preferences are a shared persistent store. Complete the
    // session as one ordered write sequence before a protected route rereads it.
    await _storage.write(key: _accessTokenKey, value: session.accessToken);
    await _storage.write(key: _refreshTokenKey, value: session.refreshToken);
    await _storage.write(key: _tokenTypeKey, value: session.tokenType);
    await _storage.write(
      key: _expiresInKey,
      value: session.expiresIn.toString(),
    );
    await _storage.write(key: _userIdKey, value: session.user.id);
    await _storage.write(key: _userEmailKey, value: session.user.email);
    await _storage.write(key: _userRoleKey, value: session.user.role);
    await _storage.write(key: _userStatusKey, value: session.user.status);
    await _storage.write(
      key: _userEmailVerifiedKey,
      value: session.user.emailVerified.toString(),
    );
  }

  @override
  Future<AuthSessionModel?> read() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (accessToken == null || refreshToken == null) {
      return null;
    }

    final expiresInText = await _storage.read(key: _expiresInKey);
    return AuthSessionModel.fromJson(<String, dynamic>{
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
  }

  @override
  Future<void> clear() async {
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
}
