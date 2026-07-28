import 'appointment_summary.dart';
import 'consultation_price.dart';

class AppointmentPaymentView {
  const AppointmentPaymentView({
    required this.appointmentId,
    required this.appointmentStatus,
    this.pricing,
    this.payment,
  });

  final String appointmentId;
  final AppointmentStatus appointmentStatus;
  final AppointmentPricing? pricing;
  final AppointmentPayment? payment;
}

class PaymentCheckout {
  const PaymentCheckout({
    required this.appointmentId,
    required this.status,
    required this.attemptStatus,
    this.authorizationUrl,
    required this.dueAt,
  });

  final String appointmentId;
  final AppointmentPaymentStatus status;
  final String attemptStatus;
  final Uri? authorizationUrl;
  final DateTime dueAt;
}

class FinanceBank {
  const FinanceBank({
    required this.code,
    required this.name,
    required this.currency,
    required this.active,
  });

  final String code;
  final String name;
  final String currency;
  final bool active;
}

class BankAccountResolution {
  const BankAccountResolution({
    required this.resolutionId,
    required this.bankCode,
    required this.bankName,
    required this.accountName,
    required this.maskedAccountNumber,
    required this.expiresAt,
  });

  final String resolutionId;
  final String bankCode;
  final String bankName;
  final String accountName;
  final String maskedAccountNumber;
  final DateTime expiresAt;
}

class ProfessionalPayoutProfile {
  const ProfessionalPayoutProfile({
    required this.id,
    required this.version,
    required this.bankCode,
    required this.bankName,
    required this.accountName,
    required this.maskedAccountNumber,
    required this.status,
    this.coolingUntil,
    this.reviewReasonCode,
    this.activatedAt,
    required this.createdAt,
  });

  final String id;
  final int version;
  final String bankCode;
  final String bankName;
  final String accountName;
  final String maskedAccountNumber;
  final String status;
  final DateTime? coolingUntil;
  final String? reviewReasonCode;
  final DateTime? activatedAt;
  final DateTime createdAt;
}

class ProfessionalLedgerEntry {
  const ProfessionalLedgerEntry({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.eligibleAt,
    required this.descriptionCode,
    required this.createdAt,
    required this.reserved,
  });

  final String id;
  final String type;
  final int amountMinor;
  final String currency;
  final DateTime eligibleAt;
  final String descriptionCode;
  final DateTime createdAt;
  final bool reserved;
}

class ProfessionalPayout {
  const ProfessionalPayout({
    required this.id,
    required this.status,
    required this.mode,
    required this.amountMinor,
    required this.currency,
    this.externalReference,
    required this.bankName,
    required this.maskedAccountNumber,
    this.failureCode,
    this.submittedAt,
    this.completedAt,
    required this.createdAt,
  });

  final String id;
  final String status;
  final String mode;
  final int amountMinor;
  final String currency;
  final String? externalReference;
  final String bankName;
  final String maskedAccountNumber;
  final String? failureCode;
  final DateTime? submittedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
}

class ProfessionalFinanceSummary {
  const ProfessionalFinanceSummary({
    required this.currency,
    required this.heldMinor,
    required this.eligibleMinor,
    required this.availableMinor,
    required this.processingMinor,
    required this.paidMinor,
    required this.negativeBalanceMinor,
    required this.payoutPaused,
    this.payoutPauseReason,
    required this.recentLedger,
    required this.payouts,
  });

  final String currency;
  final int heldMinor;
  final int eligibleMinor;
  final int availableMinor;
  final int processingMinor;
  final int paidMinor;
  final int negativeBalanceMinor;
  final bool payoutPaused;
  final String? payoutPauseReason;
  final List<ProfessionalLedgerEntry> recentLedger;
  final List<ProfessionalPayout> payouts;
}

class ProfessionalFinanceSnapshot {
  const ProfessionalFinanceSnapshot({
    this.consultationPrice,
    required this.summary,
    required this.payoutProfile,
  });

  final ConsultationPrice? consultationPrice;
  final ProfessionalFinanceSummary summary;
  final ProfessionalPayoutProfile? payoutProfile;
}
