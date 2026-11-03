import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/network/carenet_http_client.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import '../../domain/entities/verification_storage_failure.dart';
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
        throw VerificationStorageFailure(
          reason:
              _confirmedStorageExpiry(error)
                  ? VerificationStorageFailureReason.expiredCapability
                  : VerificationStorageFailureReason.other,
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

  bool _confirmedStorageExpiry(DioException error) {
    final response = error.response;
    if (error.type != DioExceptionType.badResponse ||
        !const {400, 403}.contains(response?.statusCode)) {
      return false;
    }
    final contentTypes = response?.headers[Headers.contentTypeHeader];
    if (contentTypes == null || contentTypes.length != 1) return false;
    final mime = contentTypes.single.split(';').first.trim().toLowerCase();
    final body = response?.data;
    if (!const {'application/xml', 'text/xml'}.contains(mime) ||
        body is! String ||
        body.length > 16384 ||
        utf8.encode(body).length > 16384 ||
        RegExp(
          r'<!\s*(?:DOCTYPE|ENTITY)',
          caseSensitive: false,
        ).hasMatch(body)) {
      return false;
    }
    try {
      final document = XmlDocument.parse(body);
      final root = document.rootElement;
      if (document.children.any(
        (node) =>
            !identical(node, root) &&
            node is! XmlDeclaration &&
            node is! XmlComment &&
            !(node is XmlText && node.value.trim().isEmpty),
      )) {
        return false;
      }
      if (root.name.qualified != 'Error' || root.attributes.isNotEmpty) {
        return false;
      }
      final codes = root.findElements('Code').toList();
      final messages = root.findElements('Message').toList();
      if (codes.length != 1 ||
          messages.length != 1 ||
          codes.single.attributes.isNotEmpty ||
          messages.single.attributes.isNotEmpty ||
          codes.single.childElements.isNotEmpty ||
          messages.single.childElements.isNotEmpty ||
          root.descendantElements.where((e) => e.name.local == 'Code').length !=
              1 ||
          root.descendantElements
                  .where((e) => e.name.local == 'Message')
                  .length !=
              1) {
        return false;
      }
      final code = codes.single.innerText.trim();
      final message = messages.single.innerText.trim();
      return response!.statusCode == 400
          ? code == 'ExpiredToken' &&
              RegExp(
                r'^The provided token has expired\.?$',
                caseSensitive: false,
              ).hasMatch(message)
          : code == 'AccessDenied' &&
              RegExp(
                r'^Request has expired(?:[.:\s]|$)',
                caseSensitive: false,
              ).hasMatch(message);
    } on XmlException {
      return false;
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
