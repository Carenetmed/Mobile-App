import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_session.dart';
import '../models/auth_session_model.dart';
import '../services/auth_api_client.dart';
import '../storage/session_store.dart';

class AuthRepository {
  const AuthRepository({
    required AuthApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final AuthApiClient _apiClient;
  final SessionStore _sessionStore;

  Future<AuthSession> register({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic> profile = const <String, dynamic>{},
  }) async {
    final session = await _apiClient.register(
      email: email,
      password: password,
      role: role,
      profile: profile,
    );
    await _sessionStore.save(session);
    return session;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _apiClient.login(email: email, password: password);
    await _sessionStore.save(session);
    return session;
  }

  Future<AuthSession?> restore() {
    return _sessionStore.read();
  }

  Future<AuthSession> refresh() async {
    final current = await _sessionStore.read();
    if (current == null) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
      );
    }

    try {
      final session = await _apiClient.refresh(
        refreshToken: current.refreshToken,
      );
      await _sessionStore.save(session);
      return session;
    } on AuthFailure catch (failure) {
      if (failure.shouldClearSession) {
        await _sessionStore.clear();
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    final current = await _sessionStore.read();
    try {
      if (current != null) {
        await _apiClient.logout(refreshToken: current.refreshToken);
      }
    } finally {
      await _sessionStore.clear();
    }
  }

  Future<void> requestPasswordReset({required String email}) {
    return _apiClient.requestPasswordReset(email: email);
  }

  Future<void> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    await _apiClient.confirmPasswordReset(token: token, password: password);
    await _sessionStore.clear();
  }

  Future<AuthSession> googleSignIn({
    required String idToken,
    String? role,
  }) async {
    final session = await _apiClient.googleSignIn(idToken: idToken, role: role);
    await _sessionStore.save(session);
    return session;
  }

  Future<void> googleLink({required String idToken}) async {
    final current = await _requireSession();
    return _apiClient.googleLink(
      accessToken: current.accessToken,
      idToken: idToken,
    );
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
