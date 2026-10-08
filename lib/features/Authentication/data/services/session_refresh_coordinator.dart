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
  SessionSnapshot? _refreshingSnapshot;
  SessionAuthenticatedCallback? onAuthenticated;
  SessionClearingCallback? onClearing;

  Future<AuthSessionModel> refresh({
    AuthSessionModel? expected,
    SessionSnapshot? expectedSnapshot,
  }) async {
    final snapshot = await requireSnapshot();
    final current = snapshot.session;
    if (expectedSnapshot != null &&
        !_sameGeneration(snapshot, expectedSnapshot)) {
      throw _accountChangedFailure;
    }
    if (expected != null) {
      if (current.user.id != expected.user.id) throw _accountChangedFailure;
      if (current.accessToken != expected.accessToken) return current;
    }
    final active = _refreshing;
    if (active != null) {
      final owner = _refreshingSnapshot;
      if (owner != null && _sameGeneration(owner, snapshot)) {
        return active;
      }
      // A previous session's refresh cannot reject or rotate the new session.
      try {
        final completed = await active;
        final latest = await _sessionStore.capture();
        if (latest != null &&
            _sameGeneration(latest, snapshot) &&
            latest.session.accessToken == completed.accessToken &&
            latest.session.refreshToken == completed.refreshToken) {
          return completed;
        }
      } catch (_) {
        // The current session is validated independently below.
      }
      return refresh(expected: current, expectedSnapshot: snapshot);
    }

    final future = _refresh(snapshot);
    _refreshing = future;
    _refreshingSnapshot = snapshot;
    return future.whenComplete(() {
      if (identical(_refreshing, future)) {
        _refreshing = null;
        _refreshingSnapshot = null;
      }
    });
  }

  Future<AuthSessionModel> _refresh(SessionSnapshot expected) async {
    final latest = await requireSnapshot();
    if (!_sameGeneration(latest, expected)) throw _accountChangedFailure;
    if (latest.session.accessToken != expected.session.accessToken) {
      return latest.session;
    }
    final current = latest.session;

    try {
      final session = await _apiClient.refresh(
        refreshToken: current.refreshToken,
      );
      if (session.user.id != current.user.id ||
          !await _sessionStore.replaceSnapshotIfCurrent(expected, session)) {
        throw _signedOutFailure;
      }
      await _notifyAuthenticated(session);
      return session;
    } on AuthFailure catch (failure) {
      if (failure.shouldClearSession || failure.statusCode == 403) {
        if (await _sessionStore.clearSnapshotIfCurrent(expected)) {
          await _notifyClearing(current);
        }
        if (failure.statusCode == 403) throw _signedOutFailure;
      }
      rethrow;
    }
  }

  Future<AuthSessionModel> requireSession() async {
    return (await requireSnapshot()).session;
  }

  Future<SessionSnapshot> requireSnapshot() async {
    final snapshot = await _sessionStore.capture();
    if (snapshot == null) throw _signedOutFailure;
    return snapshot;
  }

  Future<T> execute<T>(Future<T> Function(String accessToken) request) async {
    final snapshot = await requireSnapshot();
    final current = snapshot.session;
    try {
      final result = await request(current.accessToken);
      await _requireRequestSnapshot(snapshot);
      return result;
    } on AuthFailure catch (failure) {
      if (failure.statusCode != 401) rethrow;
      final refreshed = await _refreshForRequest(snapshot, current.accessToken);
      final result = await request(refreshed.accessToken);
      await _requireRequestSnapshot(snapshot);
      return result;
    }
  }

  Future<SessionSnapshot> _requireRequestSnapshot(
    SessionSnapshot expected,
  ) async {
    final current = await requireSnapshot();
    if (!_sameGeneration(current, expected)) {
      throw _accountChangedFailure;
    }
    return current;
  }

  Future<AuthSessionModel> _refreshForRequest(
    SessionSnapshot expected,
    String expectedAccessToken,
  ) async {
    final current = await _requireRequestSnapshot(expected);
    if (current.session.accessToken != expectedAccessToken) {
      return current.session;
    }
    await refresh(expected: current.session, expectedSnapshot: expected);
    return (await _requireRequestSnapshot(expected)).session;
  }

  static bool _sameGeneration(SessionSnapshot left, SessionSnapshot right) =>
      left.generation == right.generation &&
      left.session.user.id == right.session.user.id;

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
  static const String replaySafeExtraKey = 'carenet.authRefreshReplaySafe';
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
      final snapshot = await _coordinator.requireSnapshot();
      if (authorization != 'Bearer ${snapshot.session.accessToken}') {
        throw SessionRefreshCoordinator._accountChangedFailure;
      }
      options.extra[_sessionKey] = snapshot;
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
    if (context is! SessionSnapshot) {
      handler.next(response);
      return;
    }
    try {
      await _coordinator._requireRequestSnapshot(context);
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
        context is! SessionSnapshot ||
        !_canReplay(request)) {
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

  static bool _canReplay(RequestOptions request) {
    if (!_isReplayableBody(request.data)) return false;

    switch (request.method.toUpperCase()) {
      case 'GET':
      case 'HEAD':
      case 'OPTIONS':
        return true;
      default:
        return request.extra[replaySafeExtraKey] == true &&
            _hasIdempotencyKey(request);
    }
  }

  static bool _hasIdempotencyKey(RequestOptions request) {
    for (final entry in request.headers.entries) {
      if (entry.key.toLowerCase() == 'idempotency-key') {
        return entry.value is String &&
            (entry.value as String).trim().isNotEmpty;
      }
    }
    return false;
  }

  static bool _isReplayableBody(Object? body) {
    if (body == null || body is String || body is num || body is bool) {
      return true;
    }
    if (body is FormData || body is MultipartFile || body is Stream) {
      return false;
    }
    if (body is Map) {
      return body.entries.every(
        (entry) => entry.key is String && _isReplayableBody(entry.value),
      );
    }
    if (body is List) {
      return body.every(_isReplayableBody);
    }
    return false;
  }
}
