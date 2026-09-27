import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/network/carenet_http_client.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/availability_window.dart';
import '../models/appointment_summary_model.dart';
import '../models/availability_window_model.dart';
import '../models/requestable_times_model.dart';

class SchedulingApiClient {
  SchedulingApiClient({required CareNetApiConfig config, Dio? dio})
    : _config = config,
      _dio = dio ?? CareNetHttpClient.create();

  final CareNetApiConfig _config;
  final Dio _dio;

  static const String ownAvailabilityPath = '/availability/me';
  static const String appointmentsPath = '/appointments';

  static String publicAvailabilityPath(String professionalProfileId) {
    return '/professionals/${Uri.encodeComponent(professionalProfileId)}/availability';
  }

  static String publicRequestableTimesPath(String professionalProfileId) {
    return '/professionals/${Uri.encodeComponent(professionalProfileId)}/requestable-times';
  }

  static String appointmentActionPath(String appointmentId, String action) {
    return '/appointments/${Uri.encodeComponent(appointmentId)}/$action';
  }

  Future<List<AvailabilityWindowModel>> publicAvailability({
    required String professionalProfileId,
  }) async {
    final response = await _request(
      () => _dio.get<dynamic>(
        _url(publicAvailabilityPath(professionalProfileId)),
        options: Options(headers: const <String, String>{}),
      ),
    );
    return _availabilityItems(response);
  }

  Future<RequestableTimesModel> publicRequestableTimes({
    required String professionalProfileId,
    DateTime? rangeStartAt,
    DateTime? rangeEndAt,
  }) async {
    final response = await _request(
      () => _dio.get<dynamic>(
        _url(publicRequestableTimesPath(professionalProfileId)),
        queryParameters: <String, dynamic>{
          if (rangeStartAt != null)
            'from': rangeStartAt.toUtc().toIso8601String(),
          if (rangeEndAt != null) 'to': rangeEndAt.toUtc().toIso8601String(),
        },
        options: Options(headers: const <String, String>{}),
      ),
    );
    return RequestableTimesModel.fromJson(_object(response));
  }

  Future<List<AvailabilityWindowModel>> ownAvailability({
    required String accessToken,
  }) async {
    final response = await _request(
      () => _dio.get<dynamic>(
        _url(ownAvailabilityPath),
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
    );
    return _availabilityItems(response);
  }

  Future<List<AvailabilityWindowModel>> replaceOwnAvailability({
    required String accessToken,
    required List<AvailabilityWindowDraft> windows,
  }) async {
    final response = await _request(
      () => _dio.put<dynamic>(
        _url(ownAvailabilityPath),
        data: <String, dynamic>{
          'availabilityWindows':
              windows.map((window) => window.toJson()).toList(),
        },
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
    );
    return _availabilityItems(response);
  }

  Future<AppointmentSummaryModel> requestAppointment({
    required String accessToken,
    required String professionalProfileId,
    required DateTime requestedStartAt,
    required int durationMinutes,
    required String idempotencyKey,
    ConsultationMode consultationMode = ConsultationMode.video,
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(
        _url(appointmentsPath),
        data: <String, dynamic>{
          'professionalProfileId': professionalProfileId,
          'requestedStartAt': requestedStartAt.toUtc().toIso8601String(),
          'durationMinutes': durationMinutes,
          'consultationMode': consultationMode.wireName,
        },
        options: Options(
          headers: <String, String>{
            ..._bearerHeaders(accessToken),
            'Idempotency-Key': idempotencyKey,
          },
        ),
      ),
    );
    return AppointmentSummaryModel.fromJson(_object(response));
  }

  Future<List<AppointmentSummaryModel>> ownAppointments({
    required String accessToken,
  }) async {
    final response = await _request(
      () => _dio.get<dynamic>(
        _url(appointmentsPath),
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
    );
    return _appointmentItems(response);
  }

  Future<AppointmentSummaryModel> acceptAppointment({
    required String accessToken,
    required String appointmentId,
  }) {
    return _appointmentAction(
      accessToken: accessToken,
      appointmentId: appointmentId,
      action: 'accept',
    );
  }

  Future<AppointmentSummaryModel> declineAppointment({
    required String accessToken,
    required String appointmentId,
  }) {
    return _appointmentAction(
      accessToken: accessToken,
      appointmentId: appointmentId,
      action: 'decline',
    );
  }

  Future<AppointmentSummaryModel> cancelAppointment({
    required String accessToken,
    required String appointmentId,
  }) {
    return _appointmentAction(
      accessToken: accessToken,
      appointmentId: appointmentId,
      action: 'cancel',
    );
  }

  Future<AppointmentSummaryModel> completeAppointment({
    required String accessToken,
    required String appointmentId,
  }) {
    return _appointmentAction(
      accessToken: accessToken,
      appointmentId: appointmentId,
      action: 'complete',
    );
  }

  Future<AppointmentSummaryModel> rescheduleAppointment({
    required String accessToken,
    required String appointmentId,
    required DateTime requestedStartAt,
    required int durationMinutes,
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(
        _url(appointmentActionPath(appointmentId, 'reschedule')),
        data: <String, dynamic>{
          'requestedStartAt': requestedStartAt.toUtc().toIso8601String(),
          'durationMinutes': durationMinutes,
        },
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
    );
    return AppointmentSummaryModel.fromJson(_object(response));
  }

  Future<AppointmentSummaryModel> _appointmentAction({
    required String accessToken,
    required String appointmentId,
    required String action,
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(
        _url(appointmentActionPath(appointmentId, action)),
        options: Options(headers: _bearerHeaders(accessToken)),
      ),
    );
    return AppointmentSummaryModel.fromJson(_object(response));
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

  List<AvailabilityWindowModel> _availabilityItems(dynamic response) {
    return _items(response)
        .whereType<Map<String, dynamic>>()
        .map(AvailabilityWindowModel.fromJson)
        .toList(growable: false);
  }

  List<AppointmentSummaryModel> _appointmentItems(dynamic response) {
    return _items(response)
        .whereType<Map<String, dynamic>>()
        .map(AppointmentSummaryModel.fromJson)
        .toList(growable: false);
  }

  List<dynamic> _items(dynamic response) {
    return response is List
        ? response
        : response is Map<String, dynamic> && response['items'] is List
        ? response['items'] as List<dynamic>
        : response is Map<String, dynamic> &&
            response['availabilityWindows'] is List
        ? response['availabilityWindows'] as List<dynamic>
        : response is Map<String, dynamic> && response['appointments'] is List
        ? response['appointments'] as List<dynamic>
        : const <dynamic>[];
  }

  Map<String, dynamic> _object(dynamic response) {
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
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
        type: AuthFailureType.validation,
        message: 'This account is not allowed to perform that action.',
        statusCode: 403,
      );
    }
    if (statusCode == 404) {
      return const AuthFailure(
        type: AuthFailureType.validation,
        message: 'The requested resource is no longer available.',
        statusCode: 404,
      );
    }
    if (statusCode == 409) {
      return const AuthFailure(
        type: AuthFailureType.validation,
        message: 'The appointment changed. Refresh and try again.',
        statusCode: 409,
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
