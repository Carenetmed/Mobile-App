import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';

import '../../domain/entities/consultation_price.dart';
import '../../domain/entities/financial_entities.dart';
import '../services/financial_api_client.dart';

class FinancialRepository {
  const FinancialRepository({
    required FinancialApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final FinancialApiClient _apiClient;
  final SessionStore _sessionStore;

  Future<AppointmentPaymentView> appointmentPayment(
    String appointmentId,
  ) async {
    final session = await _requireSession();
    return _apiClient.appointmentPayment(
      accessToken: session.accessToken,
      appointmentId: appointmentId,
    );
  }

  Future<PaymentCheckout> initializeCheckout({
    required String appointmentId,
    required String idempotencyKey,
  }) async {
    final session = await _requireSession();
    return _apiClient.initializeCheckout(
      accessToken: session.accessToken,
      appointmentId: appointmentId,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<AppointmentPaymentView> refreshPayment(String appointmentId) async {
    final session = await _requireSession();
    return _apiClient.refreshPayment(
      accessToken: session.accessToken,
      appointmentId: appointmentId,
    );
  }

  Future<ConsultationPrice?> consultationPrice() async {
    final session = await _requireProfessional();
    return _apiClient.consultationPrice(accessToken: session.accessToken);
  }

  Future<ConsultationPrice> updateConsultationPrice(int amountMinor) async {
    final session = await _requireProfessional();
    return _apiClient.updateConsultationPrice(
      accessToken: session.accessToken,
      amountMinor: amountMinor,
    );
  }

  Future<List<FinanceBank>> banks() async {
    final session = await _requireProfessional();
    return _apiClient.banks(accessToken: session.accessToken);
  }

  Future<BankAccountResolution> resolveBankAccount({
    required String bankCode,
    required String accountNumber,
  }) async {
    final session = await _requireProfessional();
    return _apiClient.resolveBankAccount(
      accessToken: session.accessToken,
      bankCode: bankCode,
      accountNumber: accountNumber,
    );
  }

  Future<ProfessionalPayoutProfile> confirmBankAccount(
    String resolutionId,
  ) async {
    final session = await _requireProfessional();
    return _apiClient.confirmBankAccount(
      accessToken: session.accessToken,
      resolutionId: resolutionId,
    );
  }

  Future<ProfessionalPayoutProfile?> payoutProfile() async {
    final session = await _requireProfessional();
    return _apiClient.payoutProfile(accessToken: session.accessToken);
  }

  Future<void> deactivatePayoutProfile() async {
    final session = await _requireProfessional();
    await _apiClient.deactivatePayoutProfile(accessToken: session.accessToken);
  }

  Future<ProfessionalFinanceSummary> financeSummary() async {
    final session = await _requireProfessional();
    return _apiClient.financeSummary(accessToken: session.accessToken);
  }

  Future<AuthSessionModel> _requireSession() async {
    final session = await _sessionStore.read();
    if (session == null) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }
    return session;
  }

  Future<AuthSessionModel> _requireProfessional() async {
    final session = await _requireSession();
    if (session.user.role.trim().toUpperCase() != 'PROFESSIONAL') {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'This account cannot manage professional finances.',
        statusCode: 403,
      );
    }
    return session;
  }
}
