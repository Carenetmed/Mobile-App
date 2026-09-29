import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Home/data/repositories/financial_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/data/storage/payment_checkout_intent_store.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/consultation_price.dart';
import 'package:app_t/features/Home/domain/entities/financial_entities.dart';
import 'package:app_t/features/Home/domain/services/hosted_checkout_launcher.dart';
import 'package:app_t/features/Home/presentation/pages/appointment_experience_shell.dart';
import 'package:app_t/features/Home/presentation/pages/professional_finance_shell.dart';
import 'package:app_t/features/Home/presentation/state/appointment_payment_controller.dart';
import 'package:app_t/features/Home/presentation/state/professional_finance_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

void main() {
  testWidgets('patient sees authoritative amount and secure Paystack action', (
    tester,
  ) async {
    final sessionStore = _sessionStore('PATIENT');
    final financial = _FinanceRepository();
    final paymentController = AppointmentPaymentController(
      appointmentId: 'appointment-1',
      financialRepository: financial,
      sessionStore: sessionStore,
      intentStore: InMemoryPaymentCheckoutIntentStore(),
      launcher: _Launcher(),
      now: () => DateTime.parse('2026-07-29T10:00:00Z'),
    );

    await _pump(
      tester,
      AppointmentDetailShellPage(
        appointmentId: 'appointment-1',
        schedulingRepository: _SchedulingRepository(),
        sessionStore: sessionStore,
        paymentController: paymentController,
        now: DateTime.parse('2026-07-29T10:00:00Z'),
      ),
    );

    expect(find.text('Consultation payment'), findsOneWidget);
    expect(find.text('NGN 15,000.00'), findsOneWidget);
    expect(find.text('PAYMENT DUE'), findsOneWidget);
    expect(find.byKey(const Key('appointment-pay-now')), findsOneWidget);
    expect(
      find.textContaining('CareNet never handles card details'),
      findsOneWidget,
    );
    expect(find.text('Your net after commission'), findsNothing);
  });

  testWidgets(
    'professional sees net and never receives patient checkout action',
    (tester) async {
      final sessionStore = _sessionStore('PROFESSIONAL');
      final paymentController = AppointmentPaymentController(
        appointmentId: 'appointment-1',
        financialRepository: _FinanceRepository(),
        sessionStore: sessionStore,
        intentStore: InMemoryPaymentCheckoutIntentStore(),
        launcher: _Launcher(),
        now: () => DateTime.parse('2026-07-29T10:00:00Z'),
      );

      await _pump(
        tester,
        AppointmentDetailShellPage(
          appointmentId: 'appointment-1',
          schedulingRepository: _SchedulingRepository(),
          sessionStore: sessionStore,
          paymentController: paymentController,
          now: DateTime.parse('2026-07-29T10:00:00Z'),
        ),
      );

      expect(find.text('Your net after commission'), findsOneWidget);
      expect(find.text('NGN 12,750.00'), findsOneWidget);
      expect(find.byKey(const Key('appointment-pay-now')), findsNothing);
      expect(find.textContaining('Waiting for the patient'), findsOneWidget);
    },
  );

  testWidgets(
    'professional finance presents commission, balances and masked bank',
    (tester) async {
      final controller = ProfessionalFinanceController(
        repository: _FinanceRepository(),
      );

      await _pump(tester, ProfessionalFinanceShellPage(controller: controller));

      expect(find.text('Payments & payouts'), findsOneWidget);
      expect(find.text('NGN 15,000.00'), findsOneWidget);
      expect(find.text('CareNet commission (15%)'), findsOneWidget);
      expect(find.text('NGN 2,250.00'), findsOneWidget);
      expect(find.text('NGN 12,750.00'), findsNWidgets(2));
      expect(find.text('Held'), findsOneWidget);
      expect(find.textContaining('instant withdrawal'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();
      expect(find.text('Cooling period'), findsOneWidget);
      expect(find.textContaining('******1234'), findsOneWidget);
      expect(find.textContaining('recipient'), findsNothing);
    },
  );

  testWidgets('professional finance fits a compact screen with 2x text', (
    tester,
  ) async {
    final controller = ProfessionalFinanceController(
      repository: _FinanceRepository(
        hasPayoutProfile: false,
        includeActivity: true,
      ),
    );

    await _pump(
      tester,
      ProfessionalFinanceShellPage(controller: controller),
      screenSize: const Size(320, 568),
      textScaler: const TextScaler.linear(2),
    );

    expect(find.text('Payments & payouts'), findsOneWidget);
    expect(find.text('Your consultation finances'), findsOneWidget);
    expect(tester.takeException(), isNull);

    for (var i = 0; i < 8; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    for (var i = 0; i < 8; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    for (var i = 0; i < 8; i++) {
      if (find.byKey(const Key('payout-bank-selector')).evaluate().isNotEmpty) {
        break;
      }
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.byKey(const Key('payout-bank-selector')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('payout-bank-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payout-bank-selector')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Care Bank').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Care Bank').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('payout-account-number')),
      '0123456789',
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('bank details become resolvable only after valid input', (
    tester,
  ) async {
    final controller = ProfessionalFinanceController(
      repository: _FinanceRepository(hasPayoutProfile: false),
    );

    await _pump(tester, ProfessionalFinanceShellPage(controller: controller));
    await tester.drag(find.byType(ListView), const Offset(0, -650));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('payout-bank-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Care Bank').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('payout-account-number')),
      '0123456789',
    );
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('resolve-payout-account')),
    );
    expect(button.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('resolve-payout-account')));
    await tester.pumpAndSettle();
    expect(find.text('Confirm resolved account'), findsOneWidget);
    expect(find.textContaining('******6789'), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  Size screenSize = _phoneSize,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.physicalSize = screenSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (context, _) => MaterialApp(
            home: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: home,
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

class _SchedulingRepository implements SchedulingRepository {
  @override
  Future<List<AppointmentSummary>> ownAppointments() async {
    return <AppointmentSummary>[
      AppointmentSummary(
        id: 'appointment-1',
        patientProfileId: 'patient-1',
        professionalProfileId: 'professional-1',
        requestedStartAt: DateTime.parse('2026-07-30T11:00:00Z'),
        durationMinutes: 30,
        status: AppointmentStatus.accepted,
        pricing: const AppointmentPricing(
          currency: 'NGN',
          grossAmountMinor: 1500000,
          professionalNetMinor: 1275000,
        ),
        payment: AppointmentPayment(
          status: AppointmentPaymentStatus.awaitingPayment,
          dueAt: DateTime.parse('2026-07-29T12:00:00Z'),
          consultationConfirmed: false,
        ),
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FinanceRepository implements FinancialRepository {
  _FinanceRepository({
    this.hasPayoutProfile = true,
    this.includeActivity = false,
  });

  final bool hasPayoutProfile;
  final bool includeActivity;

  @override
  Future<AppointmentPaymentView> appointmentPayment(
    String appointmentId,
  ) async {
    return AppointmentPaymentView(
      appointmentId: appointmentId,
      appointmentStatus: AppointmentStatus.accepted,
      pricing: const AppointmentPricing(
        currency: 'NGN',
        grossAmountMinor: 1500000,
        platformFeeMinor: 225000,
        professionalNetMinor: 1275000,
      ),
      payment: AppointmentPayment(
        id: 'payment-1',
        status: AppointmentPaymentStatus.awaitingPayment,
        dueAt: DateTime.parse('2026-07-29T12:00:00Z'),
        consultationConfirmed: false,
      ),
    );
  }

  @override
  Future<ConsultationPrice?> consultationPrice() async {
    return const ConsultationPrice(amountMinor: 1500000, currency: 'NGN');
  }

  @override
  Future<ProfessionalFinanceSummary> financeSummary() async {
    return ProfessionalFinanceSummary(
      currency: 'NGN',
      heldMinor: 1275000,
      eligibleMinor: 0,
      availableMinor: 0,
      processingMinor: 0,
      paidMinor: 0,
      negativeBalanceMinor: 0,
      payoutPaused: false,
      recentLedger:
          includeActivity
              ? <ProfessionalLedgerEntry>[
                ProfessionalLedgerEntry(
                  id: 'ledger-1',
                  type: 'CONSULTATION_EARNING',
                  amountMinor: 1275000,
                  currency: 'NGN',
                  eligibleAt: DateTime.parse('2026-08-01T10:00:00Z'),
                  descriptionCode: 'CONSULTATION_EARNING',
                  createdAt: DateTime.parse('2026-07-29T10:00:00Z'),
                  reserved: false,
                ),
              ]
              : <ProfessionalLedgerEntry>[],
      payouts:
          includeActivity
              ? <ProfessionalPayout>[
                ProfessionalPayout(
                  id: 'payout-1',
                  status: 'FAILED',
                  mode: 'MANUAL',
                  amountMinor: 1275000,
                  currency: 'NGN',
                  bankName: 'Care Bank',
                  maskedAccountNumber: '******1234',
                  failureCode: 'BENEFICIARY_ACCOUNT_UNAVAILABLE',
                  createdAt: DateTime.parse('2026-07-29T10:00:00Z'),
                ),
              ]
              : <ProfessionalPayout>[],
    );
  }

  @override
  Future<ProfessionalPayoutProfile?> payoutProfile() async {
    if (!hasPayoutProfile) {
      return null;
    }
    return ProfessionalPayoutProfile(
      id: 'payout-profile-1',
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
    return BankAccountResolution(
      resolutionId: 'resolution-1',
      bankCode: bankCode,
      bankName: 'Care Bank',
      accountName: 'Ada Care',
      maskedAccountNumber: '******${accountNumber.substring(6)}',
      expiresAt: DateTime.parse('2026-07-29T10:15:00Z'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Launcher implements HostedCheckoutLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

InMemorySessionStore _sessionStore(String role) {
  return InMemorySessionStore()..save(
    AuthSessionModel.fromJson(<String, dynamic>{
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
      'expiresIn': 900,
      'user': <String, dynamic>{
        'id': '${role.toLowerCase()}-user-1',
        'email': 'care@example.com',
        'role': role,
        'status': 'ACTIVE',
        'emailVerified': true,
      },
    }),
  );
}
