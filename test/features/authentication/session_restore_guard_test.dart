import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_session.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/splash/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpSplash(
  WidgetTester tester, {
  required _FakeAuthRepository repository,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: SplashScreen(authRepository: repository),
            routes: <String, WidgetBuilder>{
              RouteName.dashboard:
                  (_) => const Scaffold(body: Text('dashboard')),
              RouteName.onboarding:
                  (_) => const Scaffold(body: Text('onboarding')),
            },
          ),
    ),
  );
}

void main() {
  group('Session restore launch guard', () {
    testWidgets('routes authenticated users to dashboard', (tester) async {
      final repository = _FakeAuthRepository(session: _session());

      await _pumpSplash(tester, repository: repository);
      await tester.pump(const Duration(milliseconds: 801));
      await tester.pumpAndSettle();

      expect(repository.restoreCalls, 1);
      expect(find.text('dashboard'), findsOneWidget);
      expect(find.text('onboarding'), findsNothing);
    });

    testWidgets('routes missing sessions to onboarding', (tester) async {
      final repository = _FakeAuthRepository();

      await _pumpSplash(tester, repository: repository);
      await tester.pump(const Duration(milliseconds: 801));
      await tester.pumpAndSettle();

      expect(repository.restoreCalls, 1);
      expect(find.text('onboarding'), findsOneWidget);
      expect(find.text('dashboard'), findsNothing);
    });

    testWidgets('routes invalid stored sessions to onboarding', (tester) async {
      final repository = _FakeAuthRepository(
        session: _session(accessToken: '', userId: ''),
      );

      await _pumpSplash(tester, repository: repository);
      await tester.pump(const Duration(milliseconds: 801));
      await tester.pumpAndSettle();

      expect(repository.restoreCalls, 1);
      expect(find.text('onboarding'), findsOneWidget);
      expect(find.text('dashboard'), findsNothing);
    });

    testWidgets('routes restore failures to onboarding safely', (tester) async {
      final repository = _FakeAuthRepository(throwsOnRestore: true);

      await _pumpSplash(tester, repository: repository);
      await tester.pump(const Duration(milliseconds: 801));
      await tester.pumpAndSettle();

      expect(repository.restoreCalls, 1);
      expect(find.text('onboarding'), findsOneWidget);
      expect(find.text('dashboard'), findsNothing);
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.session, this.throwsOnRestore = false});

  final AuthSession? session;
  final bool throwsOnRestore;
  int restoreCalls = 0;

  @override
  Future<AuthSession?> restore() async {
    restoreCalls += 1;
    if (throwsOnRestore) {
      throw StateError('restore failed');
    }
    return session;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthSession _session({
  String accessToken = 'access',
  String userId = 'user-1',
}) {
  return AuthSession(
    accessToken: accessToken,
    refreshToken: 'refresh',
    tokenType: 'Bearer',
    expiresIn: 900,
    user: AuthUser(
      id: userId,
      email: 'patient@example.com',
      role: 'PATIENT',
      status: 'ACTIVE',
      emailVerified: false,
    ),
  );
}
