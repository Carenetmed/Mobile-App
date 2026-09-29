import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_session.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/services/onboarding_api_client.dart';
import 'package:app_t/features/Home/data/storage/booking_intent_store.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/booking_intent.dart';
import 'package:app_t/features/Home/domain/services/booking_resume_service.dart';
import 'package:app_t/features/splash/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpSplash(
  WidgetTester tester, {
  required _FakeAuthRepository repository,
  BookingResumeService? bookingResumeService,
  Size screenSize = _phoneSize,
  TextScaler textScaler = TextScaler.noScaling,
  Duration refreshTimeout = const Duration(seconds: 10),
  Duration bookingResumeTimeout = const Duration(seconds: 10),
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
            home: SplashScreen(
              authRepository: repository,
              bookingResumeService: bookingResumeService,
              refreshTimeout: refreshTimeout,
              bookingResumeTimeout: bookingResumeTimeout,
            ),
            routes: <String, WidgetBuilder>{
              RouteName.dashboard:
                  (_) => const Scaffold(body: Text('dashboard')),
              RouteName.onboarding:
                  (_) => const Scaffold(body: Text('onboarding')),
              RouteName.patientOnboardingSetup:
                  (_) => const Scaffold(body: Text('patient setup')),
              RouteName.specialistDetails:
                  (context) => Scaffold(
                    body: Text(
                      'detail ${ModalRoute.of(context)!.settings.arguments}',
                    ),
                  ),
            },
          ),
    ),
  );
}

void main() {
  group('Session restore launch guard', () {
    testWidgets('splash remains readable at compact width with 2x text', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await _pumpSplash(
          tester,
          repository: _FakeAuthRepository(),
          screenSize: const Size(320, 568),
          textScaler: const TextScaler.linear(2),
        );

        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('CARENET'), findsOneWidget);
        expect(find.text('HEALTH SERVICES'), findsOneWidget);
        expect(tester.getSemantics(find.text('CARENET')).label, 'CARENET');
        expect(
          tester.getSemantics(find.text('HEALTH SERVICES')).label,
          'HEALTH SERVICES',
        );
      } finally {
        semantics.dispose();
      }
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 801));
      await tester.pumpAndSettle();
      expect(find.text('onboarding'), findsOneWidget);
    });

    testWidgets('routes authenticated users to dashboard', (tester) async {
      final repository = _FakeAuthRepository(session: _session());

      await _pumpSplash(tester, repository: repository);
      await tester.pump(const Duration(milliseconds: 801));
      await tester.pumpAndSettle();

      expect(repository.restoreCalls, 1);
      expect(repository.refreshCalls, 1);
      expect(find.text('dashboard'), findsOneWidget);
      expect(find.text('onboarding'), findsNothing);
    });

    testWidgets('bounded refresh cannot strand an authenticated launch', (
      tester,
    ) async {
      final repository = _FakeAuthRepository(
        session: _session(),
        refreshCompleter: Completer<AuthSession>(),
      );

      await _pumpSplash(
        tester,
        repository: repository,
        refreshTimeout: const Duration(milliseconds: 100),
      );
      await tester.pump(const Duration(milliseconds: 901));
      await tester.pumpAndSettle();

      expect(repository.refreshCalls, 1);
      expect(find.text('dashboard'), findsOneWidget);
      expect(find.text('onboarding'), findsNothing);
    });

    testWidgets(
      'resumes a persisted booking detail after authenticated app restart',
      (tester) async {
        final session = _session();
        final sessionStore = InMemorySessionStore()..save(session);
        final intentStore =
            InMemoryBookingIntentStore()..save(
              BookingIntent(
                professionalProfileId: 'professional-42',
                startAt: DateTime.utc(2026, 7, 24, 9),
                endAt: DateTime.utc(2026, 7, 24, 9, 30),
                durationMinutes: 30,
                idempotencyKey: 'booking-key',
                resumeRoute: RouteName.specialistDetails,
                createdAt: DateTime.utc(2026, 7, 23),
                expiresAt: DateTime.utc(2027, 7, 23),
                accountUserId: session.user.id,
              ),
            );
        final resumeService = BookingResumeService(
          bookingIntentStore: intentStore,
          sessionStore: sessionStore,
          onboardingRepository: _ReadyPatientOnboardingRepository(
            sessionStore: sessionStore,
          ),
        );

        await _pumpSplash(
          tester,
          repository: _FakeAuthRepository(session: session),
          bookingResumeService: resumeService,
        );
        await tester.pump(const Duration(milliseconds: 801));
        await tester.pumpAndSettle();

        expect(find.text('detail professional-42'), findsOneWidget);
        expect(find.text('dashboard'), findsNothing);
      },
    );

    testWidgets('bounded booking recovery cannot strand app startup', (
      tester,
    ) async {
      final session = _session();
      final sessionStore = InMemorySessionStore()..save(session);
      final intentStore =
          InMemoryBookingIntentStore()..save(
            BookingIntent(
              professionalProfileId: 'professional-slow',
              startAt: DateTime.utc(2026, 7, 24, 9),
              endAt: DateTime.utc(2026, 7, 24, 9, 30),
              durationMinutes: 30,
              idempotencyKey: 'booking-key-slow',
              resumeRoute: RouteName.specialistDetails,
              createdAt: DateTime.utc(2026, 7, 23),
              expiresAt: DateTime.utc(2027, 7, 23),
              accountUserId: session.user.id,
            ),
          );
      final readinessCompleter = Completer<AccountReadiness>();
      final resumeService = BookingResumeService(
        bookingIntentStore: intentStore,
        sessionStore: sessionStore,
        onboardingRepository: _ReadyPatientOnboardingRepository(
          sessionStore: sessionStore,
          readinessCompleter: readinessCompleter,
        ),
      );

      await _pumpSplash(
        tester,
        repository: _FakeAuthRepository(session: session),
        bookingResumeService: resumeService,
        bookingResumeTimeout: const Duration(milliseconds: 100),
      );
      await tester.pump(const Duration(milliseconds: 901));
      await tester.pumpAndSettle();

      expect(find.text('dashboard'), findsOneWidget);
      expect(await intentStore.read(), isNotNull);
    });

    testWidgets('routes missing sessions to onboarding', (tester) async {
      final repository = _FakeAuthRepository();

      await _pumpSplash(tester, repository: repository);
      await tester.pump(const Duration(milliseconds: 801));
      await tester.pumpAndSettle();

      expect(repository.restoreCalls, 1);
      expect(repository.refreshCalls, 0);
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
      expect(repository.refreshCalls, 0);
      expect(find.text('onboarding'), findsOneWidget);
      expect(find.text('dashboard'), findsNothing);
    });

    testWidgets('routes restore failures to onboarding safely', (tester) async {
      final repository = _FakeAuthRepository(throwsOnRestore: true);

      await _pumpSplash(tester, repository: repository);
      await tester.pump(const Duration(milliseconds: 801));
      await tester.pumpAndSettle();

      expect(repository.restoreCalls, 1);
      expect(repository.refreshCalls, 0);
      expect(find.text('onboarding'), findsOneWidget);
      expect(find.text('dashboard'), findsNothing);
    });
  });
}

