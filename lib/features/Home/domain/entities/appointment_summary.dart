class AppointmentSummary {
  const AppointmentSummary({
    required this.id,
    required this.patientProfileId,
    required this.professionalProfileId,
    required this.requestedStartAt,
    required this.durationMinutes,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String patientProfileId;
  final String professionalProfileId;
  final DateTime requestedStartAt;
  final int durationMinutes;
  final AppointmentStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

enum AppointmentStatus {
  requested,
  accepted,
  declined,
  cancelled,
  completed,
  unknown,
}

extension AppointmentStatusWire on AppointmentStatus {
  String get wireName {
    return switch (this) {
      AppointmentStatus.requested => 'REQUESTED',
      AppointmentStatus.accepted => 'ACCEPTED',
      AppointmentStatus.declined => 'DECLINED',
      AppointmentStatus.cancelled => 'CANCELLED',
      AppointmentStatus.completed => 'COMPLETED',
      AppointmentStatus.unknown => 'UNKNOWN',
    };
  }
}
