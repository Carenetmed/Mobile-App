import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/network/carenet_http_client.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/messaging_models.dart';

class MessagingApiClient {
  MessagingApiClient({required CareNetApiConfig config, Dio? dio})
    : _config = config,
      _dio = dio ?? CareNetHttpClient.create();

  final CareNetApiConfig _config;
  final Dio _dio;

  Future<ConversationPage> conversations({
    required String accessToken,
    String? cursor,
    int limit = 30,
  }) async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url('/conversations'),
        queryParameters: <String, dynamic>{
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
        options: Options(headers: _headers(accessToken)),
      ),
    );
    return ConversationPage.fromJson(_object(data));
  }

  Future<ConversationDetail> conversation({
    required String accessToken,
    required String conversationId,
  }) async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url('/conversations/${Uri.encodeComponent(conversationId)}'),
        options: Options(headers: _headers(accessToken)),
      ),
    );
    return ConversationDetail.fromJson(_object(data));
  }

  Future<MessagePage> messages({
    required String accessToken,
    required String conversationId,
    BigInt? beforeSequence,
    BigInt? afterSequence,
    int limit = 50,
  }) async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url('/conversations/${Uri.encodeComponent(conversationId)}/messages'),
        queryParameters: <String, dynamic>{
          'limit': limit,
          if (beforeSequence != null)
            'beforeSequence': beforeSequence.toString(),
          if (afterSequence != null) 'afterSequence': afterSequence.toString(),
        },
        options: Options(headers: _headers(accessToken)),
      ),
    );
    return MessagePage.fromJson(_object(data));
  }

  Future<CareMessage> sendMessage({
    required String accessToken,
    required String conversationId,
    required String clientMessageId,
    required String text,
  }) async {
    final data = await _request(
      () => _dio.post<dynamic>(
        _url('/conversations/${Uri.encodeComponent(conversationId)}/messages'),
        data: <String, dynamic>{
          'clientMessageId': clientMessageId,
          'text': text,
        },
        options: Options(headers: _headers(accessToken)),
      ),
    );
    return CareMessage.fromJson(_object(data));
  }

  Future<void> markRead({
    required String accessToken,
    required String conversationId,
    required BigInt throughSequence,
  }) async {
    await _request(
      () => _dio.post<dynamic>(
        _url('/conversations/${Uri.encodeComponent(conversationId)}/read'),
        data: <String, dynamic>{'throughSequence': throughSequence.toString()},
        options: Options(headers: _headers(accessToken)),
      ),
    );
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() send) async {
    try {
      return (await send()).data;
    } on MissingCareNetApiConfigException {
      throw const AuthFailure(
        type: AuthFailureType.missingConfiguration,
        message: 'Backend is not configured yet.',
      );
    } on DioException catch (error) {
      throw _mapDioFailure(error);
    } on FormatException {
      throw const AuthFailure(
        type: AuthFailureType.server,
        message: 'Messaging returned an invalid response.',
      );
    } catch (_) {
      throw const AuthFailure(
        type: AuthFailureType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Map<String, dynamic> _object(Object? response) {
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw const FormatException('Invalid messaging response.');
  }

  Map<String, String> _headers(String accessToken) {
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
    final status = error.response?.statusCode;
    if (status == 400 || status == 422) {
      return AuthFailure(
        type: AuthFailureType.validation,
        message: 'Check the message and try again.',
        statusCode: status,
      );
    }
    if (status == 401) {
      return const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Your session has expired. Please sign in again.',
        statusCode: 401,
      );
    }
    if (status == 403) {
      return const AuthFailure(
        type: AuthFailureType.validation,
        message: 'This account cannot access that conversation.',
        statusCode: 403,
      );
    }
    if (status == 404) {
      return const AuthFailure(
        type: AuthFailureType.validation,
        message: 'This conversation is no longer available.',
        statusCode: 404,
      );
    }
    if (status == 409) {
      return const AuthFailure(
        type: AuthFailureType.validation,
        message: 'The conversation changed. Refresh and try again.',
        statusCode: 409,
      );
    }
    if (status != null && status >= 500) {
      return AuthFailure(
        type: AuthFailureType.server,
        message: 'Messaging is temporarily unavailable.',
        statusCode: status,
      );
    }
    return AuthFailure(
      type: AuthFailureType.network,
      message: 'Network error. Please try again.',
      statusCode: status,
    );
  }
}
