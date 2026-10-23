import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/config/carenet_public_links.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_session.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_con.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/onboarding_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpFinishSignUp(
  WidgetTester tester, {
  Size screenSize = _phoneSize,
  TextScaler textScaler = TextScaler.noScaling,
  _FakeAuthRepository? authRepository,
  _FakeOnboardingRepository? onboardingRepository,
  String? initialEmail,
  SignUpRole selectedRole = SignUpRole.patient,
  PublicLinkLauncher? publicLinkLauncher,
}) async {
  tester.view.physicalSize = screenSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (context, _) => MaterialApp(
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                  child: child!,
                ),
            initialRoute: RouteName.finishSignUp,
            routes: {
              RouteName.finishSignUp:
                  (_) => FinSignUp(
                    authRepository: authRepository ?? _FakeAuthRepository(),
                    onboardingRepository:
                        onboardingRepository ?? _FakeOnboardingRepository(),
                    initialEmail: initialEmail,
                    selectedRole: selectedRole,
                    publicLinkLauncher: publicLinkLauncher,
                  ),
              RouteName.communityAgreement:
                  (_) => const Scaffold(body: Text('community-agreement')),
              RouteName.patientOnboardingSetup:
                  (_) => const Scaffold(body: Text('patient-setup')),
              RouteName.medicalProfessional:
                  (_) => const Scaffold(body: Text('professional-onboarding')),
              RouteName.professionalVerificationDocuments:
                  (_) => const Scaffold(body: Text('verification-documents')),
            },
          ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Finish sign up', () {
    testWidgets('finish signup remains usable at 320px with 2x text', (
      tester,
    ) async {
      await _pumpFinishSignUp(
        tester,
        screenSize: const Size(320, 568),
        textScaler: const TextScaler.linear(2),
      );

      expect(find.text('Secure your patient account'), findsOneWidget);
      expect(find.byType(EditableText), findsNWidgets(3));
      expect(tester.takeException(), isNull);

      final submit = find.text(' Agree & continue');
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.text('Email Address is required'), findsOneWidget);
      expect(find.text('Please enter your password'), findsNWidgets(2));
      expect(tester.takeException(), isNull);

      final termsLink = find.byKey(const Key('sign-up-terms-link')).last;
      final privacyLink = find.byKey(const Key('sign-up-privacy-link')).last;
      await tester.ensureVisible(termsLink);
      await tester.ensureVisible(privacyLink);
      await tester.pumpAndSettle();
      expect(termsLink, findsOneWidget);
      expect(privacyLink, findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('legal controls open canonical public pages', (tester) async {
      final opened = <Uri>[];
      await _pumpFinishSignUp(
        tester,
        publicLinkLauncher: (uri) async {
          opened.add(uri);
          return true;
        },
      );

      await tester.scrollUntilVisible(
        find.byKey(const Key('sign-up-terms-link')).last,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const Key('sign-up-terms-link')).last);
      await tester.tap(find.byKey(const Key('sign-up-privacy-link')).last);
      await tester.pump();

      expect(opened, <Uri>[
        CareNetPublicLinks.terms,
        CareNetPublicLinks.privacy,
      ]);
    });
    for (final failure in ['false', 'sync throw', 'async throw']) {
      testWidgets('signup legal link handles $failure with fixed error', (
        tester,
      ) async {
        final opened = <Uri>[];
        await _pumpFinishSignUp(
          tester,
          publicLinkLauncher: (uri) {
            opened.add(uri);
            if (failure == 'false') return Future.value(false);
            final error = PlatformException(
              code: 'ACTIVITY_NOT_FOUND',
              message: 'private-launcher-detail',
            );
            if (failure == 'sync throw') throw error;
            return Future.error(error);
          },
        );
        final link = find.byKey(const Key('sign-up-terms-link')).last;
        await tester.ensureVisible(link);
        await tester.tap(link);
        await tester.pumpAndSettle();

        expect(opened, [CareNetPublicLinks.terms]);
        expect(
          find.text('Could not open this page. Please try again.'),
          findsOneWidget,
        );
        expect(find.textContaining('private-launcher-detail'), findsNothing);
        expect(find.textContaining('ACTIVITY_NOT_FOUND'), findsNothing);
        expect(find.byType(FinSignUp), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    for (final completion in ['true', 'false', 'error']) {
      testWidgets('signup legal link ignores $completion after disposal', (
        tester,
      ) async {
        final pending = Completer<bool>();
        final opened = <Uri>[];
        await _pumpFinishSignUp(
          tester,
          publicLinkLauncher: (uri) {
            opened.add(uri);
            return pending.future;
          },
        );
        final link = find.byKey(const Key('sign-up-privacy-link')).last;
        await tester.ensureVisible(link);
        await tester.tap(link);
        await tester.pump();
        expect(opened, [CareNetPublicLinks.privacy]);
        await tester.pumpWidget(const SizedBox.shrink());

        if (completion == 'error') {
          pending.completeError(
            PlatformException(
              code: 'ACTIVITY_NOT_FOUND',
              message: 'private-launcher-detail',
            ),
          );
        } else {
          pending.complete(completion == 'true');
        }
        await tester.pump();

        expect(find.byType(SnackBar), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('blocks navigation when required fields are empty', (
      tester,
    ) async {
      await _pumpFinishSignUp(tester);

      await tester.tap(find.text(' Agree & continue'));
      await tester.pump();

      expect(find.text('Email Address is required'), findsOneWidget);
      expect(find.text('Please enter your password'), findsNWidgets(2));
      expect(find.text('community-agreement'), findsNothing);
      expect(find.text('patient-setup'), findsNothing);
    });

    testWidgets('registers through repository when form fields are valid', (
      tester,
    ) async {
      final repository = _FakeAuthRepository();
      final onboardingRepository = _FakeOnboardingRepository();
      await _pumpFinishSignUp(
        tester,
        authRepository: repository,
        onboardingRepository: onboardingRepository,
      );

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'john@example.com');
      await tester.enterText(fields.at(1), 'correct horse battery staple');
      await tester.enterText(fields.at(2), 'correct horse battery staple');

      await tester.tap(find.text(' Agree & continue'));
      await tester.pumpAndSettle();

      expect(repository.registerCalls, 1);
      expect(repository.lastEmail, 'john@example.com');
      expect(repository.lastRole, 'PATIENT');
      expect(repository.lastProfile, isEmpty);
      expect(onboardingRepository.readinessCalls, 1);
      expect(find.text('patient-setup'), findsOneWidget);
    });

    testWidgets(
      'registers professional role and routes to professional setup',
      (tester) async {
        final repository = _FakeAuthRepository();
        final onboardingRepository = _FakeOnboardingRepository(
          readiness: _readiness(
            nextAction: 'PROFESSIONAL_UPLOAD_EVIDENCE',
            role: 'PROFESSIONAL',
          ),
        );
        await _pumpFinishSignUp(
          tester,
          authRepository: repository,
          onboardingRepository: onboardingRepository,
          selectedRole: SignUpRole.professional,
        );

        await _fillValidForm(tester);
        await tester.tap(find.text(' Agree & continue'));
        await tester.pumpAndSettle();

        expect(repository.registerCalls, 1);
        expect(repository.lastRole, 'PROFESSIONAL');
        expect(onboardingRepository.readinessCalls, 1);
        expect(find.text('verification-documents'), findsOneWidget);
        expect(find.text('professional-onboarding'), findsNothing);
        expect(find.text('community-agreement'), findsNothing);
        expect(find.text('patient-setup'), findsNothing);
      },
    );

    testWidgets('prefills email passed from email sign-up entry', (
      tester,
    ) async {
      await _pumpFinishSignUp(tester, initialEmail: 'hello@example.com');

      expect(
        find.widgetWithText(TextFormField, 'hello@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('does not collect profile fields discarded by registration', (
      tester,
    ) async {
      await _pumpFinishSignUp(tester);

      expect(find.text('First name'), findsNothing);
      expect(find.text('Last name'), findsNothing);
      expect(find.text('Birthday'), findsNothing);
      expect(
        find.textContaining('profile details are collected'),
        findsOneWidget,
      );
    });

    testWidgets('accepts a backend-valid passphrase without complexity rules', (
      tester,
    ) async {
      final repository = _FakeAuthRepository();
      await _pumpFinishSignUp(tester, authRepository: repository);

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'john@example.com');
      await tester.enterText(fields.at(1), 'all lowercase passphrase');
      await tester.enterText(fields.at(2), 'all lowercase passphrase');
      await tester.tap(find.text(' Agree & continue'));
      await tester.pumpAndSettle();

      expect(repository.registerCalls, 1);
    });

    testWidgets('shows safe backend error without navigation', (tester) async {
      await _pumpFinishSignUp(
        tester,
        authRepository: _FakeAuthRepository(
          failure: const AuthFailure(
            type: AuthFailureType.missingConfiguration,
            message: 'Backend is not configured yet.',
          ),
        ),
      );

      await _fillValidForm(tester);
      await tester.tap(find.text(' Agree & continue'));
      await tester.pumpAndSettle();

      expect(find.text('Backend is not configured yet.'), findsOneWidget);
      expect(find.text('community-agreement'), findsNothing);
      expect(find.text('patient-setup'), findsNothing);
    });

    testWidgets('shows loading state while registration is pending', (
      tester,
    ) async {
      final completer = Completer<AuthSession>();
      await _pumpFinishSignUp(
        tester,
        authRepository: _FakeAuthRepository(completer: completer),
        onboardingRepository: _FakeOnboardingRepository(),
      );

      await _fillValidForm(tester);
      await tester.tap(find.text(' Agree & continue'));
      await tester.pump();

      expect(find.text('Creating account...'), findsOneWidget);
      expect(find.text('community-agreement'), findsNothing);
      expect(find.text('patient-setup'), findsNothing);

      completer.complete(_session());
      await tester.pumpAndSettle();

      expect(find.text('patient-setup'), findsOneWidget);
    });

    testWidgets(
      'falls back to authenticated professional setup when readiness fails',
      (tester) async {
        await _pumpFinishSignUp(
          tester,
          authRepository: _FakeAuthRepository(),
          onboardingRepository: _FakeOnboardingRepository(failReadiness: true),
          selectedRole: SignUpRole.professional,
        );

        await _fillValidForm(tester);
        await tester.tap(find.text(' Agree & continue'));
        await tester.pumpAndSettle();

        expect(find.text('professional-onboarding'), findsOneWidget);
        expect(find.text('patient-setup'), findsNothing);
      },
    );

    testWidgets(
      'readiness failure cannot override the role in the returned session',
      (tester) async {
        await _pumpFinishSignUp(
          tester,
          authRepository: _FakeAuthRepository(sessionRole: 'PATIENT'),
          onboardingRepository: _FakeOnboardingRepository(failReadiness: true),
          selectedRole: SignUpRole.professional,
        );

        await _fillValidForm(tester);
        await tester.tap(find.text(' Agree & continue'));
        await tester.pumpAndSettle();

        expect(find.text('patient-setup'), findsOneWidget);
        expect(find.text('professional-onboarding'), findsNothing);
      },
    );

    testWidgets('blocks navigation when confirm password does not match', (
      tester,
    ) async {
      await _pumpFinishSignUp(tester);

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'john@example.com');
      await tester.enterText(fields.at(1), 'correct horse battery staple');
      await tester.enterText(fields.at(2), 'mismatch horse battery staple');

      await tester.tap(find.text(' Agree & continue'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(find.text('community-agreement'), findsNothing);
      expect(find.text('patient-setup'), findsNothing);
    });
  });
}

Future<void> _fillValidForm(WidgetTester tester) async {
  final fields = find.byType(EditableText);
  await tester.enterText(fields.at(0), 'john@example.com');
  await tester.enterText(fields.at(1), 'correct horse battery staple');
  await tester.enterText(fields.at(2), 'correct horse battery staple');
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.failure, this.completer, this.sessionRole});

  final AuthFailure? failure;
  final Completer<AuthSession>? completer;
  final String? sessionRole;
  int registerCalls = 0;
  String? lastEmail;
  String? lastRole;
  Map<String, dynamic>? lastProfile;

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic> profile = const <String, dynamic>{},
  }) async {
    registerCalls += 1;
    lastEmail = email;
    lastRole = role;
    lastProfile = profile;
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    final completer = this.completer;
    if (completer != null) {
      return completer.future;
    }
    return _session(role: sessionRole ?? role);
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
      throw const AuthFailure(
        type: AuthFailureType.network,
        message: 'Service is unavailable. Please try again.',
      );
    }
    return readiness;
  }

  @override
  Future<OnboardingCatalog> onboardingCatalog() async {
    throw UnimplementedError();
  }
}

AuthSession _session({String role = 'PATIENT'}) {
  return AuthSession(
    accessToken: 'access',
    refreshToken: 'refresh',
    tokenType: 'Bearer',
    expiresIn: 900,
    user: AuthUser(
      id: 'user-1',
      email: 'john@example.com',
      role: role,
      status: 'ACTIVE',
      emailVerified: false,
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
