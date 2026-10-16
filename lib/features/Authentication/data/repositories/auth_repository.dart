import 'dart:async';

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
    Duration authCallerTimeout = const Duration(seconds: 60),
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore,
       _notificationLifecycle = notificationLifecycle,
       _authCallerTimeout = authCallerTimeout,
       _refreshCoordinator =
           refreshCoordinator ??
           SessionRefreshCoordinator(
             apiClient: apiClient,
             sessionStore: sessionStore,
           ) {
    if (authCallerTimeout <= Duration.zero) {
      throw ArgumentError.value(authCallerTimeout, 'authCallerTimeout');
    }
    _refreshCoordinator.onAuthenticated = _notifyAuthenticated;
    _refreshCoordinator.onClearing = _notifyBeforeClear;
  }

  final AuthApiClient _apiClient;
  final SessionStore _sessionStore;
  final NotificationSessionLifecycle? _notificationLifecycle;
  final SessionRefreshCoordinator _refreshCoordinator;
  final Duration _authCallerTimeout;
  _AuthAttempt? _currentAttempt;

  Future<AuthSession> register({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic> profile = const <String, dynamic>{},
  }) => _authenticate(
    () => _apiClient.register(
      email: email,
      password: password,
      role: role,
      profile: profile,
    ),
  );

  Future<AuthSession> login({
    required String email,
    required String password,
  }) => _authenticate(() => _apiClient.login(email: email, password: password));

  Future<AuthSession> _authenticate(
    Future<AuthSessionModel> Function() request,
  ) {
    final attempt = _AuthAttempt();
    _currentAttempt = attempt;
    return _completeAuthentication(attempt, request).timeout(
      _authCallerTimeout,
      onTimeout: () {
        if (identical(_currentAttempt, attempt)) _currentAttempt = null;
        // The real operation retains store-queue ownership until it settles.
        unawaited(
          _cleanupAttempt(
            attempt,
          ).then<void>((_) {}, onError: (Object _, StackTrace __) {}),
        );
        throw _storageFailure;
      },
    );
  }

  Future<AuthSession> _completeAuthentication(
    _AuthAttempt attempt,
    Future<AuthSessionModel> Function() request,
  ) async {
    bool isCurrent() => identical(_currentAttempt, attempt);
    try {
      final session = await request();
      if (!isCurrent()) throw _supersededFailure;
      attempt.snapshot = await _sessionStore.saveIfOwned(session, isCurrent);
      if (attempt.snapshot == null || !isCurrent()) throw _supersededFailure;
      await _notifyAuthenticated(session);
      if (!isCurrent()) throw _supersededFailure;
      return session;
    } catch (error) {
      await _cleanupAttempt(attempt);
      if (error is AuthFailure) rethrow;
      throw _storageFailure;
    }
  }

  Future<void> _cleanupAttempt(_AuthAttempt attempt) {
    final snapshot = attempt.snapshot;
    if (snapshot == null) return Future<void>.value();
    return attempt.cleanup ??=
        (() async {
          try {
            await _sessionStore.clearSnapshotIfCurrent(snapshot);
          } catch (_) {
            throw _storageFailure;
          }
        })();
  }

  static const _supersededFailure = AuthFailure(
    type: AuthFailureType.unknown,
    message: 'Your sign-in attempt changed. Please try again.',
  );

  static const _storageFailure = AuthFailure(
    type: AuthFailureType.network,
    message: 'Could not finish authentication. Please try again.',
  );

  Future<AuthSession?> restore() {
    return _sessionStore.read();
  }

  Future<AuthSession> refresh() => _refreshCoordinator.refresh();

  Future<void> logout() {
    _currentAttempt = null;
    return _boundExitWait(_logout());
  }

  // Bound only the caller: cleanup keeps its original queue and snapshot guards.
  Future<void> _boundExitWait(Future<void> work) =>
      work.timeout(_authCallerTimeout, onTimeout: () => throw _storageFailure);

  Future<void> _logout() async {
    try {
      final snapshot = await _sessionStore.capture();
      final current = snapshot?.session;
      try {
        if (current != null) {
          await _notifyBeforeClear(current);
          await _apiClient.logout(refreshToken: current.refreshToken);
        }
      } finally {
        if (snapshot != null) {
          await _sessionStore.clearSnapshotIfCurrent(snapshot);
        }
      }
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw _storageFailure;
    }
  }

  Future<void> requestPasswordReset({required String email}) {
    return _apiClient.requestPasswordReset(email: email);
  }

  Future<void> confirmPasswordReset({
    required String token,
    required String password,
  }) {
    _currentAttempt = null;
    return _boundExitWait(
      _confirmPasswordReset(token: token, password: password),
    );
  }

  Future<void> _confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    try {
      final snapshot = await _sessionStore.capture();
      await _apiClient.confirmPasswordReset(token: token, password: password);
      if (snapshot != null &&
          await _sessionStore.clearSnapshotIfCurrent(snapshot)) {
        await _notifyBeforeClear(snapshot.session);
      }
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw _storageFailure;
    }
  }

  Future<AuthSession> googleSignIn({required String idToken, String? role}) =>
      _authenticate(
        () => _apiClient.googleSignIn(idToken: idToken, role: role),
      );

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

class _AuthAttempt {
  SessionSnapshot? snapshot;
  Future<void>? cleanup;
}
