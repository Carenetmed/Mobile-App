import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/diagnostics/diagnostic_consent_store.dart';
import 'package:app_t/core/diagnostics/diagnostic_preferences_controller.dart';
import 'package:app_t/core/diagnostics/release_health_api_client.dart';
import 'package:app_t/core/diagnostics/release_health_coordinator.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/Home/presentation/pages/account_shell.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = AuthUser(
  id: 'synthetic-patient',
  email: 'patient@example.invalid',
  role: 'PATIENT',
  status: 'ACTIVE',
  emailVerified: true,
);

class _Account implements AccountRepository {
  @override
  Future<AuthUser> currentAccount() async => _user;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Auth implements AuthRepository {
  _Auth(this.sessions);
  final SessionStore sessions;
  int exits = 0;
  @override
  Future<void> logout() async {
    exits++;
    await sessions.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transport implements ReleaseHealthTransport {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Consent implements DiagnosticConsentStore {
  String? generation;
  @override
  Future<bool> isEnabledFor(String value) async => generation == value;
  @override
  Future<void> enableFor(String value) async {
    generation = value;
  }

  @override
  Future<void> disableFor(String value) async {
    if (generation == value) generation = null;
  }
}

void main() {
  late InMemorySessionStore sessions;
  late DiagnosticPreferencesController preferences;
  late ReleaseHealthCoordinator coordinator;
  late _Auth auth;
  late _Consent consent;
  setUp(() async {
    consent = _Consent();
    sessions = InMemorySessionStore();
    await sessions.save(
      const AuthSessionModel(
        accessToken: 'synthetic-token',
        refreshToken: 'synthetic-refresh',
        tokenType: 'Bearer',
        expiresIn: 900,
        user: _user,
      ),
    );
    coordinator = ReleaseHealthCoordinator(
      sessions: sessions,
      consent: consent,
      transport: _Transport(),
      metadata: () async => throw StateError('Not used'),
    );
    preferences = DiagnosticPreferencesController(
      sessions: sessions,
      consent: consent,
      coordinator: coordinator,
    );
    sl.registerSingleton<DiagnosticPreferencesController>(preferences);
    auth = _Auth(sessions);
  });
  tearDown(() async {
    await sl.unregister<DiagnosticPreferencesController>();
    preferences.dispose();
    coordinator.dispose();
  });

  Future<void> pumpAccount(WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder:
            (_, _) => MaterialApp(
              home: AccountShellPage(
                authRepository: auth,
                accountRepository: _Account(),
              ),
              routes: {
                RouteName.onboarding:
                    (_) => const Scaffold(body: Text('signed-out-route')),
              },
            ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'account exposes default-off diagnostics and saves explicit opt-in',
    (tester) async {
      await pumpAccount(tester);
      await tester.scrollUntilVisible(find.byType(Switch), 200);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(preferences.enabled, isTrue);
      expect(
        await consent.isEnabledFor((await sessions.capture())!.generation),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('account logout invalidates diagnostic binding before leaving', (
    tester,
  ) async {
    await pumpAccount(tester);
    await preferences.setEnabled(true);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Log out'), 250);
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(auth.exits, 1);
    expect(preferences.enabled, isFalse);
    expect(preferences.canChange, isFalse);
    expect(await sessions.capture(), isNull);
    expect(find.text('signed-out-route'), findsOneWidget);
  });
}
