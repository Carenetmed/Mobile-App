import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_session.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_con.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_phone.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_role_selection.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/onboarding_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpWithRoutes(
  WidgetTester tester, {
  required Widget home,
  Size screenSize = _phoneSize,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.physicalSize = screenSize;
  tester.view.devicePixelRatio = 1.0;
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
            routes: {
              RouteName.signUpRole: (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                return SignUpRoleSelectionPage(
                  initialEmail:
                      args is SignUpRoleSelectionArgs
                          ? args.initialEmail
                          : null,
                  googleSignUp:
                      args is SignUpRoleSelectionArgs
                          ? args.googleSignUp
                          : false,
                  passwordSignUp:
                      args is SignUpRoleSelectionArgs
                          ? args.passwordSignUp
                          : false,
                  authRepository:
                      args is SignUpRoleSelectionArgs
                          ? args.authRepository
                          : null,
                  googleIdTokenProvider:
                      args is SignUpRoleSelectionArgs
                          ? args.googleIdTokenProvider
                          : null,
                  onboardingRepository:
                      args is SignUpRoleSelectionArgs
                          ? args.onboardingRepository
                          : null,
                );
              },
              RouteName.finishSignUp: (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                return Scaffold(
                  body: Text(
                    args is FinishSignUpArgs
                        ? 'finish-sign-up-${args.role.backendValue}-${args.initialEmail ?? 'no-email'}'
                        : 'finish-sign-up',
                  ),
                );
              },
              RouteName.signInPhone:
                  (_) => const Scaffold(body: Text('sign-in-phone')),
              RouteName.signInEmail:
                  (_) => const Scaffold(body: Text('sign-in-email')),
              RouteName.patientOnboardingSetup:
                  (_) => const Scaffold(body: Text('patient-setup')),
              RouteName.medicalProfessional:
                  (_) => const Scaffold(body: Text('professional-setup')),
              RouteName.professionalVerificationDocuments:
                  (_) => const Scaffold(body: Text('verification-documents')),
            },
          ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Sign up flow', () {
    testWidgets('email signup remains usable at compact width with 2x text', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        home: SignUpEmail(googleIdTokenProvider: _disabledGoogleProvider),
        screenSize: const Size(320, 568),
        textScaler: const TextScaler.linear(2),
      );

      expect(find.text('Create your CareNet account'), findsOneWidget);
      expect(find.text('Enter your email to continue.'), findsOneWidget);
      final heading = tester.widget<Text>(
        find.text('Create your CareNet account'),
      );
      expect(heading.style?.fontSize, greaterThan(16));
      expect(heading.style?.fontWeight, FontWeight.w800);
      expect(heading.style?.color, CarenetColors.primary700);
      expect(find.byType(EditableText), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Email Address is required'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final signInLink = find.text('Already have an account? Sign in');
      await tester.ensureVisible(signInLink);
      await tester.pumpAndSettle();
      expect(signInLink, findsOneWidget);
      await tester.tap(signInLink);
      await tester.pumpAndSettle();
      expect(find.text('sign-in-email'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sign up email blocks invalid input and navigates when valid', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        home: SignUpEmail(googleIdTokenProvider: _disabledGoogleProvider),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Email Address is required'), findsOneWidget);

      await tester.enterText(
        find.byType(EditableText).first,
        'hello@example.com',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('How will you use CareNet?'), findsOneWidget);
      expect(find.text('Patient'), findsOneWidget);
      expect(find.text('Medical professional'), findsOneWidget);

      await tester.tap(find.text('Patient'));
      await tester.pumpAndSettle();

      expect(
        find.text('finish-sign-up-PATIENT-hello@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('role choices expose a single descriptive button label', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        home: SignUpRoleSelectionPage(
          googleIdTokenProvider: _disabledGoogleProvider,
        ),
      );

      expect(
        find.bySemanticsLabel(
          'Patient. Find verified care, book appointments, and manage your care profile when needed. Badge: Fast setup.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'legacy phone signup exposes only supported auth at compact width',
      (tester) async {
        await _pumpWithRoutes(
          tester,
          home: SignUpPhone(googleIdTokenProvider: _disabledGoogleProvider),
          screenSize: const Size(320, 568),
          textScaler: const TextScaler.linear(2),
        );

        expect(find.text('Create your CareNet account'), findsOneWidget);
        expect(find.text('Email address'), findsOneWidget);
        expect(find.text('Phone number'), findsNothing);
        expect(find.textContaining('SMS'), findsNothing);
        expect(find.textContaining('call or text'), findsNothing);
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.text('Continue with Facebook'), findsNothing);
        expect(find.text('Continue with Apple'), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pump();
        expect(find.text('Email Address is required'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.enterText(
          find.byType(EditableText).first,
          'legacy@example.com',
        );
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text('How will you use CareNet?'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('password signup stays usable at compact width with 2x text', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        home: FinSignUp(
          initialEmail: 'hello@example.com',
          authRepository: _FakeAuthRepository(),
          onboardingRepository: _FakeOnboardingRepository(),
        ),
        screenSize: const Size(320, 568),
        textScaler: const TextScaler.linear(2),
      );

      expect(find.text('Secure your patient account'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final continueButton = find.text(' Agree & continue');
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();
      expect(continueButton, findsOneWidget);
      expect(find.byKey(const Key('sign-up-terms-link')), findsOneWidget);
      expect(find.byKey(const Key('sign-up-privacy-link')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('legacy signup entry routes to supported email sign in', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        home: SignUpPhone(googleIdTokenProvider: _disabledGoogleProvider),
      );

      final signInLink = find.text('Already have an account? Sign in');
      await tester.ensureVisible(signInLink);
      await tester.pumpAndSettle();
      await tester.tap(signInLink);
      await tester.pumpAndSettle();

      expect(find.text('sign-in-email'), findsOneWidget);
    });

    testWidgets('sign up email routes to sign in email entry', (tester) async {
      await _pumpWithRoutes(
        tester,
        home: SignUpEmail(googleIdTokenProvider: _disabledGoogleProvider),
      );

      await tester.tap(find.text('Already have an account? Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('sign-in-email'), findsOneWidget);
    });

    testWidgets(
      'sign up email Google creates patient account after role pick',
      (tester) async {
        final repository = _FakeAuthRepository();
        final onboardingRepository = _FakeOnboardingRepository(
          readiness: _readiness(nextAction: 'PATIENT_SETUP', role: 'PATIENT'),
        );
        final provider = _FakeGoogleIdTokenProvider(idToken: 'signup-id-token');
        await _pumpWithRoutes(
          tester,
          home: SignUpEmail(
            authRepository: repository,
            googleIdTokenProvider: provider,
            onboardingRepository: onboardingRepository,
          ),
        );

        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Patient'));
        await tester.pumpAndSettle();

        expect(repository.googleSignInCalls, 1);
        expect(repository.lastGoogleIdToken, 'signup-id-token');
        expect(repository.lastGoogleRole, 'PATIENT');
        expect(onboardingRepository.readinessCalls, 1);
        expect(find.text('patient-setup'), findsOneWidget);
      },
    );

    testWidgets(
      'legacy signup entry preserves configured Google role selection',
      (tester) async {
        final repository = _FakeAuthRepository();
        final onboardingRepository = _FakeOnboardingRepository(
          readiness: _readiness(
            nextAction: 'PROFESSIONAL_UPLOAD_EVIDENCE',
            role: 'PROFESSIONAL',
          ),
        );
        final provider = _FakeGoogleIdTokenProvider(idToken: 'pro-id-token');
        await _pumpWithRoutes(
          tester,
          home: SignUpPhone(
            authRepository: repository,
            googleIdTokenProvider: provider,
            onboardingRepository: onboardingRepository,
          ),
        );

        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Medical professional'));
        await tester.pumpAndSettle();

        expect(repository.googleSignInCalls, 1);
        expect(repository.lastGoogleIdToken, 'pro-id-token');
        expect(repository.lastGoogleRole, 'PROFESSIONAL');
        expect(onboardingRepository.readinessCalls, 1);
        expect(find.text('verification-documents'), findsOneWidget);
        expect(find.text('professional-setup'), findsNothing);
      },
    );

    testWidgets(
      'sign up Google falls back to professional setup when readiness fails',
      (tester) async {
        final repository = _FakeAuthRepository();
        await _pumpWithRoutes(
          tester,
          home: SignUpEmail(
            authRepository: repository,
            googleIdTokenProvider: const _FakeGoogleIdTokenProvider(
              idToken: 'pro-id-token',
            ),
            onboardingRepository: _FakeOnboardingRepository(
              failReadiness: true,
            ),
          ),
        );

        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Medical professional'));
        await tester.pumpAndSettle();

        expect(repository.googleSignInCalls, 1);
        expect(find.text('professional-setup'), findsOneWidget);
        expect(find.text('patient-setup'), findsNothing);
      },
    );

    testWidgets(
      'Google signup readiness failure follows backend session role',
      (tester) async {
        final repository = _FakeAuthRepository(sessionRole: 'PATIENT');
        await _pumpWithRoutes(
          tester,
          home: SignUpEmail(
            authRepository: repository,
            googleIdTokenProvider: const _FakeGoogleIdTokenProvider(),
            onboardingRepository: _FakeOnboardingRepository(
              failReadiness: true,
            ),
          ),
        );

        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Medical professional'));
        await tester.pumpAndSettle();

        expect(repository.lastGoogleRole, 'PROFESSIONAL');
        expect(find.text('patient-setup'), findsOneWidget);
        expect(find.text('professional-setup'), findsNothing);
      },
    );

    testWidgets('sign up role change clears stale Google error', (
      tester,
    ) async {
      final repository = _FakeAuthRepository();
      await _pumpWithRoutes(
        tester,
        home: SignUpRoleSelectionPage(
          authRepository: repository,
          googleIdTokenProvider: const _FakeGoogleIdTokenProvider(
            failure: AuthFailure(
              type: AuthFailureType.unknown,
              message: 'Google sign-in failed. Please try again.',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Patient'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(
        find.text('Google sign-in failed. Please try again.'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Google sign-in failed. Please try again.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      expect(find.text('How will you use CareNet?'), findsOneWidget);
      expect(
        find.text('Google sign-in failed. Please try again.'),
        findsNothing,
      );
      expect(repository.googleSignInCalls, 0);
    });

    testWidgets('sign up Google remains disabled without provider config', (
      tester,
    ) async {
      final repository = _FakeAuthRepository();
      await _pumpWithRoutes(
        tester,
        home: SignUpEmail(
          authRepository: repository,
          googleIdTokenProvider: const _FakeGoogleIdTokenProvider(
            isConfigured: false,
          ),
        ),
      );

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(repository.googleSignInCalls, 0);
      expect(find.text('How will you use CareNet?'), findsNothing);
    });
  });
}

const _disabledGoogleProvider = _FakeGoogleIdTokenProvider(isConfigured: false);

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.sessionRole});

  final String? sessionRole;
  int googleSignInCalls = 0;
  String? lastGoogleIdToken;
  String? lastGoogleRole;

  @override
  Future<AuthSession> googleSignIn({
    required String idToken,
    String? role,
  }) async {
    googleSignInCalls += 1;
    lastGoogleIdToken = idToken;
    lastGoogleRole = role;
    return _session(role: sessionRole ?? role ?? 'PATIENT');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({
    AccountReadiness? readiness,
    this.failReadiness = false,
  }) : readiness =
           readiness ??
           _readiness(nextAction: 'PATIENT_SETUP', role: 'PATIENT');

  final AccountReadiness readiness;
  final bool failReadiness;
  int readinessCalls = 0;

  @override
  Future<AccountReadiness> accountReadiness() async {
    readinessCalls += 1;
    if (failReadiness) {
      throw Exception('readiness failed');
    }
    return readiness;
  }

  @override
  Future<OnboardingCatalog> onboardingCatalog() async {
    throw UnimplementedError();
  }
}

class _FakeGoogleIdTokenProvider implements GoogleIdTokenProvider {
  const _FakeGoogleIdTokenProvider({
    this.isConfigured = true,
    this.idToken,
    this.failure,
  });

  @override
  final bool isConfigured;
  final String? idToken;
  final AuthFailure? failure;

  @override
  Future<String> signInIdToken() async {
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    return idToken ?? 'google-id-token';
  }
}

AuthSession _session({required String role}) {
  return AuthSession(
    accessToken: 'access',
    refreshToken: 'refresh',
    tokenType: 'Bearer',
    expiresIn: 900,
    user: AuthUser(
      id: 'user-1',
      email: 'hello@example.com',
      role: role,
      status: 'ACTIVE',
      emailVerified: true,
    ),
  );
}

AccountReadiness _readiness({
  required String nextAction,
  required String role,
}) {
  return AccountReadiness(
    account: ReadinessAccount(
      role: role,
      status: 'ACTIVE',
      emailVerified: true,
    ),
    patient: const PatientReadiness(
      profileStatus: 'DRAFT',
      requiredFields: <String>['name'],
    ),
    professional: const ProfessionalReadiness(
      applicationStatus: 'DRAFT',
      verificationStatus: 'NOT_SUBMITTED',
      requiredProfileFields: <String>[],
      requiredEvidence: <String>[],
      missingEvidence: <String>[],
    ),
    nextAction: nextAction,
    requiredActions: const <String>[],
  );
}
