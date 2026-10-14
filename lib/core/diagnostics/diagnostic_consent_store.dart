import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class DiagnosticConsentStore {
  Future<bool> isEnabledFor(String sessionGeneration);
  Future<void> enableFor(String sessionGeneration);
  Future<void> disableFor(String sessionGeneration);
}

class SecureDiagnosticConsentStore implements DiagnosticConsentStore {
  SecureDiagnosticConsentStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const key = 'carenet.diagnostics.consent.v1';
  final FlutterSecureStorage _storage;
  Future<void> _pending = Future<void>.value();

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  static bool _validGeneration(String value) =>
      value.isNotEmpty &&
      value.length <= 128 &&
      RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value);

  static String? _generation(String? encoded) {
    if (encoded == null) return null;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic> ||
          decoded.length != 2 ||
          decoded['schemaVersion'] is! int ||
          decoded['schemaVersion'] != 1) {
        return null;
      }
      final value = decoded['sessionGeneration'];
      return value is String && _validGeneration(value) ? value : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isEnabledFor(String sessionGeneration) => _serialize(() async {
    if (!_validGeneration(sessionGeneration)) return false;
    return _generation(await _storage.read(key: key)) == sessionGeneration;
  });

  @override
  Future<void> enableFor(String sessionGeneration) => _serialize(() async {
    if (!_validGeneration(sessionGeneration)) {
      throw const FormatException('Invalid diagnostic session binding.');
    }
    await _storage.write(
      key: key,
      value: jsonEncode({
        'schemaVersion': 1,
        'sessionGeneration': sessionGeneration,
      }),
    );
  });

  @override
  Future<void> disableFor(String sessionGeneration) => _serialize(() async {
    final encoded = await _storage.read(key: key);
    final current = _generation(encoded);
    // A late logout/settings operation must not revoke a different session's grant.
    if (current == null || current == sessionGeneration) {
      await _storage.delete(key: key);
    }
  });
}
