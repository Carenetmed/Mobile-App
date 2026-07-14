import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:dio/dio.dart';

import '../models/verification_document_model.dart';

class VerificationApiClient {
  VerificationApiClient({
    required CareNetApiConfig config,
    Dio? dio,
    Dio? uploadDio,
  }) : _config = config,
       _dio = dio ?? Dio(),
       _uploadDio = uploadDio ?? Dio();

  final CareNetApiConfig _config;
  final Dio _dio;
  final Dio _uploadDio;

  static const String documentsPath = '/verification/documents';
  static const String uploadInitPath = '/verification/documents/upload-init';

  Future<List<VerificationDocumentModel>> documents({
    required String accessToken,
  }) async {
    final response = await _request(
      () => _dio.get<dynamic>(
        _url(documentsPath),
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
    );
    final items =
        response is Map<String, dynamic> && response['documents'] is List
            ? response['documents'] as List<dynamic>
            : response is Map<String, dynamic> && response['items'] is List
            ? response['items'] as List<dynamic>
            : response is List
            ? response
            : const <dynamic>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(VerificationDocumentModel.fromJson)
        .toList(growable: false);
  }

  Future<VerificationUploadInitModel> uploadInit({
    required String accessToken,
    required String documentType,
    required String originalFileName,
    required String mimeType,
    int? fileSizeBytes,
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(
        _url(uploadInitPath),
        data: <String, dynamic>{
          'documentType': documentType,
          'originalFileName': originalFileName,
          'mimeType': mimeType,
          if (fileSizeBytes != null) 'fileSizeBytes': fileSizeBytes,
        },
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
    );
    return VerificationUploadInitModel.fromJson(
      response is Map<String, dynamic> ? response : const <String, dynamic>{},
    );
  }

  Future<void> uploadBytes({
    required String signedUploadUrl,
    required List<int> fileBytes,
    required String mimeType,
  }) async {
    await _request(
      () => _uploadDio.put<dynamic>(
        signedUploadUrl,
        data: fileBytes,
        options: Options(headers: <String, String>{'Content-Type': mimeType}),
      ),
    );
  }

  Future<VerificationDocumentModel> uploadComplete({
    required String accessToken,
    required String documentId,
    int? fileSizeBytes,
    String? checksumSha256,
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(
        _url('$documentsPath/$documentId/upload-complete'),
        data: <String, dynamic>{
          if (fileSizeBytes != null) 'fileSizeBytes': fileSizeBytes,
          if (checksumSha256 != null) 'checksumSha256': checksumSha256,
        },
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
    );
    final documentJson =
        response is Map<String, dynamic> ? response['document'] : null;
    return VerificationDocumentModel.fromJson(
      documentJson is Map<String, dynamic>
          ? <String, dynamic>{
            ...documentJson,
            'checksumProvided':
                documentJson['checksumProvided'] as bool? ??
                documentJson['checksumSha256'] != null,
          }
          : const <String, dynamic>{},
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
