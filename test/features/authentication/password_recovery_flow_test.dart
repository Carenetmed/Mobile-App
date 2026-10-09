import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/Authentication/presentation/pages/enter_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/email_verification_confirm_page.dart';
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
              RouteName.enterPassword:
                  (_) => ResetPasswordConfirmPage(
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

      expect(find.text('Reset your password'), findsOneWidget);
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

    testWidgets('recovery page title is exposed as screen-reader heading', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        initialRoute: RouteName.enterEmail,
        repository: _FakeAuthRepository(),
      );

      final heading = find.ancestor(
        of: find.text('Reset your password'),
        matching: find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.header == true,
        ),
      );
      expect(heading, findsOneWidget);
    });

    testWidgets('reset confirmation title is a screen-reader heading', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        initialRoute: RouteName.enterPassword,
        repository: _FakeAuthRepository(),
      );

      final heading = find.ancestor(
        of: find.text('Reset password'),
        matching: find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.header == true,
        ),
      );
      expect(heading, findsOneWidget);
    });

    testWidgets('sign in phone forgot password routes to enter email', (
      tester,
    ) async {
      await _pumpWithRoutes(tester, initialRoute: RouteName.signInPhone);

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Reset your password'), findsOneWidget);
    });

    testWidgets('sign in email forgot password routes to enter email', (
      tester,
    ) async {
      await _pumpWithRoutes(tester, initialRoute: RouteName.signInEmail);

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Reset your password'), findsOneWidget);
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
      expect(find.text('Reset your password'), findsOneWidget);
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

      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.textContaining('Open the link in the email'), findsOneWidget);
    });

    testWidgets('legacy tokenless password route fails closed', (tester) async {
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
                      builder:
                          (_) => ResetPasswordConfirmPage(
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
    });

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
      await tester.ensureVisible(updatePassword);
      await tester.tap(find.text('Update password'));
      await tester.pump();
      expect(find.text('Please enter your password'), findsNWidgets(2));

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'CareNetPassword@123');
      await tester.enterText(fields.at(1), 'MismatchPassword@123');
      tester.binding.focusManager.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(updatePassword);
      await tester.tap(find.text('Update password'));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);

      await tester.enterText(fields.at(1), 'CareNetPassword@123');
      tester.binding.focusManager.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(updatePassword);
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
      await tester.ensureVisible(backToSignIn);
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

    testWidgets('verification confirmation remains usable at large text', (
      tester,
    ) async {
      final completer = Completer<void>();
      final repository = _FakeAccountRepository(completer: completer);
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
                home: EmailVerificationConfirmPage(
                  token: 'opaque-verification-token',
                  accountRepository: repository,
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify email'), findsOneWidget);
      expect(find.text('Confirm your email address'), findsOneWidget);
      final confirm = find.text('Confirm verification');
      await tester.ensureVisible(confirm);
      await tester.tap(confirm);
      await tester.pump();

      expect(find.text('Verifying email...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);

      completer.complete();
      await tester.pumpAndSettle();

      expect(repository.lastVerificationToken, 'opaque-verification-token');
      expect(repository.currentAccountCalls, 1);
      expect(find.textContaining('Email verified'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('verification missing-link state is clear and scrollable', (
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
                home: EmailVerificationConfirmPage(token: null),
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Verification link is missing'),
        findsOneWidget,
      );
      final backToEmail = find.text('Back to account email');
      await tester.ensureVisible(backToEmail);
      expect(backToEmail, findsOneWidget);
      expect(tester.takeException(), isNull);
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

class _FakeAccountRepository implements AccountRepository {
  _FakeAccountRepository({this.completer});

  final Completer<void>? completer;
  String? lastVerificationToken;
  int currentAccountCalls = 0;

  @override
  Future<void> confirmEmailVerification({required String token}) async {
    lastVerificationToken = token;
    final completer = this.completer;
    if (completer != null) {
      await completer.future;
    }
  }

  @override
  Future<AuthUser> currentAccount() async {
    currentAccountCalls += 1;
    return const AuthUser(
      id: 'user-1',
      email: 'person@example.com',
      role: 'PATIENT',
      status: 'ACTIVE',
      emailVerified: true,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
