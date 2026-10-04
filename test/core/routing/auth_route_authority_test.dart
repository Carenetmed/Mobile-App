import 'dart:ui' show SemanticsAction;

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/constants/navigators/router.dart';
import 'package:app_t/core/routing/deferred_feature_page.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/email_verification_confirm_page.dart';
import 'package:app_t/features/Authentication/presentation/pages/reset_password_confirm_page.dart';
import 'package:app_t/features/Onboarding/presentation/pages/profile_setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('unsupported auth and legacy onboarding routes fail closed', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(_pageFor(context, RouteName.signInPhone), isA<SignInEmail>());
    expect(_pageFor(context, RouteName.signUpPhone), isA<SignUpEmail>());
    expect(
      _pageFor(context, RouteName.communityAgreement),
      isA<PatientOnboardingSetupPage>(),
    );
    expect(
      _pageFor(context, RouteName.notificationAgreement),
      isA<PatientOnboardingSetupPage>(),
    );
    expect(
      _pageFor(context, RouteName.medicalAgreement),
      isA<ProfessionalOnboardingSetupPage>(),
    );
    expect(
      _pageFor(context, RouteName.medicalProfessional),
      isA<ProfessionalOnboardingSetupPage>(),
    );
    expect(
      _pageFor(context, RouteName.medicalEdit),
      isA<DeferredFeaturePage>(),
    );
  });

  testWidgets(
    'obsolete medicalEdit route fails closed and offers accessible return home',
    (tester) async {
      final semantics = tester.ensureSemantics();
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
          home: Builder(
            builder: (value) {
              context = value;
              return const SizedBox.shrink();
            },
          ),
          onGenerateRoute: (settings) {
            if (settings.name == RouteName.dashboard) {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const Scaffold(body: Text('Dashboard home')),
              );
            }
            return generateRoute(settings);
          },
        ),
      );

      final page = _pageFor(context, RouteName.medicalEdit);
      Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => page));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DeferredFeaturePage), findsOneWidget);
      expect(
        find.text('This feature is not available in CareNet Phase 1.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      final returnHome = find.ancestor(
        of: find.text('Return home'),
        matching: find.byType(FilledButton),
      );
      expect(returnHome, findsOneWidget);
      expect(tester.getSize(returnHome).height, greaterThanOrEqualTo(48));
      expect(
        tester
            .getSemantics(returnHome)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      await tester.ensureVisible(find.text('Return home'));
      await tester.pump();
      await tester.tap(find.text('Return home'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Dashboard home'), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('canonical HTTPS auth links preserve their token', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final verify = _pageForSettings(
      context,
      const RouteSettings(
        name:
            'https://project-a96784ee-811c-46ab-a7b.web.app/verify-email?token=verify-token',
      ),
    );
    final reset = _pageForSettings(
      context,
      const RouteSettings(name: '/reset-password?token=reset-token'),
    );

    expect(verify, isA<EmailVerificationConfirmPage>());
    expect((verify as EmailVerificationConfirmPage).token, 'verify-token');
    expect(reset, isA<ResetPasswordConfirmPage>());
    expect((reset as ResetPasswordConfirmPage).token, 'reset-token');
  });

  testWidgets('auth links from an unrelated host do not receive tokens', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final page = _pageForSettings(
      context,
      const RouteSettings(
        name: 'https://example.com/verify-email?token=attacker-token',
      ),
    );
    expect(page, isNot(isA<EmailVerificationConfirmPage>()));
  });
}

Widget _pageFor(BuildContext context, String routeName) {
  return _pageForSettings(context, RouteSettings(name: routeName));
}

Widget _pageForSettings(BuildContext context, RouteSettings settings) {
  final route = generateRoute(settings);
  return (route as MaterialPageRoute<void>).builder(context);
}
