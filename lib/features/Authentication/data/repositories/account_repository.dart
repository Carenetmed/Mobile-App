import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_session_model.dart';
import '../services/auth_api_client.dart';
import '../storage/session_store.dart';

class AccountRepository {
  const AccountRepository({
    required AuthApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final AuthApiClient _apiClient;
  final SessionStore _sessionStore;

  Future<AuthUser> currentAccount() async {
    final current = await _requireSession();
    try {
      return await _apiClient.me(accessToken: current.accessToken);
    } on AuthFailure catch (failure) {
      if (failure.shouldClearSession) {
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
