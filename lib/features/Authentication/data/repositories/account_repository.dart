import '../../domain/entities/account_deletion_receipt.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_session_model.dart';
import '../services/auth_api_client.dart';
import '../storage/session_store.dart';
import '../../../Notifications/domain/services/notification_session_lifecycle.dart';

class AccountRepository {
  AccountRepository({
    required AuthApiClient apiClient,
    required SessionStore sessionStore,
    NotificationSessionLifecycle? notificationLifecycle,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore,
       _notificationLifecycle = notificationLifecycle;

  final AuthApiClient _apiClient;
  final SessionStore _sessionStore;
  final NotificationSessionLifecycle? _notificationLifecycle;

  Future<AuthUser> currentAccount() async {
    final current = await _requireSession();
    try {
      return await _apiClient.me(accessToken: current.accessToken);
    } on AuthFailure catch (failure) {
      if (failure.shouldClearSession) {
        try {
          await _notificationLifecycle?.beforeLogout(current);
        } catch (_) {
          // Session invalidation remains authoritative if cleanup is unavailable.
        }
        await _sessionStore.clear();
      }
      rethrow;
    }
  }

  Future<void> requestEmailVerification() async {
    final current = await _requireSession();
    return _apiClient.requestEmailVerification(
      accessToken: current.accessToken,
    );
  }

  Future<void> confirmEmailVerification({required String token}) {
    return _apiClient.confirmEmailVerification(token: token);
  }

  Future<AccountDeletionReceipt> requestAccountDeletion({
    String? password,
    String? googleIdToken,
  }) async {
    final current = await _requireSession();
    final receipt = await _apiClient.requestAccountDeletion(
      accessToken: current.accessToken,
      password: password,
      googleIdToken: googleIdToken,
    );
    try {
      await _notificationLifecycle?.afterAccountDeletion(current);
    } catch (_) {
      // Session removal remains authoritative if local cleanup fails.
    } finally {
      await _sessionStore.clear();
    }
    return receipt;
  }

  Future<AuthSessionModel> _requireSession() async {
    final current = await _sessionStore.read();
    if (current == null) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
      );
    }
    return current;
  }
}
