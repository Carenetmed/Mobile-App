import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Home/data/repositories/financial_repository.dart';
import 'package:app_t/features/Home/data/services/financial_api_client.dart';
import 'package:app_t/features/Home/data/storage/payment_checkout_intent_store.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/consultation_price.dart';
import 'package:app_t/features/Home/domain/entities/financial_entities.dart';
import 'package:app_t/features/Home/domain/entities/payment_checkout_intent.dart';
import 'package:app_t/features/Home/domain/services/hosted_checkout_launcher.dart';
import 'package:app_t/features/Home/domain/services/money_formatter.dart';
import 'package:app_t/features/Home/presentation/state/appointment_payment_controller.dart';
import 'package:app_t/features/Home/presentation/state/professional_finance_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money presentation', () {
    test('converts naira text without floating-point arithmetic', () {
      expect(parseNgnMajorToMinor('100.05'), 10005);
      expect(parseNgnMajorToMinor('15000'), 1500000);
      expect(parseNgnMajorToMinor('12.345'), isNull);
      expect(formatNgnMinor(-10005), '-NGN 100.05');
    });

    test('commission preview matches backend half-up basis-point rounding', () {
      expect(calculatePlatformFeeMinor(10005), 1501);
      expect(calculatePlatformFeeMinor(20000), 3000);
    });
  });

  group('Financial API contract', () {
    test(
      'payment initialization sends bearer and durable idempotency key',
      () async {
        final adapter = _FakeAdapter(
          responseJson: <String, dynamic>{
            'appointmentId': 'appointment-1',
            'status': 'PROCESSING',
            'attemptStatus': 'PENDING',
            'authorizationUrl': 'https://checkout.paystack.com/access-code',
            'dueAt': '2026-07-30T12:00:00.000Z',
          },
        );
        final client = _client(adapter);

        final checkout = await client.initializeCheckout(
          accessToken: 'access-token',
          appointmentId: 'appointment 1',
          idempotencyKey: 'checkout-key',
        );

        expect(
          adapter.lastOptions?.uri.toString(),
          endsWith('/appointments/appointment%201/payment/initialize'),
        );
        expect(adapter.lastOptions?.method, 'POST');
        expect(
          adapter.lastOptions?.headers['Authorization'],
          'Bearer access-token',
        );
        expect(adapter.lastOptions?.headers['Idempotency-Key'], 'checkout-key');
        expect(checkout.status, AppointmentPaymentStatus.processing);
        expect(checkout.authorizationUrl?.host, 'checkout.paystack.com');
      },
    );

    test('participant payment parses patient-safe projection', () async {
      final adapter = _FakeAdapter(
        responseJson: _paymentViewJson(status: 'SUCCEEDED'),
      );
      final client = _client(adapter);

      final view = await client.appointmentPayment(
        accessToken: 'access-token',
        appointmentId: 'appointment-1',
      );

      expect(view.pricing?.grossAmountMinor, 1500000);
      expect(view.pricing?.professionalNetMinor, isNull);
      expect(view.payment?.status, AppointmentPaymentStatus.succeeded);
      expect(view.payment?.consultationConfirmed, isTrue);
    });

    test('consultation price update sends integer NGN minor units', () async {
      final adapter = _FakeAdapter(
        responseJson: <String, dynamic>{
          'amountMinor': 2000000,
          'currency': 'NGN',
          'updatedAt': '2026-07-29T10:00:00.000Z',
        },
      );
      final client = _client(adapter);

      final price = await client.updateConsultationPrice(
        accessToken: 'access-token',
        amountMinor: 2000000,
      );

      expect(adapter.lastOptions?.method, 'PUT');
      expect(
        adapter.lastOptions?.uri.toString(),
        endsWith('/professionals/me/consultation-price'),
      );
      expect(adapter.lastOptions?.data, <String, dynamic>{
        'amountMinor': 2000000,
        'currency': 'NGN',
      });
      expect(price.amountMinor, 2000000);
    });

    test(
      'finance summary preserves held, eligible and payout authority',
      () async {
        final adapter = _FakeAdapter(
          responseJson: <String, dynamic>{
            'currency': 'NGN',
            'heldMinor': 100000,
            'eligibleMinor': 200000,
            'availableMinor': 200000,
            'processingMinor': 50000,
            'paidMinor': 900000,
            'negativeBalanceMinor': 0,
            'payoutPaused': false,
            'payoutPauseReason': null,
            'recentLedger': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'ledger-1',
                'type': 'EARNING',
                'amountMinor': 100000,
                'currency': 'NGN',
                'eligibleAt': '2026-08-01T10:00:00.000Z',
                'descriptionCode': 'CONSULTATION_EARNING',
                'createdAt': '2026-07-29T10:00:00.000Z',
                'reserved': false,
              },
            ],
            'payouts': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'payout-1',
                'status': 'PROCESSING',
                'mode': 'AUTOMATED',
                'amountMinor': 50000,
                'currency': 'NGN',
                'externalReference': null,
                'bankName': 'Care Bank',
                'maskedAccountNumber': '******1234',
                'failureCode': null,
                'submittedAt': null,
                'completedAt': null,
                'createdAt': '2026-07-29T10:00:00.000Z',
              },
            ],
          },
        );

        final summary = await _client(
          adapter,
        ).financeSummary(accessToken: 'access-token');

        expect(summary.heldMinor, 100000);
        expect(summary.availableMinor, 200000);
        expect(summary.recentLedger.single.reserved, isFalse);
        expect(summary.payouts.single.maskedAccountNumber, '******1234');
      },
    );
  });

  group('Payment checkout intent', () {
    test('is scoped to appointment and authenticated account', () async {
      final store = InMemoryPaymentCheckoutIntentStore();
      final intent = _paymentIntent();
      await store.save(intent);

      expect(
        await store.read(
          appointmentId: 'appointment-1',
          accountUserId: 'patient-user-1',
          now: DateTime.parse('2026-07-29T10:30:00Z'),
        ),
        same(intent),
      );
      expect(
        await store.read(
          appointmentId: 'appointment-1',
          accountUserId: 'another-user',
        ),
        isNull,
      );
    });

    test('expires and never stores credentials', () {
      final intent = _paymentIntent();
      final restored = PaymentCheckoutIntent.fromJson(intent.toJson());

      expect(restored.isExpired(intent.expiresAt), isTrue);
      expect(restored.toJson().containsKey('accessToken'), isFalse);
      expect(restored.toJson().containsKey('cardNumber'), isFalse);
    });
  });

  group('Appointment payment controller', () {
    test('serializes repeated taps and reuses the persisted key', () async {
      final repository = _FakeFinancialRepository();
      final intentStore = InMemoryPaymentCheckoutIntentStore();
      final launcher = _FakeLauncher();
      final controller = AppointmentPaymentController(
        appointmentId: 'appointment-1',
        financialRepository: repository,
        sessionStore: _patientSession(),
        intentStore: intentStore,
        launcher: launcher,
        now: () => DateTime.parse('2026-07-29T10:00:00Z'),
      );
      await controller.load();

      final first = controller.beginCheckout();
      final second = controller.beginCheckout();
      await Future.wait(<Future<void>>[first, second]);

      expect(repository.initializeCalls, 1);
      expect(repository.lastIdempotencyKey, isNotEmpty);
      expect(launcher.openCalls, 1);
      final stored = await intentStore.read(
        appointmentId: 'appointment-1',
        accountUserId: 'patient-user-1',
      );
      expect(stored?.idempotencyKey, repository.lastIdempotencyKey);
      expect(controller.awaitingBrowserReturn, isTrue);
    });

    test('rejects a non-Paystack or non-HTTPS checkout URL', () async {
      final repository = _FakeFinancialRepository(
        checkoutUri: Uri.parse('http://example.com/collect'),
      );
      final launcher = _FakeLauncher();
      final controller = AppointmentPaymentController(
        appointmentId: 'appointment-1',
        financialRepository: repository,
        sessionStore: _patientSession(),
        intentStore: InMemoryPaymentCheckoutIntentStore(),
        launcher: launcher,
        now: () => DateTime.parse('2026-07-29T10:00:00Z'),
      );
      await controller.load();

      await controller.beginCheckout();

      expect(launcher.openCalls, 0);
      expect(controller.errorMessage, contains('could not be verified'));
    });

    test('professional role fails closed before initialization', () async {
      final repository = _FakeFinancialRepository();
      final controller = AppointmentPaymentController(
        appointmentId: 'appointment-1',
        financialRepository: repository,
        sessionStore: _professionalSession(),
        intentStore: InMemoryPaymentCheckoutIntentStore(),
        launcher: _FakeLauncher(),
        now: () => DateTime.parse('2026-07-29T10:00:00Z'),
      );
      await controller.load();

      await controller.beginCheckout();

      expect(repository.initializeCalls, 0);
      expect(controller.errorMessage, contains('patient account'));
    });

    test('resume refreshes authoritative provider state', () async {
      final repository = _FakeFinancialRepository();
      final controller = AppointmentPaymentController(
        appointmentId: 'appointment-1',
        financialRepository: repository,
        sessionStore: _patientSession(),
        intentStore: InMemoryPaymentCheckoutIntentStore(),
        launcher: _FakeLauncher(),
        now: () => DateTime.parse('2026-07-29T10:00:00Z'),
      );
      await controller.load();
      await controller.beginCheckout();

      await controller.onAppResumed();

      expect(repository.refreshCalls, 1);
      expect(
        controller.view?.payment?.status,
        AppointmentPaymentStatus.succeeded,
      );
    });

    test(
      'successful checkout replay does not invent consultation confirmation',
      () async {
        final repository = _FakeFinancialRepository(
          checkoutStatus: AppointmentPaymentStatus.succeeded,
          refreshConsultationConfirmed: false,
        );
        final controller = AppointmentPaymentController(
          appointmentId: 'appointment-1',
          financialRepository: repository,
          sessionStore: _patientSession(),
          intentStore: InMemoryPaymentCheckoutIntentStore(),
          launcher: _FakeLauncher(),
          now: () => DateTime.parse('2026-07-29T10:00:00Z'),
        );
        await controller.load();

        await controller.beginCheckout();

        expect(controller.actionMessage, isNot(contains('confirmed')));
        expect(controller.view?.payment?.consultationConfirmed, isFalse);
      },
    );
  });

  group('Professional finance controller', () {
    test('loads authoritative price, balances and payout profile', () async {
      final repository = _FakeFinancialRepository();
      final controller = ProfessionalFinanceController(repository: repository);

      await controller.load();
      await controller.loadBanks();

      expect(controller.consultationPrice?.amountMinor, 1500000);
      expect(controller.summary?.heldMinor, 100000);
      expect(controller.payoutProfile?.maskedAccountNumber, '******1234');
      expect(controller.banks.single.name, 'Care Bank');
    });

    test('price and bank mutations remain backend confirmed', () async {
      final repository = _FakeFinancialRepository();
      final controller = ProfessionalFinanceController(repository: repository);
      await controller.load();

      await controller.savePrice(2000000);
      await controller.resolveBank(
        bankCode: '001',
        accountNumber: '0123456789',
      );
      await controller.confirmBank();

      expect(controller.consultationPrice?.amountMinor, 2000000);
      expect(repository.resolvedAccountNumber, '0123456789');
      expect(controller.pendingResolution, isNull);
      expect(controller.payoutProfile?.status, 'COOLING');
    });
  });
}

