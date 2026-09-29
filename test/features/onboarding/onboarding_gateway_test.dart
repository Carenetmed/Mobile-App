import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Onboarding/presentation/pages/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpGateway(
  WidgetTester tester, {
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
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                  child: child!,
                ),
            home: const OnboardingView(),
            routes: {
              RouteName.search:
                  (_) => const Scaffold(body: Text('guest-search')),
              RouteName.signUpRole:
                  (_) => const Scaffold(body: Text('role-first-signup')),
              RouteName.signInEmail:
                  (_) => const Scaffold(body: Text('email-sign-in')),
            },
          ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets(
    'welcome choices remain reachable at compact width with 2x text',
    (tester) async {
      await _pumpGateway(
        tester,
        screenSize: const Size(320, 568),
        textScaler: const TextScaler.linear(2),
      );

      expect(find.text('Find verified care with confidence'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final browse = find.text('Browse verified care');
      await tester.ensureVisible(browse);
      await tester.pumpAndSettle();
      expect(browse, findsOneWidget);
      expect(tester.takeException(), isNull);

      final createAccount = find.text('Create account');
      await tester.ensureVisible(createAccount);
      await tester.pumpAndSettle();
      expect(createAccount, findsOneWidget);
      expect(tester.takeException(), isNull);

      final signIn = find.text('Already have an account? Sign in');
      await tester.ensureVisible(signIn);
      await tester.pumpAndSettle();
      expect(signIn, findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(signIn);
      await tester.pumpAndSettle();
      expect(find.text('email-sign-in'), findsOneWidget);
    },
  );

  testWidgets('welcome gateway offers browse, create account, and sign in', (
    tester,
  ) async {
    await _pumpGateway(tester);

    expect(find.text('Find verified care with confidence'), findsOneWidget);
    expect(find.text('Browse verified care'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Already have an account? Sign in'), findsOneWidget);
    expect(find.text('Get started'), findsNothing);
    expect(find.text('Sign up with phone'), findsNothing);

    await tester.tap(find.text('Browse verified care'));
    await tester.pumpAndSettle();
    expect(find.text('guest-search'), findsOneWidget);
  });

  testWidgets(
    'create account enters role-first signup instead of phone signup',
    (tester) async {
      await _pumpGateway(tester);

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.text('role-first-signup'), findsOneWidget);
    },
  );

  testWidgets('sign in opens email sign-in from gateway', (tester) async {
    await _pumpGateway(tester);

    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('email-sign-in'), findsOneWidget);
  });
}
