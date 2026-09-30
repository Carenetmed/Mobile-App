import '../../domain/entities/auth_failure.dart';
import 'package:dio/dio.dart';
import '../models/auth_session_model.dart';
import '../storage/session_store.dart';
import 'auth_api_client.dart';

typedef SessionAuthenticatedCallback =
    Future<void> Function(AuthSessionModel session);
typedef SessionClearingCallback =
    Future<void> Function(AuthSessionModel session);

class SessionRefreshCoordinator {
  SessionRefreshCoordinator({
    required AuthApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final AuthApiClient _apiClient;
  final SessionStore _sessionStore;
  Future<AuthSessionModel>? _refreshing;
  SessionAuthenticatedCallback? onAuthenticated;
  SessionClearingCallback? onClearing;

  Future<AuthSessionModel> refresh() {
    final active = _refreshing;
    if (active != null) return active;

    final future = _refresh();
    _refreshing = future;
    return future.whenComplete(() {
      if (identical(_refreshing, future)) _refreshing = null;
    });
  }

  Future<AuthSessionModel> _refresh() async {
    final current = await _sessionStore.read();
    if (current == null) throw _signedOutFailure;

    try {
      final session = await _apiClient.refresh(
        refreshToken: current.refreshToken,
      );
      if (session.user.id != current.user.id ||
          !await _sessionStore.replaceIfCurrent(current, session)) {
        throw _signedOutFailure;
      }
      await _notifyAuthenticated(session);
      return session;
    } on AuthFailure catch (failure) {
      if (failure.shouldClearSession) {
        if (await _sessionStore.clearIfCurrent(current)) {
          await _notifyClearing(current);
        }
      }
      rethrow;
    }
  }

  Future<AuthSessionModel> requireSession() async {
    final current = await _sessionStore.read();
    if (current == null) throw _signedOutFailure;
    return current;
  }

  Future<T> execute<T>(Future<T> Function(String accessToken) request) async {
    final current = await requireSession();
    try {
      return await request(current.accessToken);
    } on AuthFailure catch (failure) {
      if (failure.statusCode != 401) rethrow;
      final refreshed = await refresh();
      return request(refreshed.accessToken);
    }
  }

  Future<void> _notifyAuthenticated(AuthSessionModel session) async {
    try {
      await onAuthenticated?.call(session);
    } catch (_) {
      // Optional notification registration cannot invalidate authentication.
    }
  }

  Future<void> _notifyClearing(AuthSessionModel session) async {
    try {
      await onClearing?.call(session);
    } catch (_) {
      // Session cleanup remains authoritative when provider cleanup fails.
    }
  }

  static const AuthFailure _signedOutFailure = AuthFailure(
    type: AuthFailureType.unauthorized,
    message: 'Please sign in again.',
    statusCode: 401,
  );
}

class SessionRefreshInterceptor extends Interceptor {
  SessionRefreshInterceptor({
    required Dio dio,
    required SessionRefreshCoordinator coordinator,
  }) : _dio = dio,
       _coordinator = coordinator;

  static const String _retriedKey = 'carenet.sessionRefreshRetried';
  final Dio _dio;
  final SessionRefreshCoordinator _coordinator;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final authorization = request.headers['Authorization'];
    if (err.response?.statusCode != 401 ||
        authorization is! String ||
        authorization.trim().isEmpty ||
        request.extra[_retriedKey] == true) {
      handler.next(err);
      return;
    }

    try {
      final session = await _coordinator.refresh();
      request.headers['Authorization'] = 'Bearer ${session.accessToken}';
      request.extra[_retriedKey] = true;
      handler.resolve(await _dio.fetch<dynamic>(request));
    } catch (_) {
      handler.next(err);
    }
  }
}
