import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/network/carenet_http_client.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:dio/dio.dart';

import '../models/account_readiness_model.dart';
import '../models/onboarding_catalog_model.dart';

class OnboardingApiClient {
  OnboardingApiClient({required CareNetApiConfig config, Dio? dio})
    : _config = config,
      _dio = dio ?? CareNetHttpClient.create();

  final CareNetApiConfig _config;
  final Dio _dio;

  static const String onboardingCatalogPath = '/catalogs/onboarding';
  static const String accountReadinessPath = '/account/readiness';

  Future<OnboardingCatalogModel> onboardingCatalog() async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url(onboardingCatalogPath),
        options: Options(headers: const <String, String>{}),
      ),
    );
    return OnboardingCatalogModel.fromJson(
      data is Map<String, dynamic> ? data : const <String, dynamic>{},
    );
  }

  Future<AccountReadinessModel> accountReadiness({
    required String accessToken,
  }) async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url(accountReadinessPath),
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
    );
    return AccountReadinessModel.fromJson(
      data is Map<String, dynamic> ? data : const <String, dynamic>{},
    );
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() send) async {
    try {
      final response = await send();
      return response.data;
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

  Map<String, String> _bearerHeaders(String accessToken) {
    return <String, String>{'Authorization': 'Bearer $accessToken'};
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
    if (statusCode == 401) {
      return AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
        statusCode: statusCode,
      );
    }
    if (statusCode == 403) {
      return const AuthFailure(
        type: AuthFailureType.forbidden,
        message: 'This account does not have permission for this action.',
        statusCode: 403,
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
