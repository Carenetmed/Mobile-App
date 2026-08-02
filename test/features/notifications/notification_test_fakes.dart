import 'dart:async';

import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Notifications/data/repositories/notification_repository.dart';
import 'package:app_t/features/Notifications/data/services/firebase_notification_transport.dart';
import 'package:app_t/features/Notifications/data/storage/notification_installation_store.dart';
import 'package:app_t/features/Notifications/domain/entities/notification_models.dart';

AuthSessionModel notificationTestSession({
  String userId = 'user-1',
  String role = 'PATIENT',
}) {
  return AuthSessionModel.fromJson(<String, dynamic>{
    'accessToken': 'access-$userId',
    'refreshToken': 'refresh-$userId',
    'tokenType': 'Bearer',
    'expiresIn': 900,
    'user': <String, dynamic>{
      'id': userId,
      'email': '$userId@example.com',
      'role': role,
      'status': 'ACTIVE',
      'emailVerified': true,
    },
  });
}

CareNotification notificationTestItem({
  String id = 'notification-1',
  String? routeCode = 'APPOINTMENT_DETAIL',
  String? entityId = 'appointment-1',
  DateTime? readAt,
  String title = 'Appointment update',
}) {
  return CareNotification(
    id: id,
    category: NotificationCategory.appointments,
    priority: 'NORMAL',
    title: title,
    body: 'Open CareNet to view the latest appointment status.',
    routeCode: routeCode,
    entityId: entityId,
    occurrenceCount: 1,
    firstOccurredAt: DateTime.utc(2026, 8, 2, 8),
    latestOccurredAt: DateTime.utc(2026, 8, 2, 8),
    readAt: readAt,
  );
}

class InMemoryNotificationSessionStore implements SessionStore {
  InMemoryNotificationSessionStore([this.session]);

  AuthSessionModel? session;

  @override
  Future<void> clear() async => session = null;

  @override
  Future<AuthSessionModel?> read() async => session;

  @override
  Future<void> save(AuthSessionModel value) async => session = value;
}

class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({
    AuthSessionModel? session,
    List<CareNotification>? items,
  }) : session = session ?? notificationTestSession(),
       items = items ?? <CareNotification>[];

  AuthSessionModel session;
  List<CareNotification> items;
  Object? listFailure;
  Object? notificationFailure;
  Object? preferencesFailure;
  Completer<NotificationPage>? listCompleter;
  int unread = 0;
  int listCalls = 0;
  int unreadCalls = 0;
  int markAllCalls = 0;
  final List<String> markedRead = <String>[];
  final List<Map<String, dynamic>> registrationPayloads =
      <Map<String, dynamic>>[];
  final List<String> removedInstallations = <String>[];
  final Map<String, CareNotification> notificationsById =
      <String, CareNotification>{};
  List<NotificationPreference> preferenceValues = NotificationCategory.values
      .map(
        (category) => NotificationPreference(
          category: category,
          pushEnabled: true,
          emailEnabled: true,
        ),
      )
      .toList(growable: false);

  @override
  Future<NotificationPage> notifications({
    String? cursor,
    NotificationCategory? category,
    String? read,
    int limit = 30,
  }) async {
    listCalls++;
    if (listFailure case final failure?) throw failure;
    final pending = listCompleter;
    if (pending != null) return pending.future;
    return NotificationPage(items: items, hasMore: false);
  }

  @override
  Future<CareNotification> notification(String id) async {
    if (notificationFailure case final failure?) throw failure;
    final item =
        notificationsById[id] ??
        items.where((candidate) => candidate.id == id).firstOrNull;
    if (item == null) throw StateError('Notification unavailable.');
    return item;
  }

  @override
  Future<int> unreadCount() async {
    unreadCalls++;
    return unread;
  }

  @override
  Future<DateTime> markRead(String id) async {
    markedRead.add(id);
    return DateTime.utc(2026, 8, 2, 9);
  }

  @override
  Future<int> markAllRead() async {
    markAllCalls++;
    return items.where((item) => !item.isRead).length;
  }

  @override
  Future<List<NotificationPreference>> preferences() async {
    if (preferencesFailure case final failure?) throw failure;
    return preferenceValues;
  }

  @override
  Future<List<NotificationPreference>> updatePreferences(
    List<NotificationPreference> preferences,
  ) async {
    if (preferencesFailure case final failure?) throw failure;
    preferenceValues = List<NotificationPreference>.of(preferences);
    return preferenceValues;
  }

  @override
  Future<void> registerInstallation({
    required AuthSessionModel session,
    required Map<String, dynamic> payload,
  }) async {
    registrationPayloads.add(Map<String, dynamic>.of(payload));
  }

  @override
  Future<void> removeInstallation({
    required AuthSessionModel session,
    required String installationId,
  }) async {
    removedInstallations.add(installationId);
  }

  @override
  Future<AuthSessionModel> requireSession() async => session;
}

class FakeNotificationInstallationStore
    implements NotificationInstallationStore {
  String id = 'installation-000000000000000000000001';
  String? boundUser;
  String? pendingNotification;

  @override
  Future<void> bindUser(String userId) async => boundUser = userId;

  @override
  Future<String?> boundUserId() async => boundUser;

  @override
  Future<void> clearBinding() async => boundUser = null;

  @override
  Future<void> clearPendingNotificationId() async {
    pendingNotification = null;
  }

  @override
  Future<String> installationId() async => id;

  @override
  Future<String?> pendingNotificationId() async => pendingNotification;

  @override
  Future<void> savePendingNotificationId(String notificationId) async {
    pendingNotification = notificationId;
  }
}

class FakeNotificationTransport implements NotificationTransport {
  FakeNotificationTransport({
    this.configured = true,
    this.permissionValue = NotificationPermissionValue.notDetermined,
    this.token = 'fcm-token',
  });

  final bool configured;
  NotificationPermissionValue permissionValue;
  String? token;
  Future<void> Function()? foregroundCallback;
  Future<void> Function()? tokenCallback;
  NotificationTapCallback? tapCallback;
  int initializeCalls = 0;
  int permissionRequests = 0;
  int settingsRequests = 0;

  @override
  bool get isConfigured => configured;

  @override
  Future<String?> endpoint() async => token;

  @override
  Future<void> initialize({
    required Future<void> Function() onForegroundMessage,
    required NotificationTapCallback onTap,
    required Future<void> Function() onTokenRefresh,
  }) async {
    initializeCalls++;
    foregroundCallback = onForegroundMessage;
    tapCallback = onTap;
    tokenCallback = onTokenRefresh;
  }

  @override
  Future<NotificationPermissionValue> permission() async => permissionValue;

  @override
  Future<NotificationPermissionValue> requestPermission() async {
    permissionRequests++;
    permissionValue = NotificationPermissionValue.authorized;
    return permissionValue;
  }

  @override
  Future<bool> openSettings() async {
    settingsRequests++;
    return true;
  }
}
