import 'dart:ui' show SemanticsAction;

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/patient_profile.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/presentation/pages/dashboard.dart';
import 'package:app_t/features/Home/presentation/pages/search_shell.dart';
import 'package:app_t/features/Home/presentation/pages/selected_dates_shell.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../notifications/notification_test_fakes.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required String role,
  NotificationCoordinator? notificationCoordinator,
  Size screenSize = _phoneSize,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.physicalSize = screenSize * tester.view.devicePixelRatio;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final sessionStore = InMemorySessionStore();
  await sessionStore.save(
    AuthSessionModel(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      tokenType: 'Bearer',
      expiresIn: 900,
      user: AuthUser(
        id: 'user-1',
        email: 'user@carenet.app',
        role: role,
        status: 'ACTIVE',
        emailVerified: true,
      ),
    ),
  );

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                  child: child!,
                ),
            home: Dashboard(
              sessionStore: sessionStore,
              profileRepository: _FakeProfileRepository(),
              onboardingRepository: _FakeOnboardingRepository(role: role),
              schedulingRepository: _FakeSchedulingRepository(),
              notificationCoordinator: notificationCoordinator,
            ),
            routes: <String, WidgetBuilder>{
              RouteName.notification:
                  (_) => const Scaffold(body: Text('notification-route')),
              RouteName.account:
                  (_) => const Scaffold(body: Text('account-route')),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

List<String?> _bottomLabels(WidgetTester tester) {
  final navigation = tester.widget<BottomNavigationBar>(
    find.byType(BottomNavigationBar),
  );
  expect(navigation.selectedItemColor, CarenetColors.brand);
  return navigation.items.map((item) => item.label).toList(growable: false);
}

void main() {
  testWidgets('patient sees the approved four destinations', (tester) async {
    await _pumpDashboard(tester, role: 'PATIENT');

    expect(_bottomLabels(tester), <String?>[
      'Home',
      'Find Care',
      'Appointments',
      'Messages',
    ]);
    expect(find.text('Post'), findsNothing);
    expect(find.text('Circles'), findsNothing);
    expect(find.text('Notifications'), findsNothing);
    expect(find.text('Profile'), findsNothing);
    expect(find.byType(Drawer), findsNothing);

    await tester.tap(find.text('Find Care'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchShellPage), findsOneWidget);
    expect(find.text('Find Care'), findsWidgets);
  });

  testWidgets('patient dashboard remains usable on compact large text', (
    tester,
  ) async {
    await _pumpDashboard(
      tester,
      role: 'PATIENT',
      screenSize: const Size(320, 568),
      textScaler: const TextScaler.linear(2),
    );

    expect(_bottomLabels(tester), <String?>[
      'Home',
      'Find Care',
      'Appointments',
      'Messages',
    ]);
    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(find.byTooltip('Account'), findsOneWidget);
    expect(tester.takeException(), isNull);

    for (final destination in <String>[
      'Find Care',
      'Appointments',
      'Messages',
    ]) {
      await tester.tap(find.text(destination).last);
      await tester.pumpAndSettle();
      expect(_bottomLabels(tester), <String?>[
        'Home',
        'Find Care',
        'Appointments',
        'Messages',
      ]);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('patient Home actions remain accessible at compact 2x text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await _pumpDashboard(
      tester,
      role: 'PATIENT',
      screenSize: const Size(320, 568),
      textScaler: const TextScaler.linear(2),
    );

    expect(find.text('Amina Yusuf'), findsOneWidget);
    expect(_bottomLabels(tester), <String?>[
      'Home',
      'Find Care',
      'Appointments',
      'Messages',
    ]);

    for (final tooltip in <String>['Notifications', 'Account']) {
      final control = find.byTooltip(tooltip);
      expect(control, findsOneWidget);
      expect(
        tester
            .getSemantics(control)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
    }

    await tester.dragUntilVisible(
      find.text('Search verified healthcare professionals'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    final primaryAction = find.ancestor(
      of: find.text('Search verified healthcare professionals'),
      matching: find.byType(InkWell),
    );
    expect(
      tester
          .getSemantics(primaryAction.first)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    await tester.tap(primaryAction.first);
    await tester.pumpAndSettle();
    expect(find.byType(SearchShellPage), findsOneWidget);
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      1,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Home'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('No appointments scheduled'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    expect(find.text('No appointments scheduled'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.widgetWithText(TextButton, 'Find care').last)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Find care').last);
    await tester.pumpAndSettle();
    expect(find.byType(SearchShellPage), findsOneWidget);
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      1,
    );
    expect(tester.takeException(), isNull);

    semantics.dispose();
  });

  testWidgets('professional sees the approved four destinations', (
    tester,
  ) async {
    await _pumpDashboard(tester, role: 'PROFESSIONAL');

    expect(_bottomLabels(tester), <String?>[
      'Home',
      'Schedule',
      'Appointments',
      'Messages',
    ]);

    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectedDatesShellPage), findsOneWidget);
    expect(find.text('Availability saved from backend.'), findsNothing);
  });

  testWidgets('professional dashboard remains accessible at compact 2x text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await _pumpDashboard(
      tester,
      role: 'PROFESSIONAL',
      screenSize: const Size(320, 568),
      textScaler: const TextScaler.linear(2),
    );

    expect(_bottomLabels(tester), <String?>[
      'Home',
      'Schedule',
      'Appointments',
      'Messages',
    ]);
    expect(find.text('Dr Ada Okafor'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Verified professional'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Verified professional').evaluate().isNotEmpty ||
          find.textContaining('Verification').evaluate().isNotEmpty,
      isTrue,
      reason: 'The professional verification status must be visible.',
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, 240));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(find.byTooltip('Account'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byTooltip('Notifications'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(
      tester
          .getSemantics(find.byTooltip('Account'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(
      tester
          .getSemantics(find.byType(InkWell).first)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    semantics.dispose();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Manage schedule'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectedDatesShellPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Home'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('No appointment activity yet'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.text('No appointment activity yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('header bell and avatar use retained routes', (tester) async {
    await _pumpDashboard(tester, role: 'PATIENT');

    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('notification-route'), findsOneWidget);

    Navigator.of(tester.element(find.text('notification-route'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    expect(find.text('account-route'), findsOneWidget);
  });

  testWidgets('header bell exposes the authoritative unread count', (
    tester,
  ) async {
    final coordinator = NotificationCoordinator(
      repository: FakeNotificationRepository(),
      installationStore: FakeNotificationInstallationStore(),
      transport: FakeNotificationTransport(),
      navigatorKey: GlobalKey<NavigatorState>(),
      metadataLoader:
          () async => const NotificationDeviceMetadata(
            platform: 'ANDROID',
            appId: 'com.carenet.app',
            appVersion: '1.0.0+1',
            locale: 'en_NG',
          ),
    )..unreadCount = 12;

    await _pumpDashboard(
      tester,
      role: 'PATIENT',
      notificationCoordinator: coordinator,
    );

    expect(find.text('12'), findsOneWidget);
    await tester.tap(find.byTooltip('Notifications, 12 unread'));
    await tester.pumpAndSettle();
    expect(find.text('notification-route'), findsOneWidget);
  });

  testWidgets('messages never expose seeded social conversations', (
    tester,
  ) async {
    await _pumpDashboard(tester, role: 'PATIENT');

    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(find.text('No appointment conversations yet'), findsOneWidget);
    expect(find.textContaining('Dr. Lagbaja'), findsNothing);
    expect(find.text('Events'), findsNothing);
    expect(find.text('Payment'), findsNothing);
  });

  testWidgets('switching tabs preserves Find Care state', (tester) async {
    await _pumpDashboard(tester, role: 'PATIENT');

    await tester.tap(find.text('Find Care'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'cardiology');
    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Appointments'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Find Care'));
    await tester.pumpAndSettle();

    expect(find.text('cardiology'), findsOneWidget);
  });

  testWidgets('system back returns a secondary tab to Home', (tester) async {
    await _pumpDashboard(tester, role: 'PATIENT');

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Appointments'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      2,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      0,
    );
    expect(find.text('Find care'), findsWidgets);
  });

  testWidgets('unknown session role fails closed', (tester) async {
    await _pumpDashboard(tester, role: 'ADMIN');

    expect(find.text('Your account role is unavailable.'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<PatientProfile?> patientMe() async {
    return const PatientProfile(name: 'Amina Yusuf');
  }

  @override
  Future<ProfessionalProfile?> professionalMe() async {
    return const ProfessionalProfile(
      displayName: 'Dr Ada Okafor',
      category: 'Doctor',
      verificationStatus: 'VERIFIED',
    );
  }

  @override
  Future<List<PublicProfessional>> publicProfessionals() async {
    return const <PublicProfessional>[
      PublicProfessional(
        id: 'professional-1',
        displayName: 'Dr Care',
        category: 'Doctor',
        specialty: 'Cardiology',
        verified: true,
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOnboardingRepository implements OnboardingRepository {
  const _FakeOnboardingRepository({required this.role});

  final String role;

  @override
  Future<AccountReadiness> accountReadiness() async {
    final professional = role == 'PROFESSIONAL';
    return AccountReadiness(
      account: ReadinessAccount(
        role: role,
        status: 'ACTIVE',
        emailVerified: true,
      ),
      patient:
          professional
              ? null
              : const PatientReadiness(
                profileStatus: 'COMPLETE',
                requiredFields: <String>[],
              ),
      professional:
          professional
              ? const ProfessionalReadiness(
                applicationStatus: 'APPROVED',
                verificationStatus: 'VERIFIED',
                requiredProfileFields: <String>[],
                requiredEvidence: <String>[],
                missingEvidence: <String>[],
              )
              : null,
      nextAction: 'DASHBOARD',
      requiredActions: const <String>[],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSchedulingRepository implements SchedulingRepository {
  @override
  Future<List<AvailabilityWindow>> ownAvailability() async {
    return const <AvailabilityWindow>[];
  }

  @override
  Future<List<AppointmentSummary>> ownAppointments() async {
    return const <AppointmentSummary>[];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
