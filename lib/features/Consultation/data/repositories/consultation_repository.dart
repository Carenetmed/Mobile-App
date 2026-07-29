import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Consultation/data/services/consultation_api_client.dart';
import 'package:app_t/features/Consultation/domain/entities/consultation_entities.dart';

abstract interface class ConsultationGateway {
  Future<ConsultationProjection> projection({required String appointmentId});

  Future<ConsultationProjection> enterWaitingRoom({
    required String appointmentId,
  });

  Future<ConsultationProjection> admitPatient({required String appointmentId});

  Future<ConsultationJoinGrant> joinGrant({
    required String appointmentId,
    required String deviceSessionId,
    required bool cameraEnabled,
  });

  Future<ConsultationProjection> endConsultation({
    required String appointmentId,
  });

  Future<ConsultationIncidentReceipt> reportIncident({
    required String appointmentId,
    required ConsultationIncidentCategory category,
    String? description,
  });
}

class ConsultationRepository implements ConsultationGateway {
  const ConsultationRepository({
    required ConsultationApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final ConsultationApiClient _apiClient;
  final SessionStore _sessionStore;

  @override
  Future<ConsultationProjection> projection({
    required String appointmentId,
  }) async {
    final session = await _requireSession();
    return _apiClient.projection(
      accessToken: session.accessToken,
      appointmentId: appointmentId,
    );
  }

  @override
  Future<ConsultationProjection> enterWaitingRoom({
    required String appointmentId,
  }) async {
    final session = await _requireSession();
    return _apiClient.enterWaitingRoom(
      accessToken: session.accessToken,
      appointmentId: appointmentId,
    );
  }

  @override
  Future<ConsultationProjection> admitPatient({
    required String appointmentId,
  }) async {
    final session = await _requireSession();
    return _apiClient.admitPatient(
      accessToken: session.accessToken,
      appointmentId: appointmentId,
    );
  }

  @override
  Future<ConsultationJoinGrant> joinGrant({
    required String appointmentId,
    required String deviceSessionId,
    required bool cameraEnabled,
  }) async {
    final session = await _requireSession();
    return _apiClient.joinGrant(
      accessToken: session.accessToken,
      appointmentId: appointmentId,
      deviceSessionId: deviceSessionId,
      cameraEnabled: cameraEnabled,
    );
  }

  @override
  Future<ConsultationProjection> endConsultation({
    required String appointmentId,
  }) async {
    final session = await _requireSession();
    return _apiClient.endConsultation(
      accessToken: session.accessToken,
      appointmentId: appointmentId,
    );
  }

  @override
  Future<ConsultationIncidentReceipt> reportIncident({
    required String appointmentId,
    required ConsultationIncidentCategory category,
    String? description,
  }) async {
    final session = await _requireSession();
    return _apiClient.reportIncident(
      accessToken: session.accessToken,
      appointmentId: appointmentId,
      category: category,
      reporterRole: switch (session.user.role.trim().toUpperCase()) {
        'PATIENT' => ConsultationParticipantRole.patient,
        'PROFESSIONAL' => ConsultationParticipantRole.professional,
        _ => ConsultationParticipantRole.unknown,
      },
      description: description,
    );
  }

  Future<AuthSessionModel> _requireSession() async {
    final current = await _sessionStore.read();
    if (current == null) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
      );
    }
    return current;
  }
}
