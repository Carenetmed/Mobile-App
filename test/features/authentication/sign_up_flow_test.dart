import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_phone.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_role_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpWithRoutes(
  WidgetTester tester, {
  required Widget home,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: home,
            routes: {
              RouteName.signUpRole: (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                return SignUpRoleSelectionPage(
                  initialEmail:
                      args is SignUpRoleSelectionArgs
                          ? args.initialEmail
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
            },
          ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Sign up flow', () {
    testWidgets('sign up email blocks invalid input and navigates when valid', (
      tester,
    ) async {
      await _pumpWithRoutes(tester, home: SignUpEmail());

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Email Address is required'), findsOneWidget);

      await tester.enterText(
        find.byType(EditableText).first,
        'hello@example.com',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Choose account type'), findsOneWidget);
      expect(find.text('I need medical guidance'), findsOneWidget);
      expect(find.text('I am a medical professional'), findsOneWidget);

      await tester.tap(find.text('I need medical guidance'));
      await tester.pumpAndSettle();

      expect(
        find.text('finish-sign-up-PATIENT-hello@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('sign up phone validates fields before navigation', (
      tester,
    ) async {
      await _pumpWithRoutes(tester, home: SignUpPhone());

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Country/Region is required'), findsOneWidget);
      expect(find.text('Phone number is required'), findsOneWidget);

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'United States');
      await tester.enterText(fields.at(1), '123');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Invalid phone number'), findsOneWidget);

      await tester.enterText(fields.at(1), '+1 202 555 0199');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Choose account type'), findsOneWidget);

      await tester.tap(find.text('I am a medical professional'));
      await tester.pumpAndSettle();

      expect(find.text('finish-sign-up-PROFESSIONAL-no-email'), findsOneWidget);
    });

    testWidgets('sign up phone routes to sign in phone entry', (tester) async {
      await _pumpWithRoutes(tester, home: SignUpPhone());

      await tester.tap(find.text('Already have an account? Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('sign-in-phone'), findsOneWidget);
    });

    testWidgets('sign up email routes to sign in email entry', (tester) async {
      await _pumpWithRoutes(tester, home: SignUpEmail());

      await tester.tap(find.text('Already have an account? Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('sign-in-email'), findsOneWidget);
    });
  });
}