FinancialApiClient _client(_FakeAdapter adapter) {
  return FinancialApiClient(
    config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
    dio: Dio()..httpClientAdapter = adapter,
  );
}

Map<String, dynamic> _paymentViewJson({required String status}) {
  return <String, dynamic>{
    'appointmentId': 'appointment-1',
    'appointmentStatus': 'ACCEPTED',
    'pricing': <String, dynamic>{
      'currency': 'NGN',
      'grossAmountMinor': 1500000,
    },
    'payment': <String, dynamic>{
      'id': 'payment-1',
      'status': status,
      'dueAt': '2026-07-29T12:00:00.000Z',
      'succeededAt': status == 'SUCCEEDED' ? '2026-07-29T10:30:00.000Z' : null,
      'refundReviewAt': null,
      'consultationConfirmed': status == 'SUCCEEDED',
    },
  };
}

PaymentCheckoutIntent _paymentIntent() {
  return PaymentCheckoutIntent(
    appointmentId: 'appointment-1',
    accountUserId: 'patient-user-1',
    idempotencyKey: 'payment-key-1',
    createdAt: DateTime.parse('2026-07-29T10:00:00Z'),
    expiresAt: DateTime.parse('2026-07-29T12:00:00Z'),
  );
}

InMemorySessionStore _patientSession() {
  return InMemorySessionStore()..save(_session('PATIENT', 'patient-user-1'));
}

