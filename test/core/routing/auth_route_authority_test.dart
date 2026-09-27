import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/constants/navigators/router.dart';
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
  });

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
