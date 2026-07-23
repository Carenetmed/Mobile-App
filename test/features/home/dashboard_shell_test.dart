import 'package:app_t/core/constants/navigators/routeName.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpDashboard(WidgetTester tester, {required String role}) async {
  tester.view.physicalSize = _phoneSize;
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
            home: Dashboard(
              sessionStore: sessionStore,
              profileRepository: _FakeProfileRepository(),
              onboardingRepository: _FakeOnboardingRepository(role: role),
              schedulingRepository: _FakeSchedulingRepository(),
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
