import '../../domain/entities/appointment_summary.dart';

class AppointmentSummaryModel extends AppointmentSummary {
  const AppointmentSummaryModel({
    required super.id,
    required super.patientProfileId,
    required super.professionalProfileId,
    required super.requestedStartAt,
    required super.durationMinutes,
    required super.status,
    super.consultationMode,
    super.createdAt,
    super.updatedAt,
    super.counterpart,
    super.pricing,
    super.payment,
  });

  factory AppointmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return AppointmentSummaryModel(
      id: (json['id'] as String?) ?? '',
      patientProfileId: (json['patientProfileId'] as String?) ?? '',
      professionalProfileId: (json['professionalProfileId'] as String?) ?? '',
      requestedStartAt: _asRequiredDateTime(json['requestedStartAt']),
      durationMinutes: _asInt(json['durationMinutes']),
      status: _statusFromWire(json['status']),
      consultationMode: ConsultationModeWire.tryParse(json['consultationMode']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
      counterpart: _counterpartFromJson(json['counterpart']),
      pricing: _pricingFromJson(json['pricing']),
      payment: _paymentFromJson(json['payment']),
    );
  }

  static AppointmentCounterpart? _counterpartFromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final profileId = (value['profileId'] as String? ?? '').trim();
    final displayName = (value['displayName'] as String? ?? '').trim();
    final role = switch (value['role']) {
      'PATIENT' => AppointmentCounterpartRole.patient,
      'PROFESSIONAL' => AppointmentCounterpartRole.professional,
      _ => null,
    };
    if (profileId.isEmpty || displayName.isEmpty || role == null) return null;
    return AppointmentCounterpart(
      profileId: profileId,
      role: role,
      displayName: displayName,
    );
  }

  static int _asInt(Object? value) {
    return switch (value) {
      int parsed => parsed,
      num parsed => parsed.toInt(),
      String text => int.tryParse(text) ?? 0,
      _ => 0,
    };
  }

  static DateTime _asRequiredDateTime(Object? value) {
    return _asDateTime(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _asDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static AppointmentStatus _statusFromWire(Object? value) {
    return switch (value) {
      'REQUESTED' => AppointmentStatus.requested,
      'ACCEPTED' => AppointmentStatus.accepted,
      'DECLINED' => AppointmentStatus.declined,
      'CANCELLED' => AppointmentStatus.cancelled,
      'COMPLETED' => AppointmentStatus.completed,
      _ => AppointmentStatus.unknown,
    };
  }

  static AppointmentPricing? _pricingFromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }
    final currency = value['currency'] as String? ?? '';
    final gross = _asInt(value['grossAmountMinor']);
    if (currency.isEmpty || gross <= 0) {
      return null;
    }
    return AppointmentPricing(
      currency: currency,
      grossAmountMinor: gross,
      platformFeeMinor:
          value['platformFeeMinor'] == null
              ? null
              : _asInt(value['platformFeeMinor']),
      professionalNetMinor:
          value['professionalNetMinor'] == null
              ? null
              : _asInt(value['professionalNetMinor']),
      snapshottedAt: _asDateTime(value['snapshottedAt']),
    );
  }

  static AppointmentPayment? _paymentFromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }
    final dueAt = _asDateTime(value['dueAt']);
    if (dueAt == null) {
      return null;
    }
    return AppointmentPayment(
      id: value['id'] as String?,
      status: _paymentStatusFromWire(value['status']),
      dueAt: dueAt,
      succeededAt: _asDateTime(value['succeededAt']),
      refundReviewAt: _asDateTime(value['refundReviewAt']),
      consultationConfirmed: value['consultationConfirmed'] == true,
    );
  }

  static AppointmentPaymentStatus _paymentStatusFromWire(Object? value) {
    return switch (value) {
      'AWAITING_PAYMENT' => AppointmentPaymentStatus.awaitingPayment,
      'PROCESSING' => AppointmentPaymentStatus.processing,
      'SUCCEEDED' => AppointmentPaymentStatus.succeeded,
      'EXPIRED' => AppointmentPaymentStatus.expired,
      'REFUND_PENDING' => AppointmentPaymentStatus.refundPending,
      'REFUNDED' => AppointmentPaymentStatus.refunded,
      'DISPUTED' => AppointmentPaymentStatus.disputed,
      'REVERSED' => AppointmentPaymentStatus.reversed,
      'REVIEW_REQUIRED' => AppointmentPaymentStatus.reviewRequired,
      _ => AppointmentPaymentStatus.unknown,
    };
  }
}
