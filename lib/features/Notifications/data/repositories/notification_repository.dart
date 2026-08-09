import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';

import '../../domain/entities/notification_models.dart';
import '../services/notification_api_client.dart';

class NotificationRepository {
  const NotificationRepository({
    required NotificationApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final NotificationApiClient _apiClient;
  final SessionStore _sessionStore;

  Future<NotificationPage> notifications({
    String? cursor,
    NotificationCategory? category,
    String? read,
    int limit = 30,
  }) async {
    final session = await requireSession();
    return _apiClient.notifications(
      accessToken: session.accessToken,
      cursor: cursor,
      category: category,
      read: read,
      limit: limit,
    );
  }

  Future<CareNotification> notification(String id) async {
    final session = await requireSession();
    return _apiClient.notification(
      accessToken: session.accessToken,
      notificationId: id,
    );
  }

  Future<int> unreadCount() async {
    final session = await requireSession();
    return _apiClient.unreadCount(accessToken: session.accessToken);
  }

  Future<DateTime> markRead(String id) async {
    final session = await requireSession();
    return _apiClient.markRead(
      accessToken: session.accessToken,
      notificationId: id,
    );
  }

  Future<int> markAllRead() async {
    final session = await requireSession();
    return _apiClient.markAllRead(accessToken: session.accessToken);
  }

  Future<List<NotificationPreference>> preferences() async {
    final session = await requireSession();
    return _apiClient.preferences(accessToken: session.accessToken);
  }

  Future<List<NotificationPreference>> updatePreferences(
    List<NotificationPreference> preferences,
  ) async {
    final session = await requireSession();
    return _apiClient.updatePreferences(
      accessToken: session.accessToken,
      preferences: preferences,
    );
  }

  Future<void> registerInstallation({
    required AuthSessionModel session,
    required Map<String, dynamic> payload,
  }) {
    return _apiClient.registerInstallation(
      accessToken: session.accessToken,
      payload: payload,
    );
  }

  Future<void> removeInstallation({
    required AuthSessionModel session,
    required String installationId,
  }) {
    return _apiClient.removeInstallation(
      accessToken: session.accessToken,
      installationId: installationId,
    );
  }

  Future<AuthSessionModel> requireSession() async {
    final session = await _sessionStore.read();
    if (session == null || session.user.id.trim().isEmpty) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }
    return session;
  }
}
