import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:dio/dio.dart';

import '../models/patient_profile_model.dart';
import '../models/professional_profile_model.dart';
import '../models/public_professional_model.dart';

class ProfileApiClient {
  ProfileApiClient({required CareNetApiConfig config, Dio? dio})
    : _config = config,
      _dio = dio ?? Dio();

  final CareNetApiConfig _config;
  final Dio _dio;

  static const String patientMePath = '/patients/me';
  static const String professionalMePath = '/professionals/me';
  static const String publicProfessionalsPath = '/professionals';

  Future<PatientProfileModel?> patientMe({required String accessToken}) async {
    final data = await _get(
      patientMePath,
      accessToken: accessToken,
      allowNotFound: true,
    );
    return data == null ? null : PatientProfileModel.fromJson(data);
  }

  Future<PatientProfileModel> updatePatientMe({
    required String accessToken,
    required String name,
    int? age,
    String? location,
  }) async {
    final data = await _put(
      patientMePath,
      accessToken: accessToken,
      data: <String, dynamic>{
        'name': name,
        if (age != null) 'age': age,
        if (location != null) 'location': location,
      },
    );
    return PatientProfileModel.fromJson(data);
  }

  Future<ProfessionalProfileModel?> professionalMe({
    required String accessToken,
  }) async {
    final data = await _get(
      professionalMePath,
      accessToken: accessToken,
      allowNotFound: true,
    );
    return data == null ? null : ProfessionalProfileModel.fromJson(data);
  }

  Future<ProfessionalProfileModel> updateProfessionalMe({
    required String accessToken,
    required String displayName,
    required String category,
    String? specialty,
    String? bio,
  }) async {
    final data = await _put(
      professionalMePath,
      accessToken: accessToken,
      data: <String, dynamic>{
        'displayName': displayName,
        'category': category,
        if (specialty != null) 'specialty': specialty,
        if (bio != null) 'bio': bio,
      },
    );
    return ProfessionalProfileModel.fromJson(data);
  }

  Future<List<PublicProfessionalModel>> publicProfessionals() async {
    final response = await _request(
      () => _dio.get<dynamic>(
        _url(publicProfessionalsPath),
        options: Options(headers: const <String, String>{}),
      ),
    );
    final items =
        response is List
            ? response
            : response is Map<String, dynamic> && response['items'] is List
            ? response['items'] as List<dynamic>
            : const <dynamic>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(PublicProfessionalModel.fromJson)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>?> _get(
    String path, {
    required String accessToken,
    bool allowNotFound = false,
  }) async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url(path),
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
      allowNotFound: allowNotFound,
    );
    return data is Map<String, dynamic> ? data : null;
  }

  Future<Map<String, dynamic>> _put(
    String path, {
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final response = await _request(
      () => _dio.put<dynamic>(
        _url(path),
        data: data,
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
    );
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  Future<dynamic> _request(
    Future<Response<dynamic>> Function() send, {
    bool allowNotFound = false,
  }) async {
    try {
      final response = await send();
      return response.data;
    } on MissingCareNetApiConfigException {
      throw const AuthFailure(
        type: AuthFailureType.missingConfiguration,
        message: 'Backend is not configured yet.',
      );
    } on DioException catch (error) {
      if (allowNotFound && error.response?.statusCode == 404) {
        return null;
      }
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
