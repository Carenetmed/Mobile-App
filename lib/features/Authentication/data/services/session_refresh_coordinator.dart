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
  AuthSessionModel? _refreshingSession;
  SessionAuthenticatedCallback? onAuthenticated;
  SessionClearingCallback? onClearing;

  Future<AuthSessionModel> refresh({AuthSessionModel? expected}) async {
    final current = await requireSession();
    if (expected != null) {
      if (current.user.id != expected.user.id) throw _accountChangedFailure;
      if (current.accessToken != expected.accessToken) return current;
    }
    final active = _refreshing;
    if (active != null) {
      final owner = _refreshingSession;
      if (owner?.user.id == current.user.id &&
          owner?.refreshToken == current.refreshToken) {
        return active;
      }
      // A previous session's refresh cannot reject or rotate the new session.
      try {
        final completed = await active;
        final latest = await _sessionStore.read();
        if (completed.user.id == current.user.id &&
            latest?.user.id == completed.user.id &&
            latest?.accessToken == completed.accessToken &&
            latest?.refreshToken == completed.refreshToken) {
          return completed;
        }
      } catch (_) {
        // The current session is validated independently below.
      }
      return refresh(expected: current);
    }

    final future = _refresh(current);
    _refreshing = future;
    _refreshingSession = current;
    return future.whenComplete(() {
      if (identical(_refreshing, future)) {
        _refreshing = null;
        _refreshingSession = null;
      }
    });
  }

  Future<AuthSessionModel> _refresh(AuthSessionModel? expected) async {
    final current = await _sessionStore.read();
    if (current == null) throw _signedOutFailure;
    if (expected != null) {
      if (current.user.id != expected.user.id) throw _accountChangedFailure;
      if (current.accessToken != expected.accessToken) return current;
    }

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
      if (failure.shouldClearSession || failure.statusCode == 403) {
        if (await _sessionStore.clearIfCurrent(current)) {
          await _notifyClearing(current);
        }
        if (failure.statusCode == 403) throw _signedOutFailure;
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
      final result = await request(current.accessToken);
      await _requireRequestAccount(current.user.id);
      return result;
    } on AuthFailure catch (failure) {
      if (failure.statusCode != 401) rethrow;
      final refreshed = await _refreshForRequest(
        current.user.id,
        current.accessToken,
      );
      final result = await request(refreshed.accessToken);
      await _requireRequestAccount(current.user.id);
      return result;
    }
  }

  Future<AuthSessionModel> _requireRequestAccount(String expectedUserId) async {
    final current = await _sessionStore.read();
    if (current == null || current.user.id != expectedUserId) {
      throw _accountChangedFailure;
    }
    return current;
  }

  Future<AuthSessionModel> _refreshForRequest(
    String expectedUserId,
    String expectedAccessToken,
  ) async {
    final current = await _requireRequestAccount(expectedUserId);
    if (current.accessToken != expectedAccessToken) return current;
    await refresh(expected: current);
    return _requireRequestAccount(expectedUserId);
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

  static const AuthFailure _accountChangedFailure = AuthFailure(
    type: AuthFailureType.unknown,
    message: 'Your account changed. Please try again.',
  );
}

class SessionRefreshInterceptor extends Interceptor {
  SessionRefreshInterceptor({
    required Dio dio,
    required SessionRefreshCoordinator coordinator,
  }) : _dio = dio,
       _coordinator = coordinator;

  static const String _retriedKey = 'carenet.sessionRefreshRetried';
  static const String _sessionKey = 'carenet.requestSession';
  final Dio _dio;
  final SessionRefreshCoordinator _coordinator;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final authorization = options.headers['Authorization'];
    if (authorization is! String || authorization.trim().isEmpty) {
      handler.next(options);
      return;
    }
    try {
      final current = await _coordinator.requireSession();
      if (authorization != 'Bearer ${current.accessToken}') {
        throw SessionRefreshCoordinator._accountChangedFailure;
      }
      options.extra[_sessionKey] = current.user.id;
      handler.next(options);
    } on AuthFailure catch (failure) {
      handler.reject(_failure(options, failure));
    }
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final context = response.requestOptions.extra[_sessionKey];
    if (context is! String) {
      handler.next(response);
      return;
    }
    try {
      await _coordinator._requireRequestAccount(context);
      handler.next(response);
    } on AuthFailure catch (failure) {
      handler.reject(_failure(response.requestOptions, failure));
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final authorization = request.headers['Authorization'];
    final context = request.extra[_sessionKey];
    if (err.response?.statusCode != 401 ||
        authorization is! String ||
        authorization.trim().isEmpty ||
        request.extra[_retriedKey] == true ||
        context is! String) {
      handler.next(err);
      return;
    }

    try {
      final session = await _coordinator._refreshForRequest(
        context,
        authorization.substring(7),
      );
      request.headers['Authorization'] = 'Bearer ${session.accessToken}';
      request.extra[_retriedKey] = true;
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on AuthFailure catch (failure) {
      handler.next(_failure(request, failure));
    } on DioException catch (failure) {
      handler.next(failure);
    } catch (_) {
      handler.next(
        _failure(
          request,
          const AuthFailure(
            type: AuthFailureType.network,
            message: 'Could not finish this request. Please try again.',
          ),
        ),
      );
    }
  }

  DioException _failure(RequestOptions request, AuthFailure failure) =>
      DioException(
        requestOptions: request,
        error: failure,
        type:
            failure.type == AuthFailureType.network
                ? DioExceptionType.connectionError
                : DioExceptionType.unknown,
        response:
            failure.statusCode == null
                ? null
                : Response<dynamic>(
                  requestOptions: request,
                  statusCode: failure.statusCode,
                ),
      );
}
