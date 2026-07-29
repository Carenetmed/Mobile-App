import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Consultation/data/models/consultation_models.dart';
import 'package:app_t/features/Consultation/domain/entities/consultation_entities.dart';
import 'package:dio/dio.dart';

class ConsultationApiClient {
  ConsultationApiClient({required CareNetApiConfig config, Dio? dio})
    : _config = config,
      _dio = dio ?? Dio();

  final CareNetApiConfig _config;
  final Dio _dio;

  static String consultationPath(String appointmentId) {
    return '/appointments/${Uri.encodeComponent(appointmentId)}/consultation';
  }

  Future<ConsultationProjectionModel> projection({
    required String accessToken,
    required String appointmentId,
  }) async {
    return _projectionRequest(
      () => _dio.get<dynamic>(
        _url(consultationPath(appointmentId)),
        options: Options(headers: _headers(accessToken)),
      ),
    );
  }

  Future<ConsultationProjectionModel> enterWaitingRoom({
    required String accessToken,
    required String appointmentId,
  }) {
    return _projectionRequest(
      () => _dio.post<dynamic>(
        _url('${consultationPath(appointmentId)}/waiting-room'),
        options: Options(headers: _headers(accessToken)),
      ),
    );
  }

  Future<ConsultationProjectionModel> admitPatient({
    required String accessToken,
    required String appointmentId,
  }) {
    return _projectionRequest(
      () => _dio.post<dynamic>(
        _url('${consultationPath(appointmentId)}/admit'),
        options: Options(headers: _headers(accessToken)),
      ),
    );
  }

  Future<ConsultationJoinGrantModel> joinGrant({
    required String accessToken,
    required String appointmentId,
    required String deviceSessionId,
    required bool cameraEnabled,
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(
        _url('${consultationPath(appointmentId)}/join-grants'),
        data: <String, dynamic>{
          'deviceSessionId': deviceSessionId,
          'cameraEnabled': cameraEnabled,
          'platform': 'flutter',
        },
        options: Options(headers: _headers(accessToken)),
      ),
    );
    return ConsultationJoinGrantModel.fromJson(_object(response));
  }

  Future<ConsultationProjectionModel> endConsultation({
    required String accessToken,
    required String appointmentId,
  }) {
    return _projectionRequest(
      () => _dio.post<dynamic>(
        _url('${consultationPath(appointmentId)}/end'),
        options: Options(headers: _headers(accessToken)),
      ),
    );
  }

  Future<ConsultationIncidentReceiptModel> reportIncident({
    required String accessToken,
    required String appointmentId,
    required ConsultationIncidentCategory category,
    required ConsultationParticipantRole reporterRole,
    String? description,
  }) async {
    final response = await _request(
      () => _dio.post<dynamic>(
        _url('${consultationPath(appointmentId)}/incidents'),
        data: <String, dynamic>{
          'category': _incidentWire(category, reporterRole),
          if (description?.trim().isNotEmpty == true)
            'description': description!.trim(),
        },
        options: Options(headers: _headers(accessToken)),
      ),
    );
    return ConsultationIncidentReceiptModel.fromJson(_object(response));
  }

  Future<ConsultationProjectionModel> _projectionRequest(
    Future<Response<dynamic>> Function() send,
  ) async {
    final response = await _request(send);
    return ConsultationProjectionModel.fromJson(_object(response));
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
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const AuthFailure(
        type: AuthFailureType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  AuthFailure _mapDioFailure(DioException error) {
    final status = error.response?.statusCode;
    if (status == 400 || status == 422) {
      return AuthFailure(
        type: AuthFailureType.validation,
        message: 'Please check the details and try again.',
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
        message: 'This account cannot access this consultation.',
        statusCode: 403,
      );
    }
    if (status == 404) {
      return const AuthFailure(
        type: AuthFailureType.validation,
        message: 'This consultation is no longer available.',
        statusCode: 404,
      );
    }
    if (status == 409) {
      return const AuthFailure(
        type: AuthFailureType.validation,
        message: 'The consultation state changed. Refresh and try again.',
        statusCode: 409,
      );
    }
    if (status != null && status >= 500) {
      return AuthFailure(
        type: AuthFailureType.server,
        message: 'Consultation service is temporarily unavailable.',
        statusCode: status,
      );
    }
    return AuthFailure(
      type: AuthFailureType.network,
      message: 'Network error. Please try again.',
      statusCode: status,
    );
  }

  Map<String, dynamic> _object(dynamic response) {
    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid consultation response.');
    }
    return response;
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
}

String _incidentWire(
  ConsultationIncidentCategory category,
  ConsultationParticipantRole reporterRole,
) {
  final networkFailure = switch (reporterRole) {
    ConsultationParticipantRole.patient => 'PATIENT_NETWORK_FAILURE',
    ConsultationParticipantRole.professional => 'PROFESSIONAL_NETWORK_FAILURE',
    ConsultationParticipantRole.unknown => 'UNKNOWN',
  };
  return switch (category) {
    ConsultationIncidentCategory.couldNotConnect => networkFailure,
    ConsultationIncidentCategory.microphonePermission =>
      'MICROPHONE_PERMISSION_FAILURE',
    ConsultationIncidentCategory.cameraPermission =>
      'CAMERA_PERMISSION_FAILURE',
    ConsultationIncidentCategory.noAudio => 'AUDIO_FAILURE',
    ConsultationIncidentCategory.noVideo => 'VIDEO_FAILURE',
    ConsultationIncidentCategory.disconnectedRepeatedly => networkFailure,
    ConsultationIncidentCategory.otherParticipantAbsent => 'UNKNOWN',
    ConsultationIncidentCategory.endedUnexpectedly =>
      'UNEXPECTED_ROOM_TERMINATION',
    ConsultationIncidentCategory.unknown => 'UNKNOWN',
  };
}
