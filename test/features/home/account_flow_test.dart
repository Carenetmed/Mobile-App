import 'package:app_t/core/constants/navigators/router.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/Authentication/presentation/pages/email_verification_confirm_page.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
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

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => const MaterialApp(
            home: Dashboard(),
            onGenerateRoute: generateRoute,
          ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpAccount(
  WidgetTester tester, {
  required _FakeAuthRepository repository,
  _FakeAccountRepository? accountRepository,
  GoogleIdTokenProvider? googleIdTokenProvider,
}) async {
  AccountLocalStore.reset();
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: AccountShellPage(
              authRepository: repository,
              accountRepository: accountRepository,
              googleIdTokenProvider: googleIdTokenProvider,
            ),
            routes: <String, WidgetBuilder>{
              RouteName.onboarding:
                  (_) => const Scaffold(body: Text('onboarding')),
              RouteName.manageProfile:
                  (_) => const Scaffold(body: Text('manage-profile-route')),
              RouteName.professionalVerificationDocuments:
                  (_) => const Scaffold(
                    body: Text('verification-documents-route'),
                  ),
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
      builder:
          (_, __) => MaterialApp(
            home: EditEmailShellPage(accountRepository: repository),
            routes: <String, WidgetBuilder>{
              RouteName.changeEmail:
                  (_) => const Scaffold(body: Text('change-email')),
              RouteName.enterPasswordToSave:
                  (_) => const Scaffold(body: Text('password-step')),
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
      builder:
          (_, __) => MaterialApp(
            home: SettingsProfilePage(profileRepository: profileRepository),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('drawer profile opens the account page', (tester) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Delete account'), findsWidgets);
  });

  testWidgets('logout clears session and returns to onboarding', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await _pumpAccount(tester, repository: repository);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(repository.logoutCalls, 1);
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
    expect(find.text('Settings & Profile'), findsOneWidget);
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

    expect(find.text('Authentication'), findsOneWidget);
    expect(find.text('Google account'), findsOneWidget);
    expect(find.text('Settings & Profile'), findsOneWidget);

    final authenticationTop = tester.getTopLeft(find.text('Authentication')).dy;
    final googleTop = tester.getTopLeft(find.text('Google account')).dy;
    final settingsTop = tester.getTopLeft(find.text('Settings & Profile')).dy;
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
    expect(find.text('backend-patient@carenet.app'), findsOneWidget);
    expect(find.text('PATIENT account - active'), findsOneWidget);
    expect(find.text('link-id-token'), findsNothing);
    expect(find.text('Google sign-up'), findsNothing);
    expect(find.text('Unlink Google'), findsNothing);
    expect(find.text('Production OAuth'), findsNothing);
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

  testWidgets('account read failure keeps local account display', (
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
    expect(find.text('doctor@carenet.app'), findsOneWidget);
    expect(find.text('Email + phone login is active'), findsOneWidget);
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

  testWidgets('delete account validates required fields', (tester) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete account').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete account').last);
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Phone number is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('deactivate instead shows the local deactivation modal', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete account').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deactivate your instead?'));
    await tester.pumpAndSettle();

    expect(find.text('Your account is now deactivated'), findsOneWidget);
    expect(find.text('Activate account'), findsOneWidget);
  });

  testWidgets('settings profile validates username and saves locally', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings & Profile'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'lagbaja_carenet'),
      'lagbajatamedu',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'doctor@carenet.app'),
      'doctor',
    );
    await tester.pumpAndSettle();

    expect(find.text('Username taken'), findsOneWidget);
    expect(find.text('Enter a valid email address'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'lagbajatamedu'),
      'lagbaja_new',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'doctor'),
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

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('newdoctor@carenet.app'), findsOneWidget);
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

  testWidgets('authentication row opens two-step verification route', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Authentication'));
    await tester.pumpAndSettle();

    expect(find.text('Two-step verification'), findsWidgets);
    expect(find.text('Change PIN'), findsOneWidget);
    expect(find.text('Turn off'), findsOneWidget);
    expect(find.text('Learn more'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);

    await tester.tap(find.text('Review turn-on setup'));
    await tester.pumpAndSettle();

    expect(find.text('Turn on Authentication'), findsOneWidget);
    expect(
      find.text(
        'For extra security, turn on two-step verification, which will require a PIN when switching your device.',
      ),
      findsOneWidget,
    );
    expect(find.text('Turn on'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);

    await tester.tap(find.text('Review PIN setup'));
    await tester.pumpAndSettle();

    expect(
      find.text('Create a 6-digit PIN that you can remember'),
      findsOneWidget,
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('PIN is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter 6-digit PIN'),
      '123',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a 6-digit PIN'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter 6-digit PIN'),
      '123456',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('ready for secure backend storage'),
      findsOneWidget,
    );
    expect(find.text('Review confirmation step'), findsOneWidget);

    await tester.tap(find.text('Review confirmation step'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm your PIN'), findsWidgets);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('PIN is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, '*  *  *      *   *   *'),
      '123',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a 6-digit PIN'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, '*  *  *      *   *   *'),
      '654321',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('PINs do not match'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, '*  *  *      *   *   *'),
      '123456',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('PIN confirmation is ready'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Turn on'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('phone number row opens local add-phone draft route', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Phone number'));
    await tester.pumpAndSettle();

    expect(find.text('Add phone number'), findsOneWidget);
    expect(find.text('Current: +234 801 234 5678'), findsOneWidget);

    await tester.tap(find.text('Prepare verification'));
    await tester.pumpAndSettle();

    expect(find.text('Phone number is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter phone number'),
      '+234 802 111 2222',
    );
    await tester.tap(find.text('Prepare verification'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ready for SMS verification'), findsOneWidget);
    expect(find.text('Open confirmation step'), findsOneWidget);

    await tester.tap(find.text('Open confirmation step'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm phone number'), findsOneWidget);
    expect(find.text('Enter your phone number to continue'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, '+234 802 111 2222'),
      findsOneWidget,
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('ready for backend OTP verification'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('+234 801 234 5678'), findsOneWidget);
  });

  testWidgets('confirm phone number route validates without saving account', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    Navigator.of(
      tester.element(find.byType(Dashboard)),
    ).pushNamed(RouteName.confirmPhoneNumber);
    await tester.pumpAndSettle();

    expect(find.text('Confirm phone number'), findsOneWidget);
    expect(find.text('Current saved phone: +234 801 234 5678'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Phone number is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter phone number'),
      '123',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid phone number'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, '123'),
      '+234 803 333 4444',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('ready for backend OTP verification'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('+234 801 234 5678'), findsOneWidget);
  });

  testWidgets('email address row opens local add-email draft route', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Email address'));
    await tester.pumpAndSettle();

    expect(find.text('Add email address'), findsOneWidget);
    expect(find.text('Current: doctor@carenet.app'), findsOneWidget);

    await tester.tap(find.text('Prepare verification'));
    await tester.pumpAndSettle();

    expect(find.text('Email address is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter email address'),
      'doctor',
    );
    await tester.tap(find.text('Prepare verification'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter email address'),
      'newdoctor@carenet.app',
    );
    await tester.tap(find.text('Prepare verification'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ready for email verification'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('doctor@carenet.app'), findsOneWidget);
  });

  testWidgets('change existing email opens local change-email draft route', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Email address'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change existing email'));
    await tester.pumpAndSettle();

    expect(find.text('Change your email address'), findsOneWidget);
    expect(
      find.text('We will send a verification code to this email address'),
      findsOneWidget,
    );
    expect(find.text('Current: doctor@carenet.app'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Email address is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter email'),
      'doctor',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter email'),
      'doctor@carenet.app',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a different email address'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter email'),
      'changed-doctor@carenet.app',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ready for code verification'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('doctor@carenet.app'), findsOneWidget);
  });

  testWidgets('review current email opens local edit-email route', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Email address'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review current email'));
    await tester.pumpAndSettle();

    expect(find.text('Email address'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('doctor@carenet.app'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Edit email'), findsOneWidget);
    expect(find.text('Remove email'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);

    await tester.tap(find.text('Remove email'));
    await tester.pumpAndSettle();

    expect(find.text('doctor@carenet.app'), findsOneWidget);

    await tester.tap(find.text('Edit email'));
    await tester.pumpAndSettle();

    expect(find.text('Change your email address'), findsOneWidget);
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
    tester.view.physicalSize = _phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _phoneSize,
        builder:
            (_, __) => MaterialApp(
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

    await tester.tap(find.text('Confirm verification'));
    await tester.pumpAndSettle();

    expect(repository.confirmEmailVerificationCalls, 1);
    expect(repository.lastVerificationToken, 'opaque-verification-token');
    expect(repository.currentAccountCalls, 1);
    expect(find.textContaining('Email verified'), findsOneWidget);

    await tester.tap(find.text('Back to account'));
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
        builder:
            (_, __) => MaterialApp(
              home: EmailVerificationConfirmPage(
                token: null,
                accountRepository: repository,
              ),
              routes: <String, WidgetBuilder>{
                RouteName.editEmail:
                    (_) => const Scaffold(body: Text('edit-email')),
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
        builder:
            (_, __) => MaterialApp(
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

  testWidgets('password-to-save route prepares backend re-auth only', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Email address'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review current email'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review password step'));
    await tester.pumpAndSettle();

    expect(find.text('Enter password to save'), findsOneWidget);
    expect(find.text('Enter your password to continue'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Password is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your password'),
      'short',
    );
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Enter at least 8 characters'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your password'),
      'CareNet@123',
    );
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('ready for backend re-authentication'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('doctor@carenet.app'), findsOneWidget);
  });

  testWidgets('password row opens locked password route', (tester) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Password'));
    await tester.pumpAndSettle();

    expect(find.text('Password'), findsWidgets);
    expect(
      find.text(
        'Your password helps to keep your account secure and makes it easy to log into your account',
      ),
      findsOneWidget,
    );
    expect(find.text('Edit password'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
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
}
