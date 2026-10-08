import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

abstract class NotificationInstallationStore {
  Future<String> installationId();
  Future<String> nextBindingGeneration();
  Future<String?> boundUserId();
  Future<void> bindUser(String userId);
  Future<void> clearBinding();
  Future<void> savePendingNotificationId(String notificationId);
  Future<String?> pendingNotificationId();
  Future<void> clearPendingNotificationId();
}

class SecureNotificationInstallationStore
    implements NotificationInstallationStore {
  SecureNotificationInstallationStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    Uuid uuid = const Uuid(),
  }) : _storage = storage,
       _uuid = uuid;

  static const _installationIdKey = 'carenet.notifications.installationId';
  static const _bindingGenerationKey =
      'carenet.notifications.bindingGeneration';
  static const _boundUserIdKey = 'carenet.notifications.boundUserId';
  static const _pendingNotificationIdKey =
      'carenet.notifications.pendingNotificationId';

  final FlutterSecureStorage _storage;
  final Uuid _uuid;
  Future<void> _bindingGenerationWrite = Future<void>.value();

  @override
  Future<String> installationId() async {
    final current = await _storage.read(key: _installationIdKey);
    if (current != null && current.trim().length >= 32) return current.trim();
    final created = _uuid.v4().replaceAll('-', '');
    await _storage.write(key: _bindingGenerationKey, value: '0');
    await _storage.write(key: _installationIdKey, value: created);
    return created;
  }

  @override
  Future<String> nextBindingGeneration() {
    final result = _bindingGenerationWrite.then((_) async {
      final stored = await _storage.read(key: _bindingGenerationKey);
      final current =
          stored == null ? BigInt.zero : BigInt.tryParse(stored.trim());
      final maximum = BigInt.parse('9223372036854775806');
      if (current == null || current.isNegative || current >= maximum) {
        throw const FormatException('Invalid notification binding generation.');
      }
      final next = (current + BigInt.one).toString();
      await _storage.write(key: _bindingGenerationKey, value: next);
      return next;
    });
    _bindingGenerationWrite = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return result;
  }

  @override
  Future<String?> boundUserId() => _storage.read(key: _boundUserIdKey);

  @override
  Future<void> bindUser(String userId) {
    return _storage.write(key: _boundUserIdKey, value: userId.trim());
  }

  @override
  Future<void> clearBinding() => _storage.delete(key: _boundUserIdKey);

  @override
  Future<void> savePendingNotificationId(String notificationId) {
    return _storage.write(
      key: _pendingNotificationIdKey,
      value: notificationId.trim(),
    );
  }

  @override
  Future<String?> pendingNotificationId() {
    return _storage.read(key: _pendingNotificationIdKey);
  }

  @override
  Future<void> clearPendingNotificationId() {
    return _storage.delete(key: _pendingNotificationIdKey);
  }
}
