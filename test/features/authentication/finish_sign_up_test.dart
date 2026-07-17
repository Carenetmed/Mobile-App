import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_session.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_con.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpFinishSignUp(
  WidgetTester tester, {
  _FakeAuthRepository? authRepository,
  String? initialEmail,
  SignUpRole selectedRole = SignUpRole.patient,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            initialRoute: RouteName.finishSignUp,
            routes: {
              RouteName.finishSignUp:
                  (_) => FinSignUp(
                    authRepository: authRepository ?? _FakeAuthRepository(),
                    initialEmail: initialEmail,
                    selectedRole: selectedRole,
                  ),
              RouteName.communityAgreement:
                  (_) => const Scaffold(body: Text('community-agreement')),
              RouteName.medicalProfessional:
                  (_) => const Scaffold(body: Text('professional-onboarding')),
            },
          ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Finish sign up', () {
    testWidgets('blocks navigation when required fields are empty', (
      tester,
    ) async {
      await _pumpFinishSignUp(tester);

      await tester.tap(find.text(' Agree & continue'));
      await tester.pump();

      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
      expect(find.text('Birthday is required'), findsOneWidget);
      expect(find.text('Email Address is required'), findsOneWidget);
      expect(find.text('Please enter your password'), findsNWidgets(2));
      expect(find.text('community-agreement'), findsNothing);
    });

    testWidgets('registers through repository when form fields are valid', (
      tester,
    ) async {
      final repository = _FakeAuthRepository();
      await _pumpFinishSignUp(tester, authRepository: repository);

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'John');
      await tester.enterText(fields.at(1), 'Doe');
      await tester.tap(find.byType(TextFormField).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(fields.at(3), 'john@example.com');
      await tester.enterText(fields.at(4), 'Strong1!');
      await tester.enterText(fields.at(5), 'Strong1!');

      await tester.tap(find.text(' Agree & continue'));
      await tester.pumpAndSettle();

      expect(repository.registerCalls, 1);
      expect(repository.lastEmail, 'john@example.com');
      expect(repository.lastRole, 'PATIENT');
      expect(repository.lastProfile?['firstName'], 'John');
      expect(find.text('community-agreement'), findsOneWidget);
    });

    testWidgets(
      'registers professional role and routes to professional setup',
      (tester) async {
        final repository = _FakeAuthRepository();
        await _pumpFinishSignUp(
          tester,
          authRepository: repository,
          selectedRole: SignUpRole.professional,
        );

        await _fillValidForm(tester);
        await tester.tap(find.text(' Agree & continue'));
        await tester.pumpAndSettle();

        expect(repository.registerCalls, 1);
        expect(repository.lastRole, 'PROFESSIONAL');
        expect(find.text('professional-onboarding'), findsOneWidget);
        expect(find.text('community-agreement'), findsNothing);
      },
    );

    testWidgets('prefills email passed from email sign-up entry', (
      tester,
    ) async {
      await _pumpFinishSignUp(tester, initialEmail: 'hello@example.com');

      expect(
        find.widgetWithText(TextFormField, 'hello@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('shows safe backend error without navigation', (tester) async {
      await _pumpFinishSignUp(
        tester,
        authRepository: _FakeAuthRepository(
          failure: const AuthFailure(
            type: AuthFailureType.missingConfiguration,
            message: 'Backend is not configured yet.',
          ),
        ),
      );

      await _fillValidForm(tester);
      await tester.tap(find.text(' Agree & continue'));
      await tester.pumpAndSettle();

      expect(find.text('Backend is not configured yet.'), findsOneWidget);
      expect(find.text('community-agreement'), findsNothing);
    });

    testWidgets('shows loading state while registration is pending', (
      tester,
    ) async {
      final completer = Completer<AuthSession>();
      await _pumpFinishSignUp(
        tester,
        authRepository: _FakeAuthRepository(completer: completer),
      );

      await _fillValidForm(tester);
      await tester.tap(find.text(' Agree & continue'));
      await tester.pump();

      expect(find.text('Creating account...'), findsOneWidget);
      expect(find.text('community-agreement'), findsNothing);

      completer.complete(_session());
      await tester.pumpAndSettle();

      expect(find.text('community-agreement'), findsOneWidget);
    });

    testWidgets('blocks navigation when confirm password does not match', (
      tester,
    ) async {
      await _pumpFinishSignUp(tester);

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'John');
      await tester.enterText(fields.at(1), 'Doe');
      await tester.tap(find.byType(TextFormField).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(fields.at(3), 'john@example.com');
      await tester.enterText(fields.at(4), 'Strong1!');
      await tester.enterText(fields.at(5), 'Mismatch1!');

      await tester.tap(find.text(' Agree & continue'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(find.text('community-agreement'), findsNothing);
    });
  });
}

Future<void> _fillValidForm(WidgetTester tester) async {
  final fields = find.byType(EditableText);
  await tester.enterText(fields.at(0), 'John');
  await tester.enterText(fields.at(1), 'Doe');
  await tester.tap(find.byType(TextFormField).at(2));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  await tester.enterText(fields.at(3), 'john@example.com');
  await tester.enterText(fields.at(4), 'Strong1!');
  await tester.enterText(fields.at(5), 'Strong1!');
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.failure, this.completer});

  final AuthFailure? failure;
  final Completer<AuthSession>? completer;
  int registerCalls = 0;
  String? lastEmail;
  String? lastRole;
  Map<String, dynamic>? lastProfile;

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic> profile = const <String, dynamic>{},
  }) async {
    registerCalls += 1;
    lastEmail = email;
    lastRole = role;
    lastProfile = profile;
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthSession _session() {
  return const AuthSession(
    accessToken: 'access',
    refreshToken: 'refresh',
    tokenType: 'Bearer',
    expiresIn: 900,
    user: AuthUser(
      id: 'user-1',
      email: 'john@example.com',
      role: 'PATIENT',
      status: 'ACTIVE',
      emailVerified: false,
    ),
  );
}
