import '../../domain/entities/appointment_summary.dart';
import '../../domain/entities/financial_entities.dart';
import 'appointment_summary_model.dart';
import 'consultation_price_model.dart';

class FinancialModels {
  const FinancialModels._();

  static AppointmentPaymentView paymentView(Map<String, dynamic> json) {
    final appointmentJson = <String, dynamic>{
      'id': json['appointmentId'],
      'patientProfileId': '',
      'professionalProfileId': '',
      'requestedStartAt':
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toIso8601String(),
      'durationMinutes': 0,
      'status': json['appointmentStatus'],
      'pricing': json['pricing'],
      'payment': json['payment'],
    };
    final parsed = AppointmentSummaryModel.fromJson(appointmentJson);
    return AppointmentPaymentView(
      appointmentId: parsed.id,
      appointmentStatus: parsed.status,
      pricing: parsed.pricing,
      payment: parsed.payment,
    );
  }

  static PaymentCheckout checkout(Map<String, dynamic> json) {
    final dueAt = _requiredDate(json['dueAt']);
    final rawUrl = json['authorizationUrl'] as String?;
    return PaymentCheckout(
      appointmentId: json['appointmentId'] as String? ?? '',
      status: paymentStatus(json['status']),
      attemptStatus: json['attemptStatus'] as String? ?? '',
      authorizationUrl:
          rawUrl == null || rawUrl.trim().isEmpty
              ? null
              : Uri.tryParse(rawUrl.trim()),
      dueAt: dueAt,
    );
  }

  static ConsultationPriceModel? consultationPrice(Object? json) {
    return ConsultationPriceModel.fromNullableJson(json);
  }

  static List<FinanceBank> banks(Object? json) {
    final values =
        json is Map<String, dynamic> && json['banks'] is List
            ? json['banks'] as List<dynamic>
            : const <dynamic>[];
    return values
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => FinanceBank(
            code: item['code'] as String? ?? '',
            name: item['name'] as String? ?? '',
            currency: item['currency'] as String? ?? '',
            active: item['active'] == true,
          ),
        )
        .where(
          (bank) =>
              bank.active &&
              bank.currency == 'NGN' &&
              bank.code.isNotEmpty &&
              bank.name.isNotEmpty,
        )
        .toList(growable: false);
  }

  static BankAccountResolution resolution(Map<String, dynamic> json) {
    return BankAccountResolution(
      resolutionId: json['resolutionId'] as String? ?? '',
      bankCode: json['bankCode'] as String? ?? '',
      bankName: json['bankName'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      maskedAccountNumber: json['maskedAccountNumber'] as String? ?? '',
      expiresAt: _requiredDate(json['expiresAt']),
    );
  }

  static ProfessionalPayoutProfile payoutProfile(Map<String, dynamic> json) {
    return ProfessionalPayoutProfile(
      id: json['id'] as String? ?? '',
      version: _int(json['version']),
      bankCode: json['bankCode'] as String? ?? '',
      bankName: json['bankName'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      maskedAccountNumber: json['maskedAccountNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'UNKNOWN',
      coolingUntil: _date(json['coolingUntil']),
      reviewReasonCode: json['reviewReasonCode'] as String?,
      activatedAt: _date(json['activatedAt']),
      createdAt: _requiredDate(json['createdAt']),
    );
  }

  static ProfessionalFinanceSummary financeSummary(Map<String, dynamic> json) {
    final ledger =
        json['recentLedger'] is List
            ? (json['recentLedger'] as List<dynamic>)
                .whereType<Map<String, dynamic>>()
                .map(
                  (item) => ProfessionalLedgerEntry(
                    id: item['id'] as String? ?? '',
                    type: item['type'] as String? ?? 'UNKNOWN',
                    amountMinor: _int(item['amountMinor']),
                    currency: item['currency'] as String? ?? 'NGN',
                    eligibleAt: _requiredDate(item['eligibleAt']),
                    descriptionCode:
                        item['descriptionCode'] as String? ?? 'UNAVAILABLE',
                    createdAt: _requiredDate(item['createdAt']),
                    reserved: item['reserved'] == true,
                  ),
                )
                .toList(growable: false)
            : const <ProfessionalLedgerEntry>[];
    final payouts =
        json['payouts'] is List
            ? (json['payouts'] as List<dynamic>)
                .whereType<Map<String, dynamic>>()
                .map(
                  (item) => ProfessionalPayout(
                    id: item['id'] as String? ?? '',
                    status: item['status'] as String? ?? 'UNKNOWN',
                    mode: item['mode'] as String? ?? 'UNKNOWN',
                    amountMinor: _int(item['amountMinor']),
                    currency: item['currency'] as String? ?? 'NGN',
                    externalReference: item['externalReference'] as String?,
                    bankName: item['bankName'] as String? ?? '',
                    maskedAccountNumber:
                        item['maskedAccountNumber'] as String? ?? '',
                    failureCode: item['failureCode'] as String?,
                    submittedAt: _date(item['submittedAt']),
                    completedAt: _date(item['completedAt']),
                    createdAt: _requiredDate(item['createdAt']),
                  ),
                )
                .toList(growable: false)
            : const <ProfessionalPayout>[];
    return ProfessionalFinanceSummary(
      currency: json['currency'] as String? ?? 'NGN',
      heldMinor: _int(json['heldMinor']),
      eligibleMinor: _int(json['eligibleMinor']),
      availableMinor: _int(json['availableMinor']),
      processingMinor: _int(json['processingMinor']),
      paidMinor: _int(json['paidMinor']),
      negativeBalanceMinor: _int(json['negativeBalanceMinor']),
      payoutPaused: json['payoutPaused'] == true,
      payoutPauseReason: json['payoutPauseReason'] as String?,
      recentLedger: ledger,
      payouts: payouts,
    );
  }

  static AppointmentPaymentStatus paymentStatus(Object? value) {
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

  static int _int(Object? value) {
    return switch (value) {
      int parsed => parsed,
      num parsed => parsed.toInt(),
      String text => int.tryParse(text) ?? 0,
      _ => 0,
    };
  }

  static DateTime? _date(Object? value) {
    return value is String ? DateTime.tryParse(value)?.toUtc() : null;
  }

  static DateTime _requiredDate(Object? value) {
    return _date(value) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
