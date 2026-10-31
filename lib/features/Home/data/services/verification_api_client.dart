import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/network/carenet_http_client.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:dio/dio.dart';

import '../models/verification_document_model.dart';

class VerificationApiClient {
  VerificationApiClient({
    required CareNetApiConfig config,
    Dio? dio,
    Dio? uploadDio,
  }) : _config = config,
       _dio = dio ?? CareNetHttpClient.create(),
       _uploadDio = uploadDio ?? CareNetHttpClient.createUpload();

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
    return _parseUpload(response);
  }

  Future<VerificationUploadInitModel> uploadRenew({
    required String accessToken,
    required String documentId,
  }) async {
    if (documentId.trim().isEmpty) throw _invalidUpload();
    final response = await _request(
      () => _dio.post<dynamic>(
        _url('$documentsPath/${Uri.encodeComponent(documentId)}/upload-renew'),
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
    );
    final upload = _parseUpload(response);
    if (upload.document.id != documentId) throw _invalidUpload();
    return upload;
  }

  Future<void> uploadBytes({
    required String signedUploadUrl,
    required List<int> fileBytes,
    required String mimeType,
    Map<String, String> requiredHeaders = const <String, String>{},
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    final uri = Uri.tryParse(signedUploadUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment) {
      throw _invalidUpload();
    }
    final headers = <String, String>{'Content-Type': mimeType};
    if (requiredHeaders.isNotEmpty) {
      final normalized = <String, String>{};
      for (final entry in requiredHeaders.entries) {
        final name = entry.key.toLowerCase();
        if (normalized.containsKey(name) ||
            !const <String>{
              'content-type',
              'content-length',
              'x-goog-if-generation-match',
            }.contains(name)) {
          throw _invalidUpload();
        }
        normalized[name] = entry.value;
      }
      if (normalized.length != 3 ||
          normalized['content-type'] != mimeType ||
          normalized['content-length'] != fileBytes.length.toString() ||
          normalized['x-goog-if-generation-match'] != '0') {
        throw _invalidUpload();
      }
      headers.addAll(<String, String>{
        'Content-Length': normalized['content-length']!,
        'x-goog-if-generation-match': '0',
      });
    }
    await _request(
      () => _uploadDio.put<dynamic>(
        signedUploadUrl,
        data: Uint8List.fromList(fileBytes),
        options: Options(headers: headers, followRedirects: false),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
      storageRequest: true,
    );
  }

  Future<VerificationDocumentModel> uploadComplete({
    required String accessToken,
    required String documentId,
    required int fileSizeBytes,
    required String checksumSha256,
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(
        _url('$documentsPath/$documentId/upload-complete'),
        data: <String, dynamic>{
          'fileSizeBytes': fileSizeBytes,
          'checksumSha256': checksumSha256,
        },
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
    );
    final documentJson =
        response is Map<String, dynamic> ? response['document'] : null;
    final document = VerificationDocumentModel.fromJson(
      documentJson is Map<String, dynamic>
          ? <String, dynamic>{
            ...documentJson,
            'checksumProvided':
                documentJson['checksumProvided'] as bool? ??
                documentJson['checksumSha256'] != null,
          }
          : const <String, dynamic>{},
    );
    if (document.id != documentId ||
        !document.checksumProvided ||
        !const {'PENDING', 'APPROVED', 'REJECTED'}.contains(document.status)) {
      throw _invalidUpload();
    }
    return document;
  }

  Future<dynamic> _request(
    Future<Response<dynamic>> Function() send, {
    bool storageRequest = false,
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
      if (storageRequest) {
        throw AuthFailure(
          type: AuthFailureType.network,
          message: 'Could not upload the document. Please try again.',
          statusCode: error.response?.statusCode,
        );
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

  VerificationUploadInitModel _parseUpload(dynamic response) {
    try {
      if (response is! Map<String, dynamic>) throw _invalidUpload();
      final upload = VerificationUploadInitModel.fromJson(response);
      if (upload.document.id.trim().isEmpty ||
          upload.signedUploadUrl.isEmpty ||
          upload.expiresInSeconds <= 0) {
        throw _invalidUpload();
      }
      return upload;
    } on FormatException {
      throw _invalidUpload();
    } on TypeError {
      throw _invalidUpload();
    }
  }

  AuthFailure _invalidUpload() => const AuthFailure(
    type: AuthFailureType.unknown,
    message: 'Could not prepare the document upload. Please try again.',
  );

  String _url(String path) {
    final baseUrl = _config.normalizedBaseUrl;
    if (baseUrl == null) {
      throw const MissingCareNetApiConfigException();
    }
    return '$baseUrl$path';
  }

  AuthFailure _mapDioFailure(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 404 || statusCode == 409 || statusCode == 412) {
      return AuthFailure(
        type: AuthFailureType.validation,
        message: 'This upload is unavailable or has changed. Please try again.',
        statusCode: statusCode,
      );
    }
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
      return AuthFailure(
        type: AuthFailureType.forbidden,
        message: 'This account cannot manage verification.',
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
    if (statusCode != null) {
      return AuthFailure(
        type: AuthFailureType.unknown,
        message:
            statusCode == 429
                ? 'Too many attempts. Please wait and try again.'
                : 'Request could not be completed. Please try again.',
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
