import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/presentation/pages/enter_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/enter_password.dart';
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

    testWidgets('enter email validates and requests password reset', (
      tester,
    ) async {
      final repository = _FakeAuthRepository();
      await _pumpWithRoutes(
        tester,
        initialRoute: RouteName.enterEmail,
        repository: repository,
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

      expect(repository.requestPasswordResetCalls, 1);
      expect(repository.lastResetEmail, 'hello@example.com');
      expect(find.text('Enter password'), findsOneWidget);
      expect(
        find.text('We sent reset instructions to hello@example.com'),
        findsOneWidget,
      );
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
      await tester.tap(find.text('Continue'));
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
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Sending reset link...'), findsOneWidget);
      expect(find.text('Enter password'), findsNothing);

      completer.complete();
      await tester.pumpAndSettle();

      expect(find.text('Enter password'), findsOneWidget);
    });

    testWidgets(
      'enter password validates and stops before fake reset success',
      (tester) async {
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

        await tester.tap(find.text('Review reset token requirement'));
        await tester.pump();
        expect(find.text('Please enter your password'), findsNWidgets(2));

        final fields = find.byType(EditableText);
        await tester.enterText(fields.at(0), 'Strong1!');
        await tester.enterText(fields.at(1), 'Mismatch1!');
        await tester.tap(find.text('Review reset token requirement'));
        await tester.pump();
        expect(find.text('Passwords do not match'), findsOneWidget);

        await tester.enterText(fields.at(1), 'Strong1!');
        await tester.tap(find.text('Review reset token requirement'));
        await tester.pump();

        expect(
          find.textContaining(
            'Password reset confirmation needs the secure token',
          ),
          findsOneWidget,
        );
        expect(find.text('sign-in-email'), findsNothing);
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
                routes: <String, WidgetBuilder>{
                  RouteName.signInEmail:
                      (_) => const Scaffold(body: Text('sign-in-email')),
                },
              ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update password'));
      await tester.pump();
      expect(find.text('Please enter your password'), findsNWidgets(2));

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'CareNet@123');
      await tester.enterText(fields.at(1), 'Mismatch@123');
      await tester.tap(find.text('Update password'));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);

      await tester.enterText(fields.at(1), 'CareNet@123');
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();

      expect(repository.confirmPasswordResetCalls, 1);
      expect(repository.lastResetToken, 'opaque-reset-token');
      expect(repository.lastResetPassword, 'CareNet@123');
      expect(find.textContaining('Password updated'), findsOneWidget);

      await tester.tap(find.text('Back to sign in'));
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
      await tester.enterText(fields.at(0), 'CareNet@123');
      await tester.enterText(fields.at(1), 'CareNet@123');
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
