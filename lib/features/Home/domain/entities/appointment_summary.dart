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
    this.pricing,
    this.payment,
  });

  final String id;
  final String patientProfileId;
  final String professionalProfileId;
  final DateTime requestedStartAt;
  final int durationMinutes;
  final AppointmentStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AppointmentPricing? pricing;
  final AppointmentPayment? payment;
}

class AppointmentPricing {
  const AppointmentPricing({
    required this.currency,
    required this.grossAmountMinor,
    this.platformFeeMinor,
    this.professionalNetMinor,
    this.snapshottedAt,
  });

  final String currency;
  final int grossAmountMinor;
  final int? platformFeeMinor;
  final int? professionalNetMinor;
  final DateTime? snapshottedAt;
}

class AppointmentPayment {
  const AppointmentPayment({
    this.id,
    required this.status,
    required this.dueAt,
    this.succeededAt,
    this.refundReviewAt,
    required this.consultationConfirmed,
  });

  final String? id;
  final AppointmentPaymentStatus status;
  final DateTime dueAt;
  final DateTime? succeededAt;
  final DateTime? refundReviewAt;
  final bool consultationConfirmed;
}

enum AppointmentPaymentStatus {
  awaitingPayment,
  processing,
  succeeded,
  expired,
  refundPending,
  refunded,
  disputed,
  reversed,
  reviewRequired,
  unknown,
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