class _ReadyPatientOnboardingRepository extends OnboardingRepository {
  _ReadyPatientOnboardingRepository({
    required super.sessionStore,
    this.readinessCompleter,
  }) : super(apiClient: _UnusedOnboardingApiClient());

  final Completer<AccountReadiness>? readinessCompleter;

  @override
  Future<AccountReadiness> accountReadiness() async {
    if (readinessCompleter case final completer?) return completer.future;
    return const AccountReadiness(
      account: ReadinessAccount(
        role: 'PATIENT',
        status: 'ACTIVE',
        emailVerified: true,
      ),
      patient: PatientReadiness(
        profileStatus: 'COMPLETE',
        requiredFields: <String>[],
      ),
      nextAction: 'DASHBOARD',
      requiredActions: <String>[],
    );
  }
}

class _UnusedOnboardingApiClient implements OnboardingApiClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.session,
    this.throwsOnRestore = false,
    this.refreshCompleter,
  });

  final AuthSession? session;
  final bool throwsOnRestore;
  final Completer<AuthSession>? refreshCompleter;
  int restoreCalls = 0;
  int refreshCalls = 0;

  @override
  Future<AuthSession?> restore() async {
    restoreCalls += 1;
    if (throwsOnRestore) {
      throw StateError('restore failed');
    }
    return session;
  }

  @override
  Future<AuthSession> refresh() async {
    refreshCalls += 1;
    if (refreshCompleter case final completer?) return completer.future;
    final current = session;
    if (current == null) throw StateError('No session to refresh');
    return current;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthSessionModel _session({
  String accessToken = 'access',
  String userId = 'user-1',
}) {
  return AuthSessionModel(
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
