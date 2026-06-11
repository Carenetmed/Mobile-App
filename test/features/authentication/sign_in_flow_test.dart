import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_phone.dart';
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
              RouteName.dashboard:
                  (_) => const Scaffold(body: Text('dashboard')),
              RouteName.signInPhone: (_) => const SignInPhone(),
              RouteName.signInEmail: (_) => const SignInEmail(),
              RouteName.signUpPhone:
                  (_) => const Scaffold(body: Text('sign-up-phone')),
              RouteName.signUpEmail:
                  (_) => const Scaffold(body: Text('sign-up-email')),
            },
          ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Sign in flow', () {
    testWidgets('sign in email blocks invalid input and navigates when valid', (
      tester,
    ) async {
      await _pumpWithRoutes(tester, home: const SignInEmail());

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Email Address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'hello@example.com');
      await tester.enterText(fields.at(1), 'secret123');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('dashboard'), findsOneWidget);
    });

    testWidgets('sign in phone validates fields before navigation', (
      tester,
    ) async {
      await _pumpWithRoutes(tester, home: const SignInPhone());

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Country/Region is required'), findsOneWidget);
      expect(find.text('Phone number is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'United States');
      await tester.enterText(fields.at(1), '123');
      await tester.enterText(fields.at(2), 'secret123');
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Invalid phone number'), findsOneWidget);
      expect(find.text('dashboard'), findsNothing);

      await tester.enterText(fields.at(1), '+1 202 555 0199');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('dashboard'), findsOneWidget);
    });

    testWidgets('sign in email routes to sign up email entry', (tester) async {
      await _pumpWithRoutes(tester, home: const SignInEmail());

      await tester.tap(find.text('Don\'t have an account? Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('sign-up-email'), findsOneWidget);
    });

    testWidgets('sign in phone routes to sign up phone entry', (tester) async {
      await _pumpWithRoutes(tester, home: const SignInPhone());

      await tester.tap(find.text('Don\'t have an account? Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('sign-up-phone'), findsOneWidget);
    });
  });
}