InMemorySessionStore _professionalSession() {
  return InMemorySessionStore()
    ..save(_session('PROFESSIONAL', 'professional-user-1'));
}

AuthSessionModel _session(String role, String id) {
  return AuthSessionModel.fromJson(<String, dynamic>{
    'accessToken': 'access-token',
    'refreshToken': 'refresh-token',
    'expiresIn': 900,
    'user': <String, dynamic>{
      'id': id,
      'email': 'care@example.com',
      'role': role,
      'status': 'ACTIVE',
      'emailVerified': true,
    },
  });
}

class _FakeLauncher implements HostedCheckoutLauncher {
  int openCalls = 0;

  @override
  Future<bool> open(Uri uri) async {
    openCalls += 1;
    return true;
  }
}

class _FakeFinancialRepository implements FinancialRepository {
  _FakeFinancialRepository({
    Uri? checkoutUri,
    this.checkoutStatus = AppointmentPaymentStatus.processing,
    this.refreshConsultationConfirmed = true,
  }) : checkoutUri =
           checkoutUri ?? Uri.parse('https://checkout.paystack.com/pay');

  final Uri checkoutUri;
  final AppointmentPaymentStatus checkoutStatus;
  final bool refreshConsultationConfirmed;
  int initializeCalls = 0;
  int refreshCalls = 0;
  String lastIdempotencyKey = '';
  String? resolvedAccountNumber;

