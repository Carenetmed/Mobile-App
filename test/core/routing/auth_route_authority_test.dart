import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/constants/navigators/router.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_email.dart';
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
}

Widget _pageFor(BuildContext context, String routeName) {
  final route = generateRoute(RouteSettings(name: routeName));
  return (route as MaterialPageRoute<void>).builder(context);
}
