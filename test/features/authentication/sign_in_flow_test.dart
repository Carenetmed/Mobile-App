import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_session.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
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
              RouteName.signInPhone:
                  (_) => SignInPhone(
                    googleIdTokenProvider: _disabledGoogleProvider,
                  ),
              RouteName.signInEmail:
                  (_) => SignInEmail(
                    googleIdTokenProvider: _disabledGoogleProvider,
                  ),
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
    testWidgets(
      'sign in email blocks invalid input and navigates after backend success',
      (tester) async {
        final repository = _FakeAuthRepository();
        await _pumpWithRoutes(
          tester,
          home: SignInEmail(
            authRepository: repository,
            googleIdTokenProvider: _disabledGoogleProvider,
          ),
        );

        await tester.tap(find.text('Continue'));
        await tester.pump();

        expect(find.text('Email Address is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);

        final fields = find.byType(EditableText);
        await tester.enterText(fields.at(0), 'hello@example.com');
        await tester.enterText(fields.at(1), 'secret123');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(repository.loginCalls, 1);
        expect(repository.lastEmail, 'hello@example.com');
        expect(find.text('dashboard'), findsOneWidget);
      },
    );

    testWidgets('sign in email shows safe backend error without navigation', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        home: SignInEmail(
          authRepository: _FakeAuthRepository(
            failure: const AuthFailure(
              type: AuthFailureType.missingConfiguration,
              message: 'Backend is not configured yet.',
            ),
          ),
          googleIdTokenProvider: _disabledGoogleProvider,
        ),
      );

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'hello@example.com');
      await tester.enterText(fields.at(1), 'secret123');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Backend is not configured yet.'), findsOneWidget);
      expect(find.text('dashboard'), findsNothing);
    });

    testWidgets(
      'sign in email shows loading state while repository is pending',
      (tester) async {
        final completer = Completer<AuthSession>();
        await _pumpWithRoutes(
          tester,
          home: SignInEmail(
            authRepository: _FakeAuthRepository(completer: completer),
            googleIdTokenProvider: _disabledGoogleProvider,
          ),
        );

        final fields = find.byType(EditableText);
        await tester.enterText(fields.at(0), 'hello@example.com');
        await tester.enterText(fields.at(1), 'secret123');
        await tester.tap(find.text('Continue'));
        await tester.pump();

        expect(find.text('Signing in...'), findsOneWidget);
        expect(find.text('dashboard'), findsNothing);

        completer.complete(_session());
        await tester.pumpAndSettle();

        expect(find.text('dashboard'), findsOneWidget);
      },
    );

    testWidgets(
      'sign in email Google button authenticates with backend token',
      (tester) async {
        final repository = _FakeAuthRepository();
        await _pumpWithRoutes(
          tester,
          home: SignInEmail(
            authRepository: repository,
            googleIdTokenProvider: _FakeGoogleIdTokenProvider(
              idToken: 'id-token',
            ),
          ),
        );

        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();

        expect(repository.googleSignInCalls, 1);
        expect(repository.lastGoogleIdToken, 'id-token');
        expect(find.text('dashboard'), findsOneWidget);
      },
    );

    testWidgets('sign in email Google button shows safe provider failure', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        home: SignInEmail(
          authRepository: _FakeAuthRepository(),
          googleIdTokenProvider: _FakeGoogleIdTokenProvider(
            failure: const AuthFailure(
              type: AuthFailureType.validation,
              message: 'Google sign-in was cancelled.',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.text('Google sign-in was cancelled.'), findsOneWidget);
      expect(find.text('dashboard'), findsNothing);
    });

    testWidgets('sign in email Google button stays disabled without config', (
      tester,
    ) async {
      final repository = _FakeAuthRepository();
      await _pumpWithRoutes(
        tester,
        home: SignInEmail(
          authRepository: repository,
          googleIdTokenProvider: _FakeGoogleIdTokenProvider(
            isConfigured: false,
            idToken: 'id-token',
          ),
        ),
      );

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(repository.googleSignInCalls, 0);
      expect(find.text('dashboard'), findsNothing);
    });

    testWidgets('sign in phone validates fields before navigation', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        home: SignInPhone(googleIdTokenProvider: _disabledGoogleProvider),
      );

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

    testWidgets('sign in phone Google button uses backend Google sign-in', (
      tester,
    ) async {
      final repository = _FakeAuthRepository();
      await _pumpWithRoutes(
        tester,
        home: SignInPhone(
          authRepository: repository,
          googleIdTokenProvider: _FakeGoogleIdTokenProvider(
            idToken: 'phone-id',
          ),
        ),
      );

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(repository.googleSignInCalls, 1);
      expect(repository.lastGoogleIdToken, 'phone-id');
      expect(find.text('dashboard'), findsOneWidget);
    });

    testWidgets('sign in email routes to sign up email entry', (tester) async {
      await _pumpWithRoutes(
        tester,
        home: SignInEmail(googleIdTokenProvider: _disabledGoogleProvider),
      );

      await tester.tap(find.text('Don\'t have an account? Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('sign-up-email'), findsOneWidget);
    });

    testWidgets('sign in phone routes to sign up phone entry', (tester) async {
      await _pumpWithRoutes(
        tester,
        home: SignInPhone(googleIdTokenProvider: _disabledGoogleProvider),
      );

      await tester.tap(find.text('Don\'t have an account? Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('sign-up-phone'), findsOneWidget);
    });
  });
}

const _disabledGoogleProvider = _FakeGoogleIdTokenProvider(isConfigured: false);

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.failure, this.completer});

  final AuthFailure? failure;
  final Completer<AuthSession>? completer;
  int loginCalls = 0;
  int googleSignInCalls = 0;
  String? lastEmail;
  String? lastGoogleIdToken;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    loginCalls += 1;
    lastEmail = email;
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    final completer = this.completer;
    if (completer != null) {
      return completer.future;
    }
    return _session();
  }

  @override
  Future<AuthSession> googleSignIn({required String idToken}) async {
    googleSignInCalls += 1;
    lastGoogleIdToken = idToken;
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    return _session();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGoogleIdTokenProvider implements GoogleIdTokenProvider {
  const _FakeGoogleIdTokenProvider({
    this.isConfigured = true,
    this.idToken,
    this.failure,
  });

  @override
  final bool isConfigured;
  final String? idToken;
  final AuthFailure? failure;

  @override
  Future<String> signInIdToken() async {
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    return idToken ?? 'google-id-token';
  }
}

AuthSession _session() {
  return const AuthSession(
    accessToken: 'access',
    refreshToken: 'refresh',
    tokenType: 'Bearer',
    expiresIn: 900,
    user: AuthUser(
      id: 'user-1',
      email: 'hello@example.com',
      role: 'PATIENT',
      status: 'ACTIVE',
      emailVerified: false,
    ),
  );
}
