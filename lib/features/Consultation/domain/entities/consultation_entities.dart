import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';

enum ConsultationSessionStatus {
  pending,
  waiting,
  admitted,
  active,
  interrupted,
  ended,
  cancelled,
  closed,
  reviewRequired,
  noShowReview,
  unknown,
}

enum ConsultationParticipantRole { patient, professional, unknown }

enum ConsultationIncidentCategory {
  couldNotConnect,
  microphonePermission,
  cameraPermission,
  noAudio,
  noVideo,
  disconnectedRepeatedly,
  otherParticipantAbsent,
  endedUnexpectedly,
  unknown,
}

class ConsultationProjection {
  const ConsultationProjection({
    required this.appointmentId,
    required this.mode,
    required this.sessionStatus,
    required this.joinOpensAt,
    required this.lateJoinDeadlineAt,
    required this.scheduledEndsAt,
    required this.closesAt,
    required this.canEnterWaitingRoom,
    required this.canJoin,
    required this.canAdmit,
    required this.canRejoin,
    required this.patientWaiting,
    required this.patientAdmitted,
    required this.patientPresent,
    required this.professionalPresent,
    required this.reviewRequired,
    this.blockingReason,
  });

  final String appointmentId;
  final ConsultationMode? mode;
  final ConsultationSessionStatus? sessionStatus;
  final DateTime? joinOpensAt;
  final DateTime? lateJoinDeadlineAt;
  final DateTime? scheduledEndsAt;
  final DateTime? closesAt;
  final bool canEnterWaitingRoom;
  final bool canJoin;
  final bool canAdmit;
  final bool canRejoin;
  final bool patientWaiting;
  final bool patientAdmitted;
  final bool patientPresent;
  final bool professionalPresent;
  final bool reviewRequired;
  final String? blockingReason;

  bool get isTerminal =>
      sessionStatus == ConsultationSessionStatus.ended ||
      sessionStatus == ConsultationSessionStatus.cancelled ||
      sessionStatus == ConsultationSessionStatus.closed;
}

class ConsultationJoinGrant {
  const ConsultationJoinGrant({
    required this.provider,
    required this.serverUrl,
    required this.token,
    required this.expiresAt,
    required this.participantRole,
    required this.microphoneAllowed,
    required this.cameraAllowed,
    required this.sessionId,
    required this.replacedPriorDevice,
  });

  final String provider;
  final Uri serverUrl;
  final String token;
  final DateTime expiresAt;
  final ConsultationParticipantRole participantRole;
  final bool microphoneAllowed;
  final bool cameraAllowed;
  final String sessionId;
  final bool replacedPriorDevice;
}

class ConsultationIncidentReceipt {
  const ConsultationIncidentReceipt({
    required this.id,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String status;
  final DateTime createdAt;
}
