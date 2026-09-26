import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';

abstract class NotificationSessionLifecycle {
  Future<void> onAuthenticatedSession(AuthSessionModel session);
  Future<void> beforeLogout(AuthSessionModel session);
  Future<void> afterAccountDeletion(AuthSessionModel session);
}
