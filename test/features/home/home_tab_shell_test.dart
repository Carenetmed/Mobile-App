import 'dart:async';

import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/patient_profile.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/features/Home/presentation/pages/home.dart';
import 'package:app_t/features/Home/presentation/state/marketplace_home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);
final DateTime _now = DateTime.utc(2026, 7, 23, 9);

Future<void> _pumpHome(
  WidgetTester tester, {
  required MarketplaceHomeRole role,
  _FakeProfileRepository? profileRepository,
  _FakeOnboardingRepository? onboardingRepository,
  _FakeSchedulingRepository? schedulingRepository,
  VoidCallback? onPrimary,
  VoidCallback? onAppointments,
  ValueChanged<String>? onAppointment,
  ValueChanged<AccountReadiness?>? onReadiness,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: Scaffold(
              body: Home(
                role: role,
                profileRepository:
                    profileRepository ?? _FakeProfileRepository(),
                onboardingRepository:
                    onboardingRepository ??
                    _FakeOnboardingRepository(
                      readiness: _readiness(role: role),
                    ),
                schedulingRepository:
                    schedulingRepository ?? _FakeSchedulingRepository(),
                onPrimaryAction: onPrimary ?? () {},
                onAppointments: onAppointments ?? () {},
                onAppointment: onAppointment,
                onReadinessAction: onReadiness ?? (_) {},
                now: _now,
              ),
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('marketplace Home state selection', () {
    test('selects earliest request and future accepted appointment', () {
      final state = MarketplaceHomeState(
        role: MarketplaceHomeRole.patient,
        appointments: <AppointmentSummary>[
          _appointment(
            id: 'request-b',
            status: AppointmentStatus.requested,
            start: _now.add(const Duration(days: 2)),
          ),
          _appointment(
            id: 'accepted',
            status: AppointmentStatus.accepted,
            start: _now.add(const Duration(days: 1)),
          ),
          _appointment(
            id: 'request-a',
            status: AppointmentStatus.requested,
            start: _now.add(const Duration(days: 2)),
          ),
          _appointment(
            id: 'past',
            status: AppointmentStatus.accepted,
            start: _now.subtract(const Duration(hours: 1)),
          ),
        ],
      );

      expect(state.pendingRequest()?.id, 'request-a');
      expect(state.nextUpcoming(_now)?.id, 'accepted');
    });

    test('professional action priority is readiness then requests', () {
      final incomplete = MarketplaceHomeState(
        role: MarketplaceHomeRole.professional,
        readiness: _readiness(
          role: MarketplaceHomeRole.professional,
          nextAction: 'PROFESSIONAL_RESUME_APPLICATION',
          requiredProfileFields: const <String>['licenseNumber'],
        ),
        appointments: <AppointmentSummary>[
          _appointment(
            id: 'request',
            status: AppointmentStatus.requested,
            start: _now,
          ),
        ],
      );
      expect(
        incomplete.requiredAction(_now),
        HomeRequiredAction.completeProfile,
      );

      final ready = MarketplaceHomeState(
        role: MarketplaceHomeRole.professional,
        readiness: _readiness(role: MarketplaceHomeRole.professional),
        appointments: incomplete.appointments,
        availability: const <AvailabilityWindow>[
          AvailabilityWindow(
            id: 'window',
            weekday: 1,
            startMinute: 540,
            endMinute: 600,
            timezone: 'Africa/Lagos',
            active: true,
          ),
        ],
      );
      expect(ready.requiredAction(_now), HomeRequiredAction.respondToRequest);
    });

    test('failed refresh retains previously loaded backend sections', () async {
      final previous = MarketplaceHomeState(
        role: MarketplaceHomeRole.patient,
        patientProfile: const PatientProfile(name: 'Amina Yusuf'),
        appointments: <AppointmentSummary>[
          _appointment(
            id: 'accepted',
            status: AppointmentStatus.accepted,
            start: _now.add(const Duration(days: 1)),
          ),
        ],
      );
      final state = await MarketplaceHomeCoordinator(
        role: MarketplaceHomeRole.patient,
        profileRepository: _FakeProfileRepository(failPatient: true),
        onboardingRepository: _FakeOnboardingRepository(
          readiness: _readiness(role: MarketplaceHomeRole.patient),
        ),
        schedulingRepository: _FakeSchedulingRepository(
          failAppointmentsAlways: true,
        ),
      ).load(previous: previous);

      expect(state.patientProfile?.name, 'Amina Yusuf');
      expect(state.appointments.single.id, 'accepted');
      expect(
        state.failedSections,
        containsAll(<HomeDataSection>[
          HomeDataSection.profile,
          HomeDataSection.appointments,
        ]),
      );
    });
  });

  group('patient Home', () {
    testWidgets('uses backend identity and offers retained Find Care', (
      tester,
    ) async {
      var findCareCalls = 0;
      await _pumpHome(
        tester,
        role: MarketplaceHomeRole.patient,
        profileRepository: _FakeProfileRepository(
          patient: const PatientProfile(name: 'Amina Yusuf'),
        ),
        onPrimary: () => findCareCalls += 1,
      );

      expect(find.text('Amina Yusuf'), findsOneWidget);
      expect(find.text('Find care'), findsWidgets);
      expect(find.text('No appointments scheduled'), findsOneWidget);
      expect(find.text('Complete your profile'), findsNothing);
      expect(find.text('Feed'), findsNothing);
      expect(find.textContaining('payment', findRichText: true), findsNothing);
      expect(find.textContaining('Join consultation'), findsNothing);
      expect(find.textContaining('recommended'), findsNothing);

      await tester.tap(find.text('Find care').first);
      expect(findCareCalls, 1);
    });

    testWidgets('shows backend profile readiness action only when incomplete', (
      tester,
    ) async {
      AccountReadiness? selected;
      final readiness = _readiness(
        role: MarketplaceHomeRole.patient,
        nextAction: 'PATIENT_SETUP',
        patientStatus: 'DRAFT',
      );
      await _pumpHome(
        tester,
        role: MarketplaceHomeRole.patient,
        onboardingRepository: _FakeOnboardingRepository(readiness: readiness),
        onReadiness: (value) => selected = value,
      );

      expect(find.text('Complete your profile'), findsOneWidget);
      await tester.tap(find.text('Continue setup'));
      expect(selected, same(readiness));
    });

    testWidgets('surfaces pending and nearest upcoming backend appointments', (
      tester,
    ) async {
      String? openedAppointmentId;
      await _pumpHome(
        tester,
        role: MarketplaceHomeRole.patient,
        onAppointment: (appointmentId) => openedAppointmentId = appointmentId,
        schedulingRepository: _FakeSchedulingRepository(
          appointments: <AppointmentSummary>[
            _appointment(
              id: 'later',
              status: AppointmentStatus.accepted,
              start: _now.add(const Duration(days: 3)),
            ),
            _appointment(
              id: 'request',
              status: AppointmentStatus.requested,
              start: _now.add(const Duration(days: 2)),
            ),
            _appointment(
              id: 'next',
              status: AppointmentStatus.accepted,
              start: _now.add(const Duration(days: 1)),
            ),
          ],
        ),
      );

      expect(find.text('Waiting for professional response'), findsWidgets);
      expect(find.text('Accepted appointment'), findsOneWidget);
      expect(find.textContaining('Jul 24'), findsOneWidget);

      await tester.tap(find.text('Accepted appointment'));
      expect(openedAppointmentId, 'next');
    });
  });

  group('professional Home', () {
    testWidgets('shows truthful verification and routes its action', (
      tester,
    ) async {
      AccountReadiness? selected;
      final readiness = _readiness(
        role: MarketplaceHomeRole.professional,
        verificationStatus: 'NOT_SUBMITTED',
        nextAction: 'PROFESSIONAL_UPLOAD_EVIDENCE',
      );
      await _pumpHome(
        tester,
        role: MarketplaceHomeRole.professional,
        profileRepository: _FakeProfileRepository(
          professional: const ProfessionalProfile(
            displayName: 'Dr Ada Okafor',
            category: 'Doctor',
            verificationStatus: 'NOT_SUBMITTED',
          ),
        ),
        onboardingRepository: _FakeOnboardingRepository(readiness: readiness),
        onReadiness: (value) => selected = value,
      );

      expect(find.text('Dr Ada Okafor'), findsOneWidget);
      expect(find.text('Verification not submitted'), findsOneWidget);
      expect(find.text('Submit verification evidence'), findsOneWidget);
      await tester.tap(find.text('Open verification'));
      expect(selected, same(readiness));
    });

    testWidgets('surfaces request and keeps Schedule as the primary action', (
      tester,
    ) async {
      var scheduleCalls = 0;
      await _pumpHome(
        tester,
        role: MarketplaceHomeRole.professional,
        schedulingRepository: _FakeSchedulingRepository(
          appointments: <AppointmentSummary>[
            _appointment(
              id: 'request',
              status: AppointmentStatus.requested,
              start: _now.add(const Duration(hours: 2)),
            ),
          ],
          availability: const <AvailabilityWindow>[
            AvailabilityWindow(
              id: 'window',
              weekday: 4,
              startMinute: 600,
              endMinute: 720,
              timezone: 'Africa/Lagos',
              active: true,
            ),
          ],
        ),
        onPrimary: () => scheduleCalls += 1,
      );

      expect(find.text('Appointment request waiting'), findsOneWidget);
      expect(find.text('Appointment request'), findsOneWidget);
      expect(find.textContaining('earnings'), findsNothing);
      expect(find.textContaining('demand'), findsNothing);
      await tester.tap(find.text('Manage schedule'));
      expect(scheduleCalls, 1);
    });

    testWidgets('empty state offers real availability management', (
      tester,
    ) async {
      await _pumpHome(tester, role: MarketplaceHomeRole.professional);

      expect(find.text('Add your availability'), findsOneWidget);
      expect(find.text('No appointment activity yet'), findsOneWidget);
    });
  });

  testWidgets(
    'partial backend failure remains recoverable and refresh retries',
    (tester) async {
      final scheduling = _FakeSchedulingRepository(failAppointmentsOnce: true);
      await _pumpHome(
        tester,
        role: MarketplaceHomeRole.patient,
        schedulingRepository: scheduling,
      );

      expect(find.text('Some information is unavailable'), findsOneWidget);
      await tester.tap(find.byTooltip('Refresh Home'));
      await tester.pumpAndSettle();
      expect(scheduling.appointmentCalls, 2);
      expect(find.text('Some information is unavailable'), findsNothing);
    },
  );

  testWidgets('repeated retry does not start concurrent repository loads', (
    tester,
  ) async {
    final retryCompleter = Completer<List<AppointmentSummary>>();
    final scheduling = _FakeSchedulingRepository(
      failAppointmentsOnce: true,
      retryCompleter: retryCompleter,
    );
    await _pumpHome(
      tester,
      role: MarketplaceHomeRole.patient,
      schedulingRepository: scheduling,
    );

    await tester.tap(find.byTooltip('Refresh Home'));
    await tester.pump();
    await tester.tap(find.byTooltip('Refresh Home'));
    await tester.pump();
    expect(scheduling.appointmentCalls, 2);

    retryCompleter.complete(const <AppointmentSummary>[]);
    await tester.pumpAndSettle();
    expect(find.text('Some information is unavailable'), findsNothing);
  });

  testWidgets('initial loading is honest while repositories are pending', (
    tester,
  ) async {
    final completer = Completer<List<AppointmentSummary>>();
    final scheduling = _FakeSchedulingRepository(
      appointmentCompleter: completer,
    );
    tester.view.physicalSize = _phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _phoneSize,
        builder:
            (_, __) => MaterialApp(
              home: Home(
                role: MarketplaceHomeRole.patient,
                profileRepository: _FakeProfileRepository(),
                onboardingRepository: _FakeOnboardingRepository(
                  readiness: _readiness(role: MarketplaceHomeRole.patient),
                ),
                schedulingRepository: scheduling,
                onPrimaryAction: () {},
                onAppointments: () {},
                onReadinessAction: (_) {},
                now: _now,
              ),
            ),
      ),
    );
    await tester.pump();
    expect(find.text('Loading your care workspace...'), findsOneWidget);
    completer.complete(const <AppointmentSummary>[]);
    await tester.pumpAndSettle();
  });
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({
    this.patient,
    this.professional,
    this.failPatient = false,
  });

  final PatientProfile? patient;
  final ProfessionalProfile? professional;
  final bool failPatient;

  @override
  Future<PatientProfile?> patientMe() async {
    if (failPatient) throw StateError('profile unavailable');
    return patient ?? const PatientProfile(name: 'Patient');
  }

  @override
  Future<ProfessionalProfile?> professionalMe() async =>
      professional ??
      const ProfessionalProfile(
        displayName: 'Professional',
        category: 'Healthcare professional',
        verificationStatus: 'VERIFIED',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOnboardingRepository implements OnboardingRepository {
  const _FakeOnboardingRepository({required this.readiness});

  final AccountReadiness readiness;

  @override
  Future<AccountReadiness> accountReadiness() async => readiness;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSchedulingRepository implements SchedulingRepository {
  _FakeSchedulingRepository({
    this.appointments = const <AppointmentSummary>[],
    this.availability = const <AvailabilityWindow>[],
    this.failAppointmentsOnce = false,
    this.failAppointmentsAlways = false,
    this.appointmentCompleter,
    this.retryCompleter,
  });

  final List<AppointmentSummary> appointments;
  final List<AvailabilityWindow> availability;
  final bool failAppointmentsOnce;
  final bool failAppointmentsAlways;
  final Completer<List<AppointmentSummary>>? appointmentCompleter;
  final Completer<List<AppointmentSummary>>? retryCompleter;
  int appointmentCalls = 0;

  @override
  Future<List<AppointmentSummary>> ownAppointments() async {
    appointmentCalls += 1;
    if (failAppointmentsAlways) {
      throw StateError('temporary failure');
    }
    if (failAppointmentsOnce && appointmentCalls == 1) {
      throw StateError('temporary failure');
    }
    if (appointmentCalls > 1 && retryCompleter != null) {
      return retryCompleter!.future;
    }
    return appointmentCompleter?.future ?? appointments;
  }

  @override
  Future<List<AvailabilityWindow>> ownAvailability() async => availability;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AccountReadiness _readiness({
  required MarketplaceHomeRole role,
  String nextAction = 'DASHBOARD',
  String patientStatus = 'COMPLETE',
  String verificationStatus = 'VERIFIED',
  List<String> requiredProfileFields = const <String>[],
}) {
  final professional = role == MarketplaceHomeRole.professional;
  return AccountReadiness(
    account: ReadinessAccount(
      role: professional ? 'PROFESSIONAL' : 'PATIENT',
      status: 'ACTIVE',
      emailVerified: true,
    ),
    patient:
        professional
            ? null
            : PatientReadiness(
              profileStatus: patientStatus,
              requiredFields:
                  patientStatus == 'COMPLETE'
                      ? const <String>[]
                      : const <String>['name'],
            ),
    professional:
        professional
            ? ProfessionalReadiness(
              applicationStatus:
                  requiredProfileFields.isEmpty ? 'APPROVED' : 'DRAFT',
              verificationStatus: verificationStatus,
              requiredProfileFields: requiredProfileFields,
              requiredEvidence: const <String>[],
              missingEvidence: const <String>[],
            )
            : null,
    nextAction: nextAction,
    requiredActions: const <String>[],
  );
}

AppointmentSummary _appointment({
  required String id,
  required AppointmentStatus status,
  required DateTime start,
}) {
  return AppointmentSummary(
    id: id,
    patientProfileId: 'patient-1',
    professionalProfileId: 'professional-1',
    requestedStartAt: start,
    durationMinutes: 30,
    status: status,
  );
}
