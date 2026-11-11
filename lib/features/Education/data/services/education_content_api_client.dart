import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/network/carenet_http_client.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/domain/entities/education_content.dart';
import 'package:dio/dio.dart';

class EducationContentApiClient {
  EducationContentApiClient({required CareNetApiConfig config, Dio? dio})
    : _config = config,
      _dio = dio ?? CareNetHttpClient.create();

  final CareNetApiConfig _config;
  final Dio _dio;

  static const String contentPath = '/education/content';
  static const int maxVideoBytes = 25 * 1024 * 1024;

  Future<List<EducationContent>> listMine({
    required String accessToken,
    CancelToken? cancelToken,
  }) async {
    final response = await _request(
      () => _dio.get<dynamic>(
        _url('$contentPath/mine'),
        options: Options(headers: _headers(accessToken)),
        cancelToken: cancelToken,
      ),
    );
    if (response is! List || response.length > 100) {
      throw _invalidResponse();
    }
    return response
        .map((item) => EducationContent.fromJson(_object(item)))
        .toList(growable: false);
  }

  Future<EducationContent> createDraft({
    required String accessToken,
    required EducationContentType type,
    required String title,
    String? body,
    String? caption,
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(
        _url(contentPath),
        data: <String, dynamic>{
          'type': type.wireName,
          'title': title,
          if (body != null) 'body': body,
          if (caption != null) 'caption': caption,
        },
        options: Options(headers: _headers(accessToken)),
      ),
    );
    final content = EducationContent.fromJson(_object(response));
    if (content.type != type || content.status != 'DRAFT') {
      throw _invalidResponse();
    }
    return content;
  }

  Future<EducationContent> updateDraft({
    required String accessToken,
    required EducationContent content,
    required String title,
    String? body,
    String? caption,
  }) async {
    final response = await _request(
      () => _dio.patch<dynamic>(
        _url('$contentPath/${Uri.encodeComponent(content.id)}'),
        data: <String, dynamic>{
          'title': title,
          if (body != null) 'body': body,
          if (caption != null) 'caption': caption,
        },
        options: Options(headers: _headers(accessToken)),
      ),
    );
    final updated = EducationContent.fromJson(_object(response));
    if (updated.id != content.id || updated.type != content.type) {
      throw _invalidResponse();
    }
    return updated;
  }

  Future<EducationVideoUploadReceipt> uploadVideo({
    required String accessToken,
    required String contentId,
    required String fileName,
    required Uint8List bytes,
    required CancelToken cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    if (bytes.isEmpty || bytes.length > maxVideoBytes) {
      throw const AuthFailure(
        type: AuthFailureType.validation,
        message: 'Choose an MP4 video under 25 MB.',
      );
    }
    final name = fileName.split(RegExp(r'[/\\]')).last;
    final safeName =
        name.toLowerCase().endsWith('.mp4') ? name : 'education-video.mp4';
    final form = FormData.fromMap(<String, dynamic>{
      'video': MultipartFile.fromBytes(
        bytes,
        filename: safeName,
        contentType: DioMediaType('video', 'mp4'),
      ),
    });
    final response = await _request(
      () => _dio.post<dynamic>(
        _url('$contentPath/${Uri.encodeComponent(contentId)}/video'),
        data: form,
        options: Options(
          headers: _headers(accessToken),
          sendTimeout: const Duration(seconds: 60),
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
      videoUpload: true,
    );
    final receipt = EducationVideoUploadReceipt.fromJson(_object(response));
    if (receipt.id != contentId ||
        (receipt.status != 'DRAFT' && receipt.status != 'REJECTED')) {
      throw _invalidResponse();
    }
    return receipt;
  }

  Future<void> submit({
    required String accessToken,
    required String contentId,
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(
        _url('$contentPath/${Uri.encodeComponent(contentId)}/submit'),
        options: Options(headers: _headers(accessToken)),
      ),
    );
    final result = _object(response);
    if (result['id'] != contentId || result['status'] != 'PENDING_REVIEW') {
      throw _invalidResponse();
    }
  }

  Future<void> archive({
    required String accessToken,
    required String contentId,
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(
        _url('$contentPath/${Uri.encodeComponent(contentId)}/archive'),
        options: Options(headers: _headers(accessToken)),
      ),
    );
    final result = _object(response);
    if (result['id'] != contentId || result['status'] != 'ARCHIVED') {
      throw _invalidResponse();
    }
  }

  Future<dynamic> _request(
    Future<Response<dynamic>> Function() send, {
    bool videoUpload = false,
  }) async {
    try {
      return (await send()).data;
    } on MissingCareNetApiConfigException {
      throw const AuthFailure(
        type: AuthFailureType.missingConfiguration,
        message: 'CareNet is not connected right now. Please try again later.',
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (error.type == DioExceptionType.cancel) rethrow;
      if (status == 400 || status == 422) {
        throw AuthFailure(
          type: AuthFailureType.validation,
          message:
              videoUpload
                  ? 'This video could not be accepted. Choose an MP4 under 60 seconds and 25 MB, then try again.'
                  : 'Review the title and content, then try again.',
          statusCode: status,
        );
      }
      if (status == 401) {
        throw AuthFailure(
          type: AuthFailureType.unauthorized,
          message: 'Your session ended. Sign in again to continue.',
          statusCode: status,
        );
      }
      if (status == 403) {
        throw const AuthFailure(
          type: AuthFailureType.forbidden,
          message:
              'Education posts are available to active, verified medical doctors.',
          statusCode: 403,
        );
      }
      if (status == 404) {
        throw AuthFailure(
          type: AuthFailureType.unknown,
          message: 'This education post is no longer available.',
          statusCode: status,
        );
      }
      if (status == 409) {
        throw AuthFailure(
          type: AuthFailureType.validation,
          message: 'This post changed. Refresh your posts and try again.',
          statusCode: status,
        );
      }
      if (status == 413) {
        throw AuthFailure(
          type: AuthFailureType.validation,
          message: 'Choose a video under 25 MB.',
          statusCode: status,
        );
      }
      if (status != null && status >= 500) {
        throw AuthFailure(
          type: AuthFailureType.server,
          message:
              videoUpload
                  ? 'Video upload is temporarily unavailable. Your draft is saved.'
                  : 'Education posts are temporarily unavailable. Please retry.',
          statusCode: status,
        );
      }
      throw AuthFailure(
        type: AuthFailureType.network,
        message:
            videoUpload
                ? 'The video upload could not be completed. Your draft is saved; retry the upload.'
                : 'A network error occurred. Please try again.',
        statusCode: status,
      );
    } on FormatException {
      throw _invalidResponse();
    }
  }

  Map<String, dynamic> _object(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    throw _invalidResponse();
  }

  AuthFailure _invalidResponse() => const AuthFailure(
    type: AuthFailureType.server,
    message: 'CareNet returned an unexpected education-post response.',
  );

  Map<String, String> _headers(String accessToken) => <String, String>{
    'Authorization': 'Bearer $accessToken',
  };

  String _url(String path) {
    final baseUrl = _config.normalizedBaseUrl;
    if (baseUrl == null) throw const MissingCareNetApiConfigException();
    return '$baseUrl$path';
  }
}
