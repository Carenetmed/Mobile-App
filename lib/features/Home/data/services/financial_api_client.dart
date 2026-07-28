import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/consultation_price.dart';
import '../../domain/entities/financial_entities.dart';
import '../models/financial_models.dart';

class FinancialApiClient {
  FinancialApiClient({required CareNetApiConfig config, Dio? dio})
    : _config = config,
      _dio = dio ?? Dio();

  final CareNetApiConfig _config;
  final Dio _dio;

  static const String consultationPricePath =
      '/professionals/me/consultation-price';
  static const String financePath = '/professionals/me/finance';
  static const String banksPath = '$financePath/banks';
  static const String payoutProfilePath = '$financePath/payout-profile';
  static const String resolvePayoutPath = '$payoutProfilePath/resolve';
  static const String confirmPayoutPath = '$payoutProfilePath/confirm';

  static String appointmentPaymentPath(String appointmentId) {
    return '/appointments/${Uri.encodeComponent(appointmentId)}/payment';
  }

  Future<AppointmentPaymentView> appointmentPayment({
    required String accessToken,
    required String appointmentId,
  }) async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url(appointmentPaymentPath(appointmentId)),
        options: Options(headers: _bearer(accessToken)),
      ),
    );
    return FinancialModels.paymentView(_map(data));
  }

  Future<PaymentCheckout> initializeCheckout({
    required String accessToken,
    required String appointmentId,
    required String idempotencyKey,
  }) async {
    final data = await _request(
      () => _dio.post<dynamic>(
        _url('${appointmentPaymentPath(appointmentId)}/initialize'),
        options: Options(
          headers: <String, String>{
            ..._bearer(accessToken),
            'Idempotency-Key': idempotencyKey,
          },
        ),
      ),
    );
    return FinancialModels.checkout(_map(data));
  }

  Future<AppointmentPaymentView> refreshPayment({
    required String accessToken,
    required String appointmentId,
  }) async {
    final data = await _request(
      () => _dio.post<dynamic>(
        _url('${appointmentPaymentPath(appointmentId)}/refresh'),
        options: Options(headers: _bearer(accessToken)),
      ),
    );
    return FinancialModels.paymentView(_map(data));
  }

  Future<ConsultationPrice?> consultationPrice({
    required String accessToken,
  }) async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url(consultationPricePath),
        options: Options(headers: _bearer(accessToken)),
      ),
    );
    final map = _map(data);
    return FinancialModels.consultationPrice(map['consultationPrice'] ?? data);
  }

  Future<ConsultationPrice> updateConsultationPrice({
    required String accessToken,
    required int amountMinor,
  }) async {
    final data = await _request(
      () => _dio.put<dynamic>(
        _url(consultationPricePath),
        data: <String, dynamic>{'amountMinor': amountMinor, 'currency': 'NGN'},
        options: Options(headers: _bearer(accessToken)),
      ),
    );
    final map = _map(data);
    final parsed = FinancialModels.consultationPrice(
      map['consultationPrice'] ?? data,
    );
    if (parsed == null) {
      throw const AuthFailure(
        type: AuthFailureType.server,
        message: 'The saved consultation price could not be read.',
      );
    }
    return parsed;
  }

  Future<List<FinanceBank>> banks({required String accessToken}) async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url(banksPath),
        options: Options(headers: _bearer(accessToken)),
      ),
    );
    return FinancialModels.banks(data);
  }

  Future<BankAccountResolution> resolveBankAccount({
    required String accessToken,
    required String bankCode,
    required String accountNumber,
  }) async {
    final data = await _request(
      () => _dio.post<dynamic>(
        _url(resolvePayoutPath),
        data: <String, dynamic>{
          'bankCode': bankCode,
          'accountNumber': accountNumber,
        },
        options: Options(headers: _bearer(accessToken)),
      ),
    );
    return FinancialModels.resolution(_map(data));
  }

  Future<ProfessionalPayoutProfile> confirmBankAccount({
    required String accessToken,
    required String resolutionId,
  }) async {
    final data = await _request(
      () => _dio.post<dynamic>(
        _url(confirmPayoutPath),
        data: <String, dynamic>{'resolutionId': resolutionId},
        options: Options(headers: _bearer(accessToken)),
      ),
    );
    return FinancialModels.payoutProfile(_map(data));
  }

  Future<ProfessionalPayoutProfile?> payoutProfile({
    required String accessToken,
  }) async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url(payoutProfilePath),
        options: Options(headers: _bearer(accessToken)),
      ),
    );
    final value = _map(data)['payoutProfile'];
    return value is Map<String, dynamic>
        ? FinancialModels.payoutProfile(value)
        : null;
  }

  Future<void> deactivatePayoutProfile({required String accessToken}) async {
    await _request(
      () => _dio.delete<dynamic>(
        _url(payoutProfilePath),
        options: Options(headers: _bearer(accessToken)),
      ),
    );
  }

  Future<ProfessionalFinanceSummary> financeSummary({
    required String accessToken,
  }) async {
    final data = await _request(
      () => _dio.get<dynamic>(
        _url(financePath),
        options: Options(headers: _bearer(accessToken)),
      ),
    );
    return FinancialModels.financeSummary(_map(data));
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
      throw _mapFailure(error);
    } catch (error) {
      if (error is AuthFailure) {
        rethrow;
      }
      throw const AuthFailure(
        type: AuthFailureType.unknown,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Map<String, dynamic> _map(Object? data) {
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Map<String, String> _bearer(String token) {
    return <String, String>{'Authorization': 'Bearer $token'};
  }

  String _url(String path) {
    final baseUrl = _config.normalizedBaseUrl;
    if (baseUrl == null) {
      throw const MissingCareNetApiConfigException();
    }
    return '$baseUrl$path';
  }

  AuthFailure _mapFailure(DioException error) {
    final code = error.response?.statusCode;
    final message = switch (code) {
      400 || 422 => 'Please check the details and try again.',
      401 => 'Your session has expired. Please sign in again.',
      403 => 'This account is not allowed to perform that action.',
      404 => 'This financial record is no longer available.',
      409 => 'This financial state changed. Refresh and try again.',
      final int value when value >= 500 =>
        'Service is unavailable. Please try again.',
      _ => 'Network error. Please try again.',
    };
    return AuthFailure(
      type:
          code == 401 || code == 403
              ? AuthFailureType.unauthorized
              : code == 400 || code == 422 || code == 409
              ? AuthFailureType.validation
              : code != null && code >= 500
              ? AuthFailureType.server
              : AuthFailureType.network,
      message: message,
      statusCode: code,
    );
  }
}
