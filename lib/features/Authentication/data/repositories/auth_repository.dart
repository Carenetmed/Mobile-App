import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_session.dart';
import '../models/auth_session_model.dart';
import '../services/auth_api_client.dart';
import '../services/session_refresh_coordinator.dart';
import '../storage/session_store.dart';
import '../../../Notifications/domain/services/notification_session_lifecycle.dart';

class AuthRepository {
  AuthRepository({
    required AuthApiClient apiClient,
    required SessionStore sessionStore,
    NotificationSessionLifecycle? notificationLifecycle,
    SessionRefreshCoordinator? refreshCoordinator,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore,
       _notificationLifecycle = notificationLifecycle,
       _refreshCoordinator =
           refreshCoordinator ??
           SessionRefreshCoordinator(
             apiClient: apiClient,
             sessionStore: sessionStore,
           ) {
    _refreshCoordinator.onAuthenticated = _notifyAuthenticated;
    _refreshCoordinator.onClearing = _notifyBeforeClear;
  }

  final AuthApiClient _apiClient;
  final SessionStore _sessionStore;
  final NotificationSessionLifecycle? _notificationLifecycle;
  final SessionRefreshCoordinator _refreshCoordinator;

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
    await _notifyAuthenticated(session);
    return session;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _apiClient.login(email: email, password: password);
    await _sessionStore.save(session);
    await _notifyAuthenticated(session);
    return session;
  }

  Future<AuthSession?> restore() {
    return _sessionStore.read();
  }

  Future<AuthSession> refresh() => _refreshCoordinator.refresh();

  Future<void> logout() async {
    final current = await _sessionStore.read();
    try {
      if (current != null) {
        await _notifyBeforeClear(current);
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
    final current = await _sessionStore.read();
    if (current != null) await _notifyBeforeClear(current);
    await _sessionStore.clear();
  }

  Future<AuthSession> googleSignIn({
    required String idToken,
    String? role,
  }) async {
    final session = await _apiClient.googleSignIn(idToken: idToken, role: role);
    await _sessionStore.save(session);
    await _notifyAuthenticated(session);
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

  Future<void> _notifyAuthenticated(AuthSessionModel session) async {
    try {
      await _notificationLifecycle?.onAuthenticatedSession(session);
    } catch (_) {
      // Notification setup must never invalidate a successful auth session.
    }
  }

  Future<void> _notifyBeforeClear(AuthSessionModel session) async {
    try {
      await _notificationLifecycle?.beforeLogout(session);
    } catch (_) {
      // Session cleanup remains authoritative when notification cleanup fails.
    }
  }
}
