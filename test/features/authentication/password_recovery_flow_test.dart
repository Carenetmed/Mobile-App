import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/presentation/pages/enter_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/enter_password.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_phone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpWithRoutes(
  WidgetTester tester, {
  required String initialRoute,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            initialRoute: initialRoute,
            routes: {
              RouteName.signInPhone: (_) => const SignInPhone(),
              RouteName.signInEmail: (_) => const SignInEmail(),
              RouteName.enterEmail: (_) => const EnterEmailPage(),
              RouteName.enterPassword: (_) => const EnterPasswordPage(),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Password recovery flow', () {
    testWidgets('sign in phone forgot password routes to enter email', (
      tester,
    ) async {
      await _pumpWithRoutes(tester, initialRoute: RouteName.signInPhone);

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('sign in email forgot password routes to enter email', (
      tester,
    ) async {
      await _pumpWithRoutes(tester, initialRoute: RouteName.signInEmail);

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('enter email validates and routes to enter password', (
      tester,
    ) async {
      await _pumpWithRoutes(tester, initialRoute: RouteName.enterEmail);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Email Address is required'), findsOneWidget);

      await tester.enterText(
        find.byType(EditableText).first,
        'hello@example.com',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Enter password'), findsOneWidget);
      expect(
        find.text('Confirm your new password for hello@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('enter password validates and returns to sign in email', (
      tester,
    ) async {
      tester.view.physicalSize = _phoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: _phoneSize,
          builder:
              (_, __) => MaterialApp(
                initialRoute: RouteName.enterPassword,
                onGenerateRoute: (settings) {
                  if (settings.name == RouteName.enterPassword) {
                    return MaterialPageRoute<void>(
                      settings: RouteSettings(
                        name: settings.name,
                        arguments: 'hello@example.com',
                      ),
                      builder: (_) => const EnterPasswordPage(),
                    );
                  }
                  if (settings.name == RouteName.signInEmail) {
                    return MaterialPageRoute<void>(
                      builder:
                          (_) => const Scaffold(body: Text('sign-in-email')),
                    );
                  }
                  return null;
                },
              ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change password'));
      await tester.pump();
      expect(find.text('Please enter your password'), findsNWidgets(2));

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'Strong1!');
      await tester.enterText(fields.at(1), 'Mismatch1!');
      await tester.tap(find.text('Change password'));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);

      await tester.enterText(fields.at(1), 'Strong1!');
      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();

      expect(find.text('sign-in-email'), findsOneWidget);
    });
  });
}
