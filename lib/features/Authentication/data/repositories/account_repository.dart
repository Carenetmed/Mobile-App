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
      final account = await _apiClient.me(accessToken: current.accessToken);
      final latest = await _sessionStore.read();
      if (latest?.user.id != current.user.id || account.id != current.user.id) {
        throw const AuthFailure(
          type: AuthFailureType.unknown,
          message: 'Your account changed. Please try again.',
        );
      }
      return account;
    } on AuthFailure catch (failure) {
      if (failure.shouldClearSession &&
          await _sessionStore.clearIfCurrent(current)) {
        try {
          await _notificationLifecycle?.beforeLogout(current);
        } catch (_) {
          // Session invalidation remains authoritative if cleanup is unavailable.
        }
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
    final snapshot = await _sessionStore.capture();
    if (snapshot == null ||
        snapshot.session.user.id != current.user.id ||
        snapshot.session.refreshToken != current.refreshToken) {
      throw const AuthFailure(
        type: AuthFailureType.unknown,
        message: 'Your account changed. Please try again.',
      );
    }
    final receipt = await _apiClient.requestAccountDeletion(
      accessToken: current.accessToken,
      password: password,
      googleIdToken: googleIdToken,
    );
    if (await _sessionStore.clearSnapshotIfCurrent(snapshot)) {
      try {
        await _notificationLifecycle?.afterAccountDeletion(current);
      } catch (_) {
        // Session removal remains authoritative if local cleanup fails.
      }
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
