import 'dart:ui' show SemanticsAction;

import 'package:app_t/core/constants/navigators/router.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/config/carenet_public_links.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/account_deletion_receipt.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/Authentication/presentation/pages/email_verification_confirm_page.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/data/storage/booking_intent_store.dart';
import 'package:app_t/features/Home/data/storage/payment_checkout_intent_store.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/booking_intent.dart';
import 'package:app_t/features/Home/domain/entities/payment_checkout_intent.dart';
import 'package:app_t/features/Home/domain/entities/patient_profile.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/presentation/pages/dashboard.dart';
import 'package:app_t/features/Home/presentation/pages/account_shell.dart';
import 'package:app_t/features/Home/presentation/pages/edit_email_shell.dart';
import 'package:app_t/features/Home/presentation/state/account_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpDashboard(WidgetTester tester) async {
  AccountLocalStore.reset();
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final sessionStore = InMemorySessionStore();
  await sessionStore.save(
    const AuthSessionModel(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      tokenType: 'Bearer',
      expiresIn: 900,
      user: AuthUser(
        id: 'patient-1',
        email: 'patient@carenet.app',
        role: 'PATIENT',
        status: 'ACTIVE',
        emailVerified: true,
      ),
    ),
  );

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder: (_, __) => MaterialApp(
        home: Dashboard(
          sessionStore: sessionStore,
          profileRepository: _FakeProfileRepository(
            patientProfile: const PatientProfile(name: 'Patient'),
          ),
          onboardingRepository: const _DashboardOnboardingRepository(),
          schedulingRepository: const _DashboardSchedulingRepository(),
        ),
        onGenerateRoute: generateRoute,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openAccount(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Account'));
  await tester.pumpAndSettle();
}

Future<void> _pumpAccount(
  WidgetTester tester, {
  required _FakeAuthRepository repository,
  Size screenSize = _phoneSize,
  TextScaler textScaler = TextScaler.noScaling,
  _FakeAccountRepository? accountRepository,
  GoogleIdTokenProvider? googleIdTokenProvider,
  BookingIntentStore? bookingIntentStore,
  PaymentCheckoutIntentStore? paymentCheckoutIntentStore,
  PublicLinkLauncher? publicLinkLauncher,
}) async {
  AccountLocalStore.reset();
  tester.view.physicalSize = screenSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder: (_, __) => MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: AccountShellPage(
          authRepository: repository,
          accountRepository: accountRepository,
          googleIdTokenProvider: googleIdTokenProvider,
          bookingIntentStore: bookingIntentStore,
          paymentCheckoutIntentStore: paymentCheckoutIntentStore,
          publicLinkLauncher: publicLinkLauncher,
        ),
        routes: <String, WidgetBuilder>{
          RouteName.onboarding: (_) => const Scaffold(body: Text('onboarding')),
          RouteName.manageProfile: (_) =>
              const Scaffold(body: Text('manage-profile-route')),
          RouteName.professionalVerificationDocuments: (_) =>
              const Scaffold(body: Text('verification-documents-route')),
          RouteName.professionalFinance: (_) =>
              const Scaffold(body: Text('professional-finance-route')),
          RouteName.notificationPreferences: (_) =>
              const Scaffold(body: Text('notification-preferences-route')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpEditEmail(
  WidgetTester tester, {
  required _FakeAccountRepository repository,
}) async {
  AccountLocalStore.reset();
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder: (_, __) => MaterialApp(
        home: EditEmailShellPage(accountRepository: repository),
        routes: <String, WidgetBuilder>{
          RouteName.changeEmail: (_) =>
              const Scaffold(body: Text('change-email')),
          RouteName.enterPasswordToSave: (_) =>
              const Scaffold(body: Text('password-step')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpSettingsProfile(
  WidgetTester tester, {
  required _FakeProfileRepository profileRepository,
}) async {
  AccountLocalStore.reset();
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder: (_, __) => MaterialApp(
        home: SettingsProfilePage(profileRepository: profileRepository),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('account tiles remain reachable at compact width with 2x text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: _FakeAccountRepository(),
      screenSize: const Size(320, 568),
      textScaler: const TextScaler.linear(2),
    );

    expect(find.text('Account security'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Delete account'),
      160,
      scrollable: find.byType(Scrollable).last,
    );

    final deleteTile = find.ancestor(
      of: find.text('Delete account'),
      matching: find.byType(ListTile),
    );
    expect(deleteTile, findsOneWidget);
    expect(tester.getSize(deleteTile).height, greaterThanOrEqualTo(48));
    final node = tester.getSemantics(deleteTile);
    expect(node.label, contains('Delete account'));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'account status and actions are announced and operable with large text',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await _pumpAccount(
          tester,
          repository: _FakeAuthRepository(
            failure: const AuthFailure(
              type: AuthFailureType.server,
              message: 'Could not log out. Please try again.',
            ),
          ),
          accountRepository: _FakeAccountRepository(
            failure: const AuthFailure(
              type: AuthFailureType.unauthorized,
              message: 'Please sign in again.',
            ),
          ),
          screenSize: const Size(320, 568),
          textScaler: const TextScaler.linear(2),
        );

        expect(tester.takeException(), isNull);
        final back = find.byTooltip('Back');
        expect(
          tester.getSemantics(back).getSemanticsData().hasAction(
                SemanticsAction.tap,
              ),
          isTrue,
        );
        expect(tester.getSize(back).height, greaterThanOrEqualTo(48));

        final securityTile = find.ancestor(
          of: find.text('Account security'),
          matching: find.byType(ListTile),
        );
        expect(securityTile, findsOneWidget);
        expect(
          tester
              .getSemantics(securityTile)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isFalse,
        );
        final accountStatus = tester.getSemantics(
          find.text('Account details unavailable'),
        );
        expect(
          accountStatus.getSemanticsData().flagsCollection.isLiveRegion,
          isTrue,
        );
        expect(
          tester
              .getSemantics(find.text('Please sign in again.'))
              .getSemanticsData()
              .flagsCollection
              .isLiveRegion,
          isTrue,
        );

        await tester.scrollUntilVisible(
          find.text('Notification preferences'),
          120,
          scrollable: find.byType(Scrollable).last,
        );
        final preferencesTile = find.ancestor(
          of: find.text('Notification preferences'),
          matching: find.byType(ListTile),
        );
        expect(
          tester
              .getSemantics(preferencesTile)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
        );
        expect(
          tester.getSize(preferencesTile).height,
          greaterThanOrEqualTo(48),
        );

        await tester.scrollUntilVisible(
          find.text('Log out'),
          120,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.drag(
          find.byType(Scrollable).last,
          const Offset(0, -140),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Log out'));
        await tester.pumpAndSettle();
        expect(find.text('Could not log out. Please try again.'), findsOneWidget);
        expect(
          tester
              .getSemantics(
                find.text('Could not log out. Please try again.'),
              )
              .getSemanticsData()
              .flagsCollection
              .isLiveRegion,
          isTrue,
        );
        expect(find.text('Account'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.scrollUntilVisible(
          find.text('Delete account'),
          120,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.drag(
          find.byType(Scrollable).last,
          const Offset(0, -140),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete account'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Type DELETE to confirm'),
          'DELETE',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Current password'),
          'CareNet@123',
        );
        await tester.pump();
        final confirmDeletion = find.widgetWithText(
          FilledButton,
          'Delete account',
        );
        await tester.ensureVisible(confirmDeletion);
        await tester.pumpAndSettle();
        await tester.tap(confirmDeletion);
        await tester.pumpAndSettle();
        final deletionError = tester.getSemantics(
          find.text('Your recent authentication was not accepted. Try again.'),
        );
        expect(
          deletionError.getSemanticsData().flagsCollection.isLiveRegion,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('header avatar opens the account page', (tester) async {
    await _pumpDashboard(tester);

    await _openAccount(tester);

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Delete account'), findsWidgets);
  });

  testWidgets('account opens canonical support and legal pages', (tester) async {
    final opened = <Uri>[];
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: _FakeAccountRepository(),
      publicLinkLauncher: (uri) async {
        opened.add(uri);
        return true;
      },
    );

    await tester.scrollUntilVisible(find.text('Support'), 300);
    await tester.tap(find.text('Support'));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Privacy and legal'), 300);
    await tester.tap(find.text('Privacy and legal'));
    await tester.pump();

    expect(opened, <Uri>[
      CareNetPublicLinks.support,
      CareNetPublicLinks.privacy,
    ]);
  });

  testWidgets('account area opens transactional notification preferences', (
    tester,
  ) async {
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: _FakeAccountRepository(
        user: const AuthUser(
          id: 'patient-1',
          email: 'patient@carenet.app',
          role: 'PATIENT',
          status: 'ACTIVE',
          emailVerified: true,
        ),
      ),
    );

    await tester.scrollUntilVisible(find.text('Notification preferences'), 200);
    await tester.tap(find.text('Notification preferences'));
    await tester.pumpAndSettle();

    expect(find.text('notification-preferences-route'), findsOneWidget);
  });

  testWidgets('logout clears session and returns to onboarding', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final bookingIntentStore = InMemoryBookingIntentStore();
    final paymentIntentStore = InMemoryPaymentCheckoutIntentStore();
    await bookingIntentStore.save(
      BookingIntent(
        professionalProfileId: 'professional-1',
        startAt: DateTime.utc(2026, 7, 24, 9),
        endAt: DateTime.utc(2026, 7, 24, 9, 30),
        durationMinutes: 30,
        idempotencyKey: 'booking-key',
        resumeRoute: RouteName.specialistDetails,
        createdAt: DateTime.utc(2026, 7, 23),
        expiresAt: DateTime.utc(2027, 7, 23),
      ),
    );
    await paymentIntentStore.save(
      PaymentCheckoutIntent(
        appointmentId: 'appointment-1',
        accountUserId: 'patient-1',
        idempotencyKey: 'payment-key',
        createdAt: DateTime.utc(2026, 7, 23),
        expiresAt: DateTime.utc(2027, 7, 23),
      ),
    );
    await _pumpAccount(
      tester,
      repository: repository,
      bookingIntentStore: bookingIntentStore,
      paymentCheckoutIntentStore: paymentIntentStore,
    );

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(repository.logoutCalls, 1);
    expect(await bookingIntentStore.read(), isNull);
    expect(paymentIntentStore.value, isNull);
    expect(find.text('onboarding'), findsOneWidget);
    expect(find.text('Account'), findsNothing);
  });

  testWidgets('account displays backend current account when available', (
    tester,
  ) async {
    final repository = _FakeAccountRepository(
      user: const AuthUser(
        id: 'user-1',
        email: 'backend-patient@carenet.app',
        role: 'PATIENT',
        status: 'ACTIVE',
        emailVerified: true,
      ),
    );
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: repository,
    );

    expect(repository.currentAccountCalls, 1);
    expect(find.text('backend-patient@carenet.app'), findsOneWidget);
    expect(find.text('PATIENT account - active'), findsOneWidget);
    expect(find.text('doctor@carenet.app'), findsNothing);
  });

  testWidgets('professional account exposes manage profile route', (
    tester,
  ) async {
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: _FakeAccountRepository(
        user: const AuthUser(
          id: 'professional-1',
          email: 'professional@carenet.app',
          role: 'PROFESSIONAL',
          status: 'ACTIVE',
          emailVerified: true,
        ),
      ),
    );

    expect(find.text('PROFESSIONAL account - active'), findsOneWidget);
    expect(find.text('Manage Profile'), findsOneWidget);
    expect(
      find.text('Professional profile and verification documents'),
      findsOneWidget,
    );
    expect(find.text('Verification documents'), findsOneWidget);
    expect(
      find.text('Upload and review professional documents'),
      findsOneWidget,
    );

    await tester.tap(find.text('Manage Profile'));
    await tester.pumpAndSettle();

    expect(find.text('manage-profile-route'), findsOneWidget);
  });

  testWidgets('professional account opens verification documents route', (
    tester,
  ) async {
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: _FakeAccountRepository(
        user: const AuthUser(
          id: 'professional-1',
          email: 'professional@carenet.app',
          role: 'PROFESSIONAL',
          status: 'ACTIVE',
          emailVerified: true,
        ),
      ),
    );

    await tester.tap(find.text('Verification documents'));
    await tester.pumpAndSettle();

    expect(find.text('verification-documents-route'), findsOneWidget);
  });

  testWidgets('professional account opens payments and payouts route', (
    tester,
  ) async {
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: _FakeAccountRepository(
        user: const AuthUser(
          id: 'professional-1',
          email: 'professional@carenet.app',
          role: 'PROFESSIONAL',
          status: 'ACTIVE',
          emailVerified: true,
        ),
      ),
    );

    expect(find.text('Payments & payouts'), findsOneWidget);
    await tester.tap(find.text('Payments & payouts'));
    await tester.pumpAndSettle();

    expect(find.text('professional-finance-route'), findsOneWidget);
  });

  testWidgets('patient account does not expose professional manage profile', (
    tester,
  ) async {
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: _FakeAccountRepository(
        user: const AuthUser(
          id: 'patient-1',
          email: 'patient@carenet.app',
          role: 'PATIENT',
          status: 'ACTIVE',
          emailVerified: true,
        ),
      ),
    );

    expect(find.text('PATIENT account - active'), findsOneWidget);
    expect(find.text('Manage Profile'), findsNothing);
    expect(find.text('Verification documents'), findsNothing);
    expect(find.text('Payments & payouts'), findsNothing);
    expect(find.text('View or edit profile'), findsOneWidget);
  });

  testWidgets('account exposes Google link entry below authentication', (
    tester,
  ) async {
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: _FakeAccountRepository(),
      googleIdTokenProvider: _FakeGoogleIdTokenProvider(),
    );

    expect(find.text('Account security'), findsOneWidget);
    expect(find.text('Google account'), findsOneWidget);
    expect(find.text('View or edit profile'), findsOneWidget);

    final authenticationTop = tester
        .getTopLeft(find.text('Account security'))
        .dy;
    final googleTop = tester.getTopLeft(find.text('Google account')).dy;
    final settingsTop = tester.getTopLeft(find.text('View or edit profile')).dy;
    expect(authenticationTop < googleTop, isTrue);
    expect(googleTop < settingsTop, isTrue);
  });

  testWidgets('Google link stays disabled without provider config', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final provider = _FakeGoogleIdTokenProvider(isConfigured: false);
    await _pumpAccount(
      tester,
      repository: authRepository,
      accountRepository: _FakeAccountRepository(),
      googleIdTokenProvider: provider,
    );

    await tester.tap(find.text('Google account'));
    await tester.pumpAndSettle();

    expect(provider.signInCalls, 0);
    expect(authRepository.googleLinkCalls, 0);
    expect(
      find.text('Google account linking is not configured yet.'),
      findsOneWidget,
    );
  });

  testWidgets('Google link sends real provider token to repository', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final authRepository = _FakeAuthRepository();
    final accountRepository = _FakeAccountRepository(
      user: const AuthUser(
        id: 'user-1',
        email: 'backend-patient@carenet.app',
        role: 'PATIENT',
        status: 'ACTIVE',
        emailVerified: true,
      ),
    );
    final provider = _FakeGoogleIdTokenProvider(idToken: 'link-id-token');
    await _pumpAccount(
      tester,
      repository: authRepository,
      accountRepository: accountRepository,
      googleIdTokenProvider: provider,
    );

    await tester.tap(find.text('Google account'));
    await tester.pumpAndSettle();

    expect(provider.signInCalls, 1);
    expect(authRepository.googleLinkCalls, 1);
    expect(authRepository.lastGoogleLinkIdToken, 'link-id-token');
    expect(find.text('Google account linked.'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.text('Google account linked.'))
          .getSemanticsData()
          .flagsCollection
          .isLiveRegion,
      isTrue,
    );
    expect(find.text('backend-patient@carenet.app'), findsOneWidget);
    expect(find.text('PATIENT account - active'), findsOneWidget);
    expect(find.text('link-id-token'), findsNothing);
    expect(find.text('Google sign-up'), findsNothing);
    expect(find.text('Unlink Google'), findsNothing);
    expect(find.text('Production OAuth'), findsNothing);
    semantics.dispose();
  });

  testWidgets('Google provider failure shows safe copy without link call', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final provider = _FakeGoogleIdTokenProvider(
      failure: const AuthFailure(
        type: AuthFailureType.validation,
        message: 'Google sign-in was cancelled.',
      ),
    );
    await _pumpAccount(
      tester,
      repository: authRepository,
      accountRepository: _FakeAccountRepository(),
      googleIdTokenProvider: provider,
    );

    await tester.tap(find.text('Google account'));
    await tester.pumpAndSettle();

    expect(provider.signInCalls, 1);
    expect(authRepository.googleLinkCalls, 0);
    expect(find.text('Google sign-in was cancelled.'), findsOneWidget);
    expect(find.text('Google account linked.'), findsNothing);
  });

  testWidgets('Google backend validation failure hides raw backend error', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository(
      googleLinkFailure: const AuthFailure(
        type: AuthFailureType.validation,
        message: 'raw google collision from backend',
      ),
    );
    await _pumpAccount(
      tester,
      repository: authRepository,
      accountRepository: _FakeAccountRepository(),
      googleIdTokenProvider: _FakeGoogleIdTokenProvider(),
    );

    await tester.tap(find.text('Google account'));
    await tester.pumpAndSettle();

    expect(authRepository.googleLinkCalls, 1);
    expect(
      find.text('This Google account cannot be linked here.'),
      findsOneWidget,
    );
    expect(find.text('raw google collision from backend'), findsNothing);
    expect(find.text('Google account linked.'), findsNothing);
  });

  testWidgets('Google backend unauthorized failure asks for sign in again', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository(
      googleLinkFailure: const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'raw unauthorized backend message',
      ),
    );
    await _pumpAccount(
      tester,
      repository: authRepository,
      accountRepository: _FakeAccountRepository(),
      googleIdTokenProvider: _FakeGoogleIdTokenProvider(),
    );

    await tester.tap(find.text('Google account'));
    await tester.pumpAndSettle();

    expect(authRepository.googleLinkCalls, 1);
    expect(find.text('Please sign in again.'), findsOneWidget);
    expect(find.text('raw unauthorized backend message'), findsNothing);
    expect(find.text('Google account linked.'), findsNothing);
  });

  testWidgets('account read failure never falls back to seeded identity', (
    tester,
  ) async {
    final repository = _FakeAccountRepository(
      failure: const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
      ),
    );
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: repository,
    );

    expect(repository.currentAccountCalls, 1);
    expect(find.text('Please sign in again.'), findsOneWidget);
    expect(find.text('doctor@carenet.app'), findsNothing);
    expect(find.text('Unavailable'), findsOneWidget);
    expect(find.text('Account details unavailable'), findsOneWidget);
  });

  testWidgets('logout failure shows safe error without navigation', (
    tester,
  ) async {
    final repository = _FakeAuthRepository(
      failure: const AuthFailure(
        type: AuthFailureType.server,
        message: 'Could not log out. Please try again.',
      ),
    );
    await _pumpAccount(tester, repository: repository);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(repository.logoutCalls, 1);
    expect(find.text('Could not log out. Please try again.'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('onboarding'), findsNothing);
  });

  testWidgets('password reauthentication deletes account and signs out', (
    tester,
  ) async {
    final accountRepository = _FakeAccountRepository();
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: accountRepository,
    );
    await tester.scrollUntilVisible(find.text('Delete account'), 200);
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    expect(find.text('Delete your CareNet account?'), findsOneWidget);
    expect(find.textContaining('retention policy'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Type DELETE to confirm'),
      'DELETE',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Current password'),
      'CareNet@123',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete account'));
    await tester.pumpAndSettle();

    expect(accountRepository.deletionCalls, 1);
    expect(accountRepository.lastDeletionPassword, 'CareNet@123');
    expect(accountRepository.lastDeletionGoogleToken, isNull);
    expect(find.text('Account deletion requested'), findsOneWidget);
    expect(find.textContaining('all sessions were signed out'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('onboarding'), findsOneWidget);
  });

  testWidgets('Google reauthentication sends provider token without password', (
    tester,
  ) async {
    final accountRepository = _FakeAccountRepository();
    final googleProvider = _FakeGoogleIdTokenProvider(
      idToken: 'fresh-google-id-token',
    );
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: accountRepository,
      googleIdTokenProvider: googleProvider,
    );
    await tester.scrollUntilVisible(find.text('Delete account'), 200);
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Type DELETE to confirm'),
      'DELETE',
    );
    await tester.pump();
    await tester.tap(find.text('Verify with Google'));
    await tester.pumpAndSettle();

    expect(googleProvider.signInCalls, 1);
    expect(accountRepository.lastDeletionGoogleToken, 'fresh-google-id-token');
    expect(accountRepository.lastDeletionPassword, isNull);
    expect(find.text('fresh-google-id-token'), findsNothing);
  });

  testWidgets('direct delete route opens canonical account authority', (
    tester,
  ) async {
    await _pumpDashboard(tester);
    Navigator.of(
      tester.element(find.byType(Dashboard)),
    ).pushNamed(RouteName.deleteAccount);
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
    expect(
      find.textContaining('not available in CareNet Phase 1'),
      findsNothing,
    );
  });
  testWidgets('direct local settings route fails closed', (tester) async {
    await _pumpDashboard(tester);
    Navigator.of(
      tester.element(find.byType(Dashboard)),
    ).pushNamed(RouteName.settings);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('not available in CareNet Phase 1'),
      findsOneWidget,
    );
    expect(find.text('Settings & Profile'), findsNothing);
  });
  testWidgets('settings profile reads backend patient profile safely', (
    tester,
  ) async {
    final repository = _FakeProfileRepository(
      patientProfile: const PatientProfile(
        id: 'patient-1',
        name: 'Ada Lovelace',
        age: 37,
        location: 'Lagos',
      ),
    );
    await _pumpSettingsProfile(tester, profileRepository: repository);

    expect(repository.patientMeCalls, 1);
    expect(find.text('Ada Lovelace'), findsWidgets);
    expect(
      find.text('Backend name: Ada Lovelace\nAge: 37\nLocation: Lagos'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Ada'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Lovelace'), findsOneWidget);
  });

  testWidgets('settings profile shows empty backend profile state', (
    tester,
  ) async {
    final repository = _FakeProfileRepository();
    await _pumpSettingsProfile(tester, profileRepository: repository);

    expect(repository.patientMeCalls, 1);
    expect(
      find.text(
        'No backend patient profile yet. Local settings remain editable.',
      ),
      findsOneWidget,
    );
    expect(find.text('Lagbaja Tamedu'), findsOneWidget);
  });

  testWidgets('settings profile shows patient profile failure safely', (
    tester,
  ) async {
    final repository = _FakeProfileRepository(
      failure: const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
      ),
    );
    await _pumpSettingsProfile(tester, profileRepository: repository);

    expect(repository.patientMeCalls, 1);
    expect(find.text('Please sign in again.'), findsOneWidget);
    expect(find.text('Lagbaja Tamedu'), findsOneWidget);
  });

  testWidgets('settings profile saves backend patient name only', (
    tester,
  ) async {
    final repository = _FakeProfileRepository(
      patientProfile: const PatientProfile(
        id: 'patient-1',
        name: 'Ada Lovelace',
        age: 37,
        location: 'Lagos',
      ),
    );
    await _pumpSettingsProfile(tester, profileRepository: repository);

    await tester.enterText(find.widgetWithText(TextFormField, 'Ada'), 'Grace');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Lovelace'),
      'Hopper',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'lagbaja_carenet'),
      'lagbaja_new',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'doctor@carenet.app'),
      'newdoctor@carenet.app',
    );
    await tester.enterText(
      find.widgetWithText(
        TextFormField,
        'Husband | Father | Anonymous | Needs help constantly',
      ),
      'Local test bio update',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(repository.patientMeCalls, 1);
    expect(repository.updatePatientMeCalls, 1);
    expect(repository.lastUpdatedName, 'Grace Hopper');
    expect(repository.lastUpdatedAge, isNull);
    expect(repository.lastUpdatedLocation, isNull);
    expect(AccountLocalStore.snapshot.value.firstName, 'Grace');
    expect(AccountLocalStore.snapshot.value.lastName, 'Hopper');
    expect(AccountLocalStore.snapshot.value.email, 'newdoctor@carenet.app');
    expect(AccountLocalStore.snapshot.value.bio, 'Local test bio update');
  });

  testWidgets('settings profile blocks false success on patient name failure', (
    tester,
  ) async {
    final repository = _FakeProfileRepository(
      updateFailure: const AuthFailure(
        type: AuthFailureType.server,
        message: 'Service is unavailable. Please try again.',
      ),
    );
    await _pumpSettingsProfile(tester, profileRepository: repository);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Lagbaja'),
      'Grace',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tamedu'),
      'Hopper',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'lagbaja_carenet'),
      'lagbaja_new',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(repository.updatePatientMeCalls, 1);
    expect(
      find.text('Service is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(AccountLocalStore.snapshot.value.firstName, 'Lagbaja');
    expect(AccountLocalStore.snapshot.value.username, 'lagbaja_carenet');
  });

  testWidgets('local PIN authentication route fails closed', (tester) async {
    await _pumpDashboard(tester);
    Navigator.of(
      tester.element(find.byType(Dashboard)),
    ).pushNamed(RouteName.changeAuthentication);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('not available in CareNet Phase 1'),
      findsOneWidget,
    );
    expect(find.text('Two-step verification'), findsNothing);
  });
  testWidgets('account does not expose unsupported phone mutation', (
    tester,
  ) async {
    await _pumpDashboard(tester);
    await _openAccount(tester);

    expect(find.text('Phone number'), findsNothing);
    expect(find.text('+234 801 234 5678'), findsNothing);
  });
  testWidgets('direct phone confirmation route fails closed', (tester) async {
    await _pumpDashboard(tester);
    Navigator.of(
      tester.element(find.byType(Dashboard)),
    ).pushNamed(RouteName.confirmPhoneNumber);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('not available in CareNet Phase 1'),
      findsOneWidget,
    );
    expect(find.text('Confirm phone number'), findsNothing);
  });
  testWidgets('account email is backend-owned and read only', (tester) async {
    await _pumpAccount(
      tester,
      repository: _FakeAuthRepository(),
      accountRepository: _FakeAccountRepository(
        user: const AuthUser(
          id: 'patient-1',
          email: 'patient@carenet.app',
          role: 'PATIENT',
          status: 'ACTIVE',
          emailVerified: true,
        ),
      ),
    );

    expect(find.text('patient@carenet.app'), findsOneWidget);
    expect(find.text('Add email address'), findsNothing);
  });
  testWidgets('direct local email-change route fails closed', (tester) async {
    await _pumpDashboard(tester);
    Navigator.of(
      tester.element(find.byType(Dashboard)),
    ).pushNamed(RouteName.changeEmail);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('not available in CareNet Phase 1'),
      findsOneWidget,
    );
    expect(find.text('Change your email address'), findsNothing);
  });
  testWidgets('direct local email-review route fails closed', (tester) async {
    await _pumpDashboard(tester);
    Navigator.of(
      tester.element(find.byType(Dashboard)),
    ).pushNamed(RouteName.editEmail);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('not available in CareNet Phase 1'),
      findsOneWidget,
    );
    expect(find.text('Review current email'), findsNothing);
  });
  testWidgets('review current email requests verification through repository', (
    tester,
  ) async {
    final repository = _FakeAccountRepository();
    await _pumpEditEmail(tester, repository: repository);

    await tester.tap(find.text('Send verification email'));
    await tester.pumpAndSettle();

    expect(repository.requestEmailVerificationCalls, 1);
    expect(find.textContaining('Verification email requested'), findsOneWidget);
    expect(
      find.textContaining('secure token from the email link'),
      findsOneWidget,
    );
  });

  testWidgets(
    'review current email shows verification request failure safely',
    (tester) async {
      final repository = _FakeAccountRepository(
        failure: const AuthFailure(
          type: AuthFailureType.unauthorized,
          message: 'Please sign in again.',
        ),
      );
      await _pumpEditEmail(tester, repository: repository);

      await tester.tap(find.text('Send verification email'));
      await tester.pumpAndSettle();

      expect(repository.requestEmailVerificationCalls, 1);
      expect(find.text('Please sign in again.'), findsOneWidget);
      expect(find.text('Email address'), findsWidgets);
    },
  );

  testWidgets('email verification confirm uses token and refreshes account', (
    tester,
  ) async {
    final repository = _FakeAccountRepository(
      user: const AuthUser(
        id: 'user-1',
        email: 'verified@carenet.app',
        role: 'PATIENT',
        status: 'ACTIVE',
        emailVerified: true,
      ),
    );
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _phoneSize,
        builder: (context, _) => MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
            ),
            child: child!,
          ),
          home: EmailVerificationConfirmPage(
            token: 'opaque-verification-token',
            accountRepository: repository,
          ),
          routes: <String, WidgetBuilder>{
            RouteName.account: (_) => const Scaffold(body: Text('account')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verify email'), findsOneWidget);
    expect(find.text('Confirm your email address'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final confirmVerification = find.text('Confirm verification');
    await tester.scrollUntilVisible(
      confirmVerification,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(confirmVerification);
    await tester.pumpAndSettle();

    expect(repository.confirmEmailVerificationCalls, 1);
    expect(repository.lastVerificationToken, 'opaque-verification-token');
    expect(repository.currentAccountCalls, 1);
    expect(find.textContaining('Email verified'), findsOneWidget);

    final backToAccount = find.text('Back to account');
    await tester.scrollUntilVisible(
      backToAccount,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(backToAccount);
    await tester.pumpAndSettle();

    expect(find.text('account'), findsOneWidget);
  });

  testWidgets('email verification confirm handles missing token', (
    tester,
  ) async {
    final repository = _FakeAccountRepository();
    tester.view.physicalSize = _phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _phoneSize,
        builder: (_, __) => MaterialApp(
          home: EmailVerificationConfirmPage(
            token: null,
            accountRepository: repository,
          ),
          routes: <String, WidgetBuilder>{
            RouteName.editEmail: (_) =>
                const Scaffold(body: Text('edit-email')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Verification link is missing'), findsOneWidget);
    expect(repository.confirmEmailVerificationCalls, 0);

    await tester.tap(find.text('Back to account email'));
    await tester.pumpAndSettle();

    expect(find.text('edit-email'), findsOneWidget);
  });

  testWidgets('email verification confirm shows safe token failure', (
    tester,
  ) async {
    final repository = _FakeAccountRepository(
      verificationFailure: const AuthFailure(
        type: AuthFailureType.validation,
        message: 'Verification link is invalid or expired.',
      ),
    );
    tester.view.physicalSize = _phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _phoneSize,
        builder: (_, __) => MaterialApp(
          home: EmailVerificationConfirmPage(
            token: 'opaque-verification-token',
            accountRepository: repository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm verification'));
    await tester.pumpAndSettle();

    expect(repository.confirmEmailVerificationCalls, 1);
    expect(
      find.text('Verification link is invalid or expired.'),
      findsOneWidget,
    );
  });

  testWidgets('direct local reauthentication draft route fails closed', (
    tester,
  ) async {
    await _pumpDashboard(tester);
    Navigator.of(
      tester.element(find.byType(Dashboard)),
    ).pushNamed(RouteName.enterPasswordToSave);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('not available in CareNet Phase 1'),
      findsOneWidget,
    );
    expect(find.text('Enter your password'), findsNothing);
  });
  testWidgets('account does not expose local password metadata', (
    tester,
  ) async {
    await _pumpDashboard(tester);
    await _openAccount(tester);

    expect(find.text('Password'), findsNothing);
    expect(find.textContaining('Last changed locally'), findsNothing);
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.failure, this.googleLinkFailure});

  final AuthFailure? failure;
  final AuthFailure? googleLinkFailure;
  int logoutCalls = 0;
  int googleLinkCalls = 0;
  String? lastGoogleLinkIdToken;

  @override
  Future<void> logout() async {
    logoutCalls += 1;
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
  }

  @override
  Future<void> googleLink({required String idToken}) async {
    googleLinkCalls += 1;
    lastGoogleLinkIdToken = idToken;
    final failure = googleLinkFailure;
    if (failure != null) {
      throw failure;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGoogleIdTokenProvider implements GoogleIdTokenProvider {
  _FakeGoogleIdTokenProvider({
    this.isConfigured = true,
    this.idToken = 'google-id-token',
    this.failure,
  });

  @override
  final bool isConfigured;
  final String idToken;
  final AuthFailure? failure;
  int signInCalls = 0;

  @override
  Future<String> signInIdToken() async {
    signInCalls += 1;
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    return idToken;
  }
}

class _FakeAccountRepository implements AccountRepository {
  _FakeAccountRepository({this.user, this.failure, this.verificationFailure});

  final AuthUser? user;
  final AuthFailure? failure;
  final AuthFailure? verificationFailure;
  int currentAccountCalls = 0;
  int requestEmailVerificationCalls = 0;
  int confirmEmailVerificationCalls = 0;
  String? lastVerificationToken;
  int deletionCalls = 0;
  String? lastDeletionPassword;
  String? lastDeletionGoogleToken;

  @override
  Future<AuthUser> currentAccount() async {
    currentAccountCalls += 1;
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    return user ??
        const AuthUser(
          id: 'user-1',
          email: 'backend-user@carenet.app',
          role: 'PATIENT',
          status: 'ACTIVE',
          emailVerified: false,
        );
  }

  @override
  Future<void> requestEmailVerification() async {
    requestEmailVerificationCalls += 1;
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
  }

  @override
  Future<void> confirmEmailVerification({required String token}) async {
    confirmEmailVerificationCalls += 1;
    lastVerificationToken = token;
    final failure = verificationFailure;
    if (failure != null) {
      throw failure;
    }
  }

  @override
  Future<AccountDeletionReceipt> requestAccountDeletion({
    String? password,
    String? googleIdToken,
  }) async {
    deletionCalls += 1;
    lastDeletionPassword = password;
    lastDeletionGoogleToken = googleIdToken;
    final failure = this.failure;
    if (failure != null) throw failure;
    return AccountDeletionReceipt(
      accountStatus: 'DELETED',
      deletionRequestedAt: DateTime.utc(2026, 9, 26, 12),
      retentionStatus: 'RETAINED_UNDER_POLICY',
      sessionsRevoked: true,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({
    this.patientProfile,
    this.failure,
    this.updateFailure,
  });

  final PatientProfile? patientProfile;
  final AuthFailure? failure;
  final AuthFailure? updateFailure;
  int patientMeCalls = 0;
  int updatePatientMeCalls = 0;
  String? lastUpdatedName;
  int? lastUpdatedAge;
  String? lastUpdatedLocation;

  @override
  Future<PatientProfile?> patientMe() async {
    patientMeCalls += 1;
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    return patientProfile;
  }

  @override
  Future<PatientProfile> updatePatientMe({
    required String name,
    int? age,
    String? location,
    DateTime? dateOfBirth,
    String? city,
    String? state,
    String? country,
    String? healthInterests,
  }) async {
    updatePatientMeCalls += 1;
    lastUpdatedName = name;
    lastUpdatedAge = age;
    lastUpdatedLocation = location;
    final failure = updateFailure;
    if (failure != null) {
      throw failure;
    }
    return PatientProfile(name: name, age: age, location: location);
  }

  @override
  Future<ProfessionalProfile?> professionalMe() async => null;

  @override
  Future<ProfessionalProfile> updateProfessionalMe({
    required String displayName,
    required String category,
    String? legalName,
    String? specialty,
    String? bio,
    String? licenseNumber,
    String? licensingCouncil,
    String? qualifications,
    int? yearsOfExperience,
    String? practiceName,
    String? practiceAddress,
    String? practiceCity,
    String? practiceState,
    String? practiceCountry,
  }) async {
    return ProfessionalProfile(displayName: displayName, category: category);
  }

  @override
  Future<List<PublicProfessional>> publicProfessionals() async {
    return const <PublicProfessional>[];
  }

  @override
  Future<PublicProfessional?> publicProfessionalById({
    required String professionalProfileId,
  }) async {
    return null;
  }
}

class _DashboardOnboardingRepository implements OnboardingRepository {
  const _DashboardOnboardingRepository();

  @override
  Future<AccountReadiness> accountReadiness() async {
    return const AccountReadiness(
      account: ReadinessAccount(
        role: 'PATIENT',
        status: 'ACTIVE',
        emailVerified: true,
      ),
      patient: PatientReadiness(
        profileStatus: 'COMPLETE',
        requiredFields: <String>[],
      ),
      nextAction: 'DASHBOARD',
      requiredActions: <String>[],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DashboardSchedulingRepository implements SchedulingRepository {
  const _DashboardSchedulingRepository();

  @override
  Future<List<AppointmentSummary>> ownAppointments() async {
    return const <AppointmentSummary>[];
  }

  @override
  Future<List<AvailabilityWindow>> ownAvailability() async {
    return const <AvailabilityWindow>[];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
