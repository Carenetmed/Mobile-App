import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/presentation/pages/enter_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/reset_password_confirm_page.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_phone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpWithRoutes(
  WidgetTester tester, {
  required String initialRoute,
  _FakeAuthRepository? repository,
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
            initialRoute: initialRoute,
            routes: {
              RouteName.signInPhone:
                  (_) => SignInPhone(
                    googleIdTokenProvider: _disabledGoogleProvider,
                  ),
              RouteName.signInEmail:
                  (_) => SignInEmail(
                    googleIdTokenProvider: _disabledGoogleProvider,
                  ),
              RouteName.enterEmail:
                  (_) => EnterEmailPage(authRepository: repository),
              RouteName.enterPassword: (_) => ResetPasswordConfirmPage(
                token: null,
                authRepository: repository,
              ),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Password recovery flow', () {
    testWidgets('enter-email recovery remains reachable with 2x text', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        initialRoute: RouteName.enterEmail,
        repository: _FakeAuthRepository(),
        screenSize: const Size(320, 568),
        textScaler: const TextScaler.linear(2),
      );

      expect(find.text('Enter email'), findsOneWidget);
      expect(find.byType(EditableText), findsOneWidget);
      expect(tester.takeException(), isNull);

      final continueButton = find.text('Send reset link');
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();
      expect(continueButton, findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      expect(find.text('Email Address is required'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

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
      expect(find.byTooltip('Back'), findsOneWidget);
    });

    testWidgets('enter email requests reset without claiming delivery', (
      tester,
    ) async {
      final repository = _FakeAuthRepository();
      await _pumpWithRoutes(
        tester,
        initialRoute: RouteName.enterEmail,
        repository: repository,
      );

      await tester.tap(find.text('Send reset link'));
      await tester.pump();
      expect(find.text('Email Address is required'), findsOneWidget);

      await tester.enterText(
        find.byType(EditableText).first,
        'hello@example.com',
      );
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(repository.requestPasswordResetCalls, 1);
      expect(repository.lastResetEmail, 'hello@example.com');
      expect(
        find.textContaining('If an account exists for that email'),
        findsOneWidget,
      );
      expect(find.text('Enter email'), findsOneWidget);
      expect(find.byType(EditableText), findsOneWidget);
    });

    testWidgets('enter email shows backend error without navigation', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        initialRoute: RouteName.enterEmail,
        repository: _FakeAuthRepository(
          failure: const AuthFailure(
            type: AuthFailureType.missingConfiguration,
            message: 'Backend is not configured yet.',
          ),
        ),
      );

      await tester.enterText(
        find.byType(EditableText).first,
        'hello@example.com',
      );
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(find.text('Backend is not configured yet.'), findsOneWidget);
      expect(find.text('Enter password'), findsNothing);
    });

    testWidgets('enter email shows loading state while request is pending', (
      tester,
    ) async {
      final completer = Completer<void>();
      await _pumpWithRoutes(
        tester,
        initialRoute: RouteName.enterEmail,
        repository: _FakeAuthRepository(completer: completer),
      );

      await tester.enterText(
        find.byType(EditableText).first,
        'hello@example.com',
      );
      await tester.tap(find.text('Send reset link'));
      await tester.pump();

      expect(find.text('Sending reset link...'), findsOneWidget);
      expect(find.text('Enter password'), findsNothing);

      completer.complete();
      await tester.pumpAndSettle();

      expect(find.text('Enter email'), findsOneWidget);
      expect(find.textContaining('Open the link in the email'), findsOneWidget);
    });

    testWidgets('legacy tokenless password route fails closed', (
      tester,
    ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: _phoneSize,
            builder:
                (context, _) => MaterialApp(
                  builder:
                      (context, child) => MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: const TextScaler.linear(2)),
                        child: child!,
                      ),
                  initialRoute: RouteName.enterPassword,
                  onGenerateRoute: (settings) {
                    if (settings.name == RouteName.enterPassword) {
                      return MaterialPageRoute<void>(
                        settings: RouteSettings(name: settings.name),
                        builder: (_) => ResetPasswordConfirmPage(
                          token: null,
                          authRepository: _FakeAuthRepository(),
                        ),
                      );
                    }
                    return null;
                  },
                ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Reset password'), findsOneWidget);
        expect(find.byType(EditableText), findsNothing);
        expect(find.textContaining('Reset link is missing'), findsOneWidget);
        expect(find.text('Request new reset email'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('reset confirmation requires token before calling backend', (
      tester,
    ) async {
      final repository = _FakeAuthRepository();
      tester.view.physicalSize = _phoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: _phoneSize,
          builder:
              (_, __) => MaterialApp(
                home: ResetPasswordConfirmPage(
                  token: null,
                  authRepository: repository,
                ),
                routes: <String, WidgetBuilder>{
                  RouteName.enterEmail:
                      (_) => const Scaffold(body: Text('enter-email')),
                },
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reset password'), findsOneWidget);
      expect(find.textContaining('Reset link is missing'), findsOneWidget);
      expect(repository.confirmPasswordResetCalls, 0);
    });

    testWidgets('reset confirmation submits token and new password', (
      tester,
    ) async {
      final repository = _FakeAuthRepository();
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: _phoneSize,
          builder:
              (context, _) => MaterialApp(
                builder:
                    (context, child) => MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: const TextScaler.linear(2)),
                      child: child!,
                    ),
                home: ResetPasswordConfirmPage(
                  token: 'opaque-reset-token',
                  authRepository: repository,
                ),
                routes: <String, WidgetBuilder>{
                  RouteName.signInEmail:
                      (_) => const Scaffold(body: Text('sign-in-email')),
                },
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reset password'), findsOneWidget);
      expect(find.byType(EditableText), findsNWidgets(2));
      expect(tester.takeException(), isNull);

      final updatePassword = find.text('Update password');
      await tester.scrollUntilVisible(
        updatePassword,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Update password'));
      await tester.pump();
      expect(find.text('Please enter your password'), findsNWidgets(2));

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'CareNetPassword@123');
      await tester.enterText(fields.at(1), 'MismatchPassword@123');
      await tester.tap(find.text('Update password'));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);

      await tester.enterText(fields.at(1), 'CareNetPassword@123');
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();

      expect(repository.confirmPasswordResetCalls, 1);
      expect(repository.lastResetToken, 'opaque-reset-token');
      expect(repository.lastResetPassword, 'CareNetPassword@123');
      expect(find.textContaining('Password updated'), findsOneWidget);

      final backToSignIn = find.text('Back to sign in');
      await tester.scrollUntilVisible(
        backToSignIn,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(backToSignIn);
      await tester.pumpAndSettle();

      expect(find.text('sign-in-email'), findsOneWidget);
    });

    testWidgets('reset confirmation shows safe backend failure', (
      tester,
    ) async {
      final repository = _FakeAuthRepository(
        confirmFailure: const AuthFailure(
          type: AuthFailureType.validation,
          message: 'Reset link is invalid or expired.',
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
                home: ResetPasswordConfirmPage(
                  token: 'opaque-reset-token',
                  authRepository: repository,
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'CareNetPassword@123');
      await tester.enterText(fields.at(1), 'CareNetPassword@123');
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();

      expect(repository.confirmPasswordResetCalls, 1);
      expect(find.text('Reset link is invalid or expired.'), findsOneWidget);
    });
  });
}

const _disabledGoogleProvider = _FakeGoogleIdTokenProvider(isConfigured: false);

class _FakeGoogleIdTokenProvider implements GoogleIdTokenProvider {
  const _FakeGoogleIdTokenProvider({this.isConfigured = true});

  @override
  final bool isConfigured;

  @override
  Future<String> signInIdToken() async => 'google-id-token';
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.failure, this.confirmFailure, this.completer});

  final AuthFailure? failure;
  final AuthFailure? confirmFailure;
  final Completer<void>? completer;
  int requestPasswordResetCalls = 0;
  int confirmPasswordResetCalls = 0;
  String? lastResetEmail;
  String? lastResetToken;
  String? lastResetPassword;

  @override
  Future<void> requestPasswordReset({required String email}) async {
    requestPasswordResetCalls += 1;
    lastResetEmail = email;
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    final completer = this.completer;
    if (completer != null) {
      return completer.future;
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    confirmPasswordResetCalls += 1;
    lastResetToken = token;
    lastResetPassword = password;
    final failure = confirmFailure;
    if (failure != null) {
      throw failure;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