  @override
  Future<AppointmentPaymentView> appointmentPayment(
    String appointmentId,
  ) async {
    return _paymentView(AppointmentPaymentStatus.awaitingPayment);
  }

  @override
  Future<PaymentCheckout> initializeCheckout({
    required String appointmentId,
    required String idempotencyKey,
  }) async {
    initializeCalls += 1;
    lastIdempotencyKey = idempotencyKey;
    return PaymentCheckout(
      appointmentId: appointmentId,
      status: checkoutStatus,
      attemptStatus: 'PENDING',
      authorizationUrl:
          checkoutStatus == AppointmentPaymentStatus.succeeded
              ? null
              : checkoutUri,
      dueAt: DateTime.parse('2026-07-29T12:00:00Z'),
    );
  }

  @override
  Future<AppointmentPaymentView> refreshPayment(String appointmentId) async {
    refreshCalls += 1;
    return _paymentView(
      AppointmentPaymentStatus.succeeded,
      consultationConfirmed: refreshConsultationConfirmed,
    );
  }

  @override
  Future<ConsultationPrice?> consultationPrice() async {
    return const ConsultationPrice(amountMinor: 1500000, currency: 'NGN');
  }

  @override
  Future<ConsultationPrice> updateConsultationPrice(int amountMinor) async {
    return ConsultationPrice(amountMinor: amountMinor, currency: 'NGN');
  }

  @override
  Future<List<FinanceBank>> banks() async {
    return const <FinanceBank>[
      FinanceBank(
        code: '001',
        name: 'Care Bank',
        currency: 'NGN',
        active: true,
      ),
    ];
  }

  @override
  Future<BankAccountResolution> resolveBankAccount({
    required String bankCode,
    required String accountNumber,
  }) async {
    resolvedAccountNumber = accountNumber;
    return BankAccountResolution(
      resolutionId: 'resolution-1',
      bankCode: bankCode,
      bankName: 'Care Bank',
      accountName: 'Ada Care',
      maskedAccountNumber: '******6789',
      expiresAt: DateTime.parse('2026-07-29T10:15:00Z'),
    );
  }

  @override
  Future<ProfessionalPayoutProfile> confirmBankAccount(
    String resolutionId,
  ) async {
    return _payoutProfile();
  }

  @override
  Future<ProfessionalPayoutProfile?> payoutProfile() async {
    return _payoutProfile();
  }

  @override
  Future<void> deactivatePayoutProfile() async {}

  @override
  Future<ProfessionalFinanceSummary> financeSummary() async {
    return _summary();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AppointmentPaymentView _paymentView(
  AppointmentPaymentStatus status, {
  bool? consultationConfirmed,
}) {
  return AppointmentPaymentView(
    appointmentId: 'appointment-1',
    appointmentStatus: AppointmentStatus.accepted,
    pricing: const AppointmentPricing(
      currency: 'NGN',
      grossAmountMinor: 1500000,
    ),
    payment: AppointmentPayment(
      id: 'payment-1',
      status: status,
      dueAt: DateTime.parse('2026-07-29T12:00:00Z'),
      succeededAt:
          status == AppointmentPaymentStatus.succeeded
              ? DateTime.parse('2026-07-29T10:30:00Z')
              : null,
      consultationConfirmed:
          consultationConfirmed ?? status == AppointmentPaymentStatus.succeeded,
    ),
  );
}

ProfessionalPayoutProfile _payoutProfile() {
  return ProfessionalPayoutProfile(
    id: 'profile-1',
    version: 1,
    bankCode: '001',
    bankName: 'Care Bank',
    accountName: 'Ada Care',
    maskedAccountNumber: '******1234',
    status: 'COOLING',
    coolingUntil: DateTime.parse('2026-08-01T10:00:00Z'),
    createdAt: DateTime.parse('2026-07-29T10:00:00Z'),
  );
}

ProfessionalFinanceSummary _summary() {
  return const ProfessionalFinanceSummary(
    currency: 'NGN',
    heldMinor: 100000,
    eligibleMinor: 200000,
    availableMinor: 200000,
    processingMinor: 0,
    paidMinor: 300000,
    negativeBalanceMinor: 0,
    payoutPaused: false,
    recentLedger: <ProfessionalLedgerEntry>[],
    payouts: <ProfessionalPayout>[],
  );
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.responseJson});

  final Map<String, dynamic> responseJson;
  RequestOptions? lastOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromString(
      jsonEncode(responseJson),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
