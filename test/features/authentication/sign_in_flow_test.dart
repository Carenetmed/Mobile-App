import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/constants/navigators/router.dart';
import 'package:app_t/core/di/injection.dart';
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
            home: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: home,
            ),
            routes: {
              RouteName.dashboard:
                  (_) => const Scaffold(body: Text('dashboard')),
              RouteName.enterEmail:
                  (_) => const Scaffold(body: Text('Enter email')),
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

Future<void> _pumpProductionRoute(
  WidgetTester tester, {
  required String initialRoute,
}) async {
  await sl.reset();
  sl.registerSingleton<AuthRepository>(_FakeAuthRepository());
  sl.registerSingleton<GoogleIdTokenProvider>(_disabledGoogleProvider);
  addTearDown(() async => sl.reset());

  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (context, _) => MaterialApp(
            initialRoute: initialRoute,
            onGenerateRoute: generateRoute,
          ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Sign in flow', () {
    testWidgets('password visibility action has state-aware semantics', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        home: SignInEmail(googleIdTokenProvider: _disabledGoogleProvider),
      );

      expect(find.byTooltip('Show password'), findsOneWidget);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(find.byTooltip('Hide password'), findsOneWidget);
    });

    testWidgets('forgot-password action retains an accessible tap target', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        home: SignInEmail(googleIdTokenProvider: _disabledGoogleProvider),
      );

      final action = find.ancestor(
        of: find.text('Forgot Password?'),
        matching: find.byType(TextButton),
      );
      expect(action, findsOneWidget);
      expect(tester.getSize(action).height, greaterThanOrEqualTo(48));

      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('sign-in form fits compact width with 2x text', (tester) async {
      await _pumpWithRoutes(
        tester,
        home: SignInEmail(googleIdTokenProvider: _disabledGoogleProvider),
        screenSize: const Size(320, 568),
        textScaler: const TextScaler.linear(2),
      );

      expect(find.text('SIGN IN'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(
        find.text('Sign in to continue to your CareNet account.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('email entry hides unsupported identity providers', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        home: SignInEmail(googleIdTokenProvider: _disabledGoogleProvider),
      );

      expect(find.text('Continue with Phone'), findsNothing);
      expect(find.text('Continue with Facebook'), findsNothing);
      expect(find.text('Continue with Apple'), findsNothing);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

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

    testWidgets('legacy phone route opens canonical email sign-in', (
      tester,
    ) async {
      await _pumpProductionRoute(tester, initialRoute: RouteName.signInPhone);

      expect(find.byType(SignInEmail), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Continue with Phone'), findsNothing);
      expect(find.text('Phone Number'), findsNothing);
      expect(find.text('Continue with Facebook'), findsNothing);
      expect(find.text('Continue with Apple'), findsNothing);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('direct legacy widget construction uses email sign-in', (
      tester,
    ) async {
      await _pumpWithRoutes(
        tester,
        home: const SignInPhone(googleIdTokenProvider: _disabledGoogleProvider),
      );

      expect(find.byType(SignInEmail), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Phone Number'), findsNothing);
      expect(find.text('Continue with Facebook'), findsNothing);
      expect(find.text('Continue with Apple'), findsNothing);
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
  Future<AuthSession> googleSignIn({
    required String idToken,
    String? role,
  }) async {
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
