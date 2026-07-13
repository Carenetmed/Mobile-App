import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/auth_failure.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';

class AuthApiClient {
  AuthApiClient({required CareNetApiConfig config, Dio? dio})
    : _config = config,
      _dio = dio ?? Dio();

  final CareNetApiConfig _config;
  final Dio _dio;

  static const String registerPath = '/auth/register';
  static const String loginPath = '/auth/login';
  static const String mePath = '/auth/me';
  static const String refreshPath = '/auth/refresh';
  static const String logoutPath = '/auth/logout';
  static const String emailVerificationRequestPath =
      '/auth/email-verification/request';
  static const String emailVerificationConfirmPath =
      '/auth/email-verification/confirm';
  static const String passwordResetRequestPath = '/auth/password-reset/request';
  static const String passwordResetConfirmPath = '/auth/password-reset/confirm';
  static const String googleSignInPath = '/auth/google/sign-in';
  static const String googleLinkPath = '/auth/google/link';

  Map<String, String> bearerHeaders(String accessToken) {
    return <String, String>{'Authorization': 'Bearer $accessToken'};
  }

  Future<AuthSessionModel> register({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic> profile = const <String, dynamic>{},
  }) async {
    final data = await _post(
      registerPath,
      data: <String, dynamic>{
        'email': email,
        'password': password,
        'role': role,
        if (profile.isNotEmpty) 'profile': profile,
      },
    );
    return AuthSessionModel.fromJson(data);
  }

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _post(
      loginPath,
      data: <String, dynamic>{'email': email, 'password': password},
    );
    return AuthSessionModel.fromJson(data);
  }

  Future<AuthUserModel> me({required String accessToken}) async {
    final data = await _get(mePath, accessToken: accessToken);
    return AuthUserModel.fromJson(data);
  }

  Future<AuthSessionModel> refresh({required String refreshToken}) async {
    final data = await _post(
      refreshPath,
      data: <String, dynamic>{'refreshToken': refreshToken},
    );
    return AuthSessionModel.fromJson(data);
  }

  Future<void> logout({required String refreshToken}) async {
    await _post(
      logoutPath,
      data: <String, dynamic>{'refreshToken': refreshToken},
    );
  }

  Future<void> requestEmailVerification({required String accessToken}) async {
    await _post(emailVerificationRequestPath, accessToken: accessToken);
  }

  Future<void> confirmEmailVerification({required String token}) async {
    await _post(
      emailVerificationConfirmPath,
      data: <String, dynamic>{'token': token},
    );
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _post(
      passwordResetRequestPath,
      data: <String, dynamic>{'email': email},
    );
  }

  Future<void> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    await _post(
      passwordResetConfirmPath,
      data: <String, dynamic>{'token': token, 'password': password},
    );
  }

  Future<AuthSessionModel> googleSignIn({required String idToken}) async {
    final data = await _post(
      googleSignInPath,
      data: <String, dynamic>{'idToken': idToken},
    );
    return AuthSessionModel.fromJson(data);
  }

  Future<void> googleLink({
    required String accessToken,
    required String idToken,
  }) async {
    await _post(
      googleLinkPath,
      accessToken: accessToken,
      data: <String, dynamic>{'idToken': idToken},
    );
  }

  Future<Map<String, dynamic>> _get(String path, {String? accessToken}) async {
    return _request(
      () => _dio.get<dynamic>(
        _url(path),
        options: Options(headers: _headers(accessToken)),
      ),
    );
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? data,
    String? accessToken,
  }) async {
    return _request(
      () => _dio.post<dynamic>(
        _url(path),
        data: data ?? const <String, dynamic>{},
        options: Options(headers: _headers(accessToken)),
      ),
    );
  }

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() send,
  ) async {
    try {
      final response = await send();
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return <String, dynamic>{};
    } on MissingCareNetApiConfigException {
      throw const AuthFailure(
        type: AuthFailureType.missingConfiguration,
        message: 'Backend is not configured yet.',
      );
    } on DioException catch (error) {
      throw _mapDioFailure(error);
    } catch (_) {
      throw const AuthFailure(
        type: AuthFailureType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Map<String, String> _headers(String? accessToken) {
    if (accessToken == null || accessToken.isEmpty) {
      return const <String, String>{};
    }
    return bearerHeaders(accessToken);
  }

  String _url(String path) {
    final baseUrl = _config.normalizedBaseUrl;
    if (baseUrl == null) {
      throw const MissingCareNetApiConfigException();
    }
    return '$baseUrl$path';
  }

  AuthFailure _mapDioFailure(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 400 || statusCode == 422) {
      return AuthFailure(
        type: AuthFailureType.validation,
        message: 'Please check the details and try again.',
        statusCode: statusCode,
      );
    }
    if (statusCode == 401 || statusCode == 403) {
      return AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
        statusCode: statusCode,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return AuthFailure(
        type: AuthFailureType.server,
        message: 'Service is unavailable. Please try again.',
        statusCode: statusCode,
      );
    }
    return AuthFailure(
      type: AuthFailureType.network,
      message: 'Network error. Please try again.',
      statusCode: statusCode,
    );
  }
}
