import 'package:app_t/features/Consultation/domain/entities/consultation_entities.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';

class ConsultationProjectionModel extends ConsultationProjection {
  const ConsultationProjectionModel({
    required super.appointmentId,
    required super.mode,
    required super.sessionStatus,
    required super.joinOpensAt,
    required super.lateJoinDeadlineAt,
    required super.scheduledEndsAt,
    required super.closesAt,
    required super.canEnterWaitingRoom,
    required super.canJoin,
    required super.canAdmit,
    required super.canRejoin,
    required super.patientWaiting,
    required super.patientAdmitted,
    required super.patientPresent,
    required super.professionalPresent,
    required super.reviewRequired,
    super.blockingReason,
  });

  factory ConsultationProjectionModel.fromJson(Map<String, dynamic> json) {
    final appointmentId = json['appointmentId'] as String? ?? '';
    final rawMode = json['mode'];
    final mode = ConsultationModeWire.tryParse(rawMode);
    final rawStatus = json['sessionStatus'];
    final status = _sessionStatus(rawStatus);
    if (appointmentId.isEmpty ||
        (rawMode != null && mode == null) ||
        (rawStatus != null &&
            (status == null || status == ConsultationSessionStatus.unknown))) {
      throw const FormatException('Invalid consultation projection.');
    }
    return ConsultationProjectionModel(
      appointmentId: appointmentId,
      mode: mode,
      sessionStatus: status,
      joinOpensAt: _date(json['joinOpensAt']),
      lateJoinDeadlineAt: _date(json['lateJoinDeadlineAt']),
      scheduledEndsAt: _date(json['scheduledEndsAt']),
      closesAt: _date(json['closesAt']),
      canEnterWaitingRoom: json['canEnterWaitingRoom'] == true,
      canJoin: json['canJoin'] == true,
      canAdmit: json['canAdmit'] == true,
      canRejoin: json['canRejoin'] == true,
      patientWaiting: json['patientWaiting'] == true,
      patientAdmitted: json['patientAdmitted'] == true,
      patientPresent: json['patientPresent'] == true,
      professionalPresent: json['professionalPresent'] == true,
      reviewRequired: json['reviewRequired'] == true,
      blockingReason: json['blockingReason'] as String?,
    );
  }
}

class ConsultationJoinGrantModel extends ConsultationJoinGrant {
  const ConsultationJoinGrantModel({
    required super.provider,
    required super.serverUrl,
    required super.token,
    required super.expiresAt,
    required super.participantRole,
    required super.microphoneAllowed,
    required super.cameraAllowed,
    required super.sessionId,
    required super.replacedPriorDevice,
  });

  factory ConsultationJoinGrantModel.fromJson(Map<String, dynamic> json) {
    final serverUrl = Uri.tryParse(json['serverUrl'] as String? ?? '');
    final expiresAt = _date(json['expiresAt']);
    final token = json['token'] as String? ?? '';
    final sessionId = json['sessionId'] as String? ?? '';
    final provider = json['provider'] as String? ?? '';
    final participantRole = _participantRole(json['participantRole']);
    final permissions = json['initialMediaPermissions'];
    final permissionMap =
        permissions is Map<String, dynamic>
            ? permissions
            : const <String, dynamic>{};
    if (serverUrl == null ||
        serverUrl.scheme != 'wss' ||
        token.isEmpty ||
        expiresAt == null ||
        sessionId.isEmpty ||
        provider != 'LIVEKIT' ||
        participantRole == ConsultationParticipantRole.unknown ||
        permissionMap['microphone'] != true) {
      throw const FormatException('Invalid consultation join grant.');
    }
    return ConsultationJoinGrantModel(
      provider: provider,
      serverUrl: serverUrl,
      token: token,
      expiresAt: expiresAt,
      participantRole: participantRole,
      microphoneAllowed: permissionMap['microphone'] == true,
      cameraAllowed: permissionMap['camera'] == true,
      sessionId: sessionId,
      replacedPriorDevice: json['replacedPriorDevice'] == true,
    );
  }
}

class ConsultationIncidentReceiptModel extends ConsultationIncidentReceipt {
  const ConsultationIncidentReceiptModel({
    required super.id,
    required super.status,
    required super.createdAt,
  });

  factory ConsultationIncidentReceiptModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final status = json['status'] as String? ?? '';
    final createdAt = _date(json['createdAt']);
    if (id.isEmpty || status.isEmpty || createdAt == null) {
      throw const FormatException('Invalid consultation incident receipt.');
    }
    return ConsultationIncidentReceiptModel(
      id: id,
      status: status,
      createdAt: createdAt,
    );
  }
}

DateTime? _date(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toUtc();
}

ConsultationSessionStatus? _sessionStatus(Object? value) {
  if (value == null) {
    return null;
  }
  return switch (value) {
    'PENDING' => ConsultationSessionStatus.pending,
    'WAITING' => ConsultationSessionStatus.waiting,
    'ADMITTED' => ConsultationSessionStatus.admitted,
    'ACTIVE' => ConsultationSessionStatus.active,
    'INTERRUPTED' => ConsultationSessionStatus.interrupted,
    'ENDED' => ConsultationSessionStatus.ended,
    'CANCELLED' => ConsultationSessionStatus.cancelled,
    'CLOSED' => ConsultationSessionStatus.closed,
    'REVIEW_REQUIRED' => ConsultationSessionStatus.reviewRequired,
    'NO_SHOW_REVIEW' => ConsultationSessionStatus.noShowReview,
    _ => ConsultationSessionStatus.unknown,
  };
}

ConsultationParticipantRole _participantRole(Object? value) {
  return switch (value) {
    'PATIENT' => ConsultationParticipantRole.patient,
    'PROFESSIONAL' => ConsultationParticipantRole.professional,
    _ => ConsultationParticipantRole.unknown,
  };
}
