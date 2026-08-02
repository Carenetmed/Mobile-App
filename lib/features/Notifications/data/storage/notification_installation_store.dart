import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

abstract class NotificationInstallationStore {
  Future<String> installationId();
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
  static const _boundUserIdKey = 'carenet.notifications.boundUserId';
  static const _pendingNotificationIdKey =
      'carenet.notifications.pendingNotificationId';

  final FlutterSecureStorage _storage;
  final Uuid _uuid;

  @override
  Future<String> installationId() async {
    final current = await _storage.read(key: _installationIdKey);
    if (current != null && current.trim().length >= 32) return current.trim();
    final created = _uuid.v4().replaceAll('-', '');
    await _storage.write(key: _installationIdKey, value: created);
    return created;
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
