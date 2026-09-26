import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/network/carenet_http_client.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/notification_models.dart';

class NotificationApiClient {
  NotificationApiClient({required CareNetApiConfig config, Dio? dio})
    : _config = config,
      _dio = dio ?? CareNetHttpClient.create();

  final CareNetApiConfig _config;
  final Dio _dio;

  Future<NotificationPage> notifications({
    required String accessToken,
    String? cursor,
    NotificationCategory? category,
    String? read,
    int limit = 30,
  }) async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url('/notifications'),
        queryParameters: <String, dynamic>{
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
          if (category != null) 'category': category.wireName,
          if (read != null) 'read': read,
        },
        options: Options(headers: _headers(accessToken)),
      ),
    );
    return NotificationPage.fromJson(_object(data));
  }

  Future<CareNotification> notification({
    required String accessToken,
    required String notificationId,
  }) async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url('/notifications/${Uri.encodeComponent(notificationId)}'),
        options: Options(headers: _headers(accessToken)),
      ),
    );
    return CareNotification.fromJson(_object(data));
  }

  Future<int> unreadCount({required String accessToken}) async {
    final data = _object(
      await _request(
        () => _dio.get<dynamic>(
          _url('/notifications/unread-count'),
          options: Options(headers: _headers(accessToken)),
        ),
      ),
    );
    final count = data['unreadCount'];
    if (count is! int || count < 0) {
      throw const FormatException('Invalid unread notification count.');
    }
    return count;
  }

  Future<DateTime> markRead({
    required String accessToken,
    required String notificationId,
  }) async {
    final data = _object(
      await _request(
        () => _dio.post<dynamic>(
          _url('/notifications/${Uri.encodeComponent(notificationId)}/read'),
          options: Options(headers: _headers(accessToken)),
        ),
      ),
    );
    final readAt = DateTime.tryParse(data['readAt']?.toString() ?? '');
    if (readAt == null) throw const FormatException('Invalid read timestamp.');
    return readAt.toUtc();
  }

  Future<int> markAllRead({required String accessToken}) async {
    final data = _object(
      await _request(
        () => _dio.post<dynamic>(
          _url('/notifications/read-all'),
          options: Options(headers: _headers(accessToken)),
        ),
      ),
    );
    final count = data['updatedCount'];
    if (count is! int || count < 0) {
      throw const FormatException('Invalid updated notification count.');
    }
    return count;
  }

  Future<List<NotificationPreference>> preferences({
    required String accessToken,
  }) async {
    final data = _object(
      await _request(
        () => _dio.get<dynamic>(
          _url('/notifications/preferences'),
          options: Options(headers: _headers(accessToken)),
        ),
      ),
    );
    final values = data['preferences'];
    if (values is! List) throw const FormatException('Invalid preferences.');
    return values
        .map((value) => NotificationPreference.fromJson(_object(value)))
        .toList(growable: false);
  }

  Future<List<NotificationPreference>> updatePreferences({
    required String accessToken,
    required List<NotificationPreference> preferences,
  }) async {
    final data = _object(
      await _request(
        () => _dio.patch<dynamic>(
          _url('/notifications/preferences'),
          data: <String, dynamic>{
            'preferences': preferences.map((item) => item.toJson()).toList(),
          },
          options: Options(headers: _headers(accessToken)),
        ),
      ),
    );
    final values = data['preferences'];
    if (values is! List) throw const FormatException('Invalid preferences.');
    return values
        .map((value) => NotificationPreference.fromJson(_object(value)))
        .toList(growable: false);
  }

  Future<void> registerInstallation({
    required String accessToken,
    required Map<String, dynamic> payload,
  }) async {
    await _request(
      () => _dio.post<dynamic>(
        _url('/notification-installations'),
        data: payload,
        options: Options(headers: _headers(accessToken)),
      ),
    );
  }

  Future<void> removeInstallation({
    required String accessToken,
    required String installationId,
  }) async {
    await _request(
      () => _dio.delete<dynamic>(
        _url(
          '/notification-installations/${Uri.encodeComponent(installationId)}',
        ),
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
      throw _mapFailure(error);
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const AuthFailure(
        type: AuthFailureType.unknown,
        message: 'Notifications are unavailable. Please try again.',
      );
    }
  }

  AuthFailure _mapFailure(DioException error) {
    final status = error.response?.statusCode;
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
        message: 'This account cannot perform that notification action.',
        statusCode: 403,
      );
    }
    if (status == 404) {
      return const AuthFailure(
        type: AuthFailureType.validation,
        message: 'This notification is no longer available.',
        statusCode: 404,
      );
    }
    if (status != null && status >= 500) {
      return AuthFailure(
        type: AuthFailureType.server,
        message: 'Notifications are temporarily unavailable.',
        statusCode: status,
      );
    }
    return AuthFailure(
      type: AuthFailureType.network,
      message: 'Network error. Please try again.',
      statusCode: status,
    );
  }

  Map<String, dynamic> _object(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid notification response.');
  }

  Map<String, String> _headers(String accessToken) => <String, String>{
    'Authorization': 'Bearer $accessToken',
  };

  String _url(String path) {
    final baseUrl = _config.normalizedBaseUrl;
    if (baseUrl == null) throw const MissingCareNetApiConfigException();
    return '$baseUrl$path';
  }
}
