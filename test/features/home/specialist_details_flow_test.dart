import 'dart:ui' show SemanticsAction, Tristate;

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/data/storage/booking_intent_store.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/consultation_price.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/domain/entities/requestable_times.dart';
import 'package:app_t/features/Home/presentation/pages/specialist_details_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpDetails(
  WidgetTester tester, {
  String? professionalId = 'pro-1',
  _FakeProfileRepository? profileRepository,
  _FakeSchedulingRepository? schedulingRepository,
  SessionStore? sessionStore,
  BookingIntentStore? bookingIntentStore,
  OnboardingRepository? onboardingRepository,
  Size screenSize = _phoneSize,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = screenSize;
  addTearDown(tester.view.reset);

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
            routes: <String, WidgetBuilder>{
              RouteName.search:
                  (_) => const Scaffold(body: Text('canonical-find-care')),
              RouteName.signInEmail:
                  (_) => const Scaffold(body: Text('booking-sign-in')),
              RouteName.patientOnboardingSetup:
                  (_) => const Scaffold(body: Text('patient-setup')),
              RouteName.dashboard:
                  (_) => const Scaffold(body: Text('appointments-dashboard')),
            },
            home: SpecialistDetailsShellPage(
              specialistId: professionalId,
              profileRepository: profileRepository ?? _FakeProfileRepository(),
              schedulingRepository:
                  schedulingRepository ?? _FakeSchedulingRepository(),
              sessionStore: sessionStore ?? _patientSessionStore(),
              bookingIntentStore:
                  bookingIntentStore ?? InMemoryBookingIntentStore(),
              onboardingRepository:
                  onboardingRepository ?? _FakeOnboardingRepository(),
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('loads canonical detail by exact ID without directory fallback', (
    tester,
  ) async {
    final profiles = _FakeProfileRepository();
    await _pumpDetails(tester, profileRepository: profiles);

    expect(profiles.detailIds, <String>['pro-1']);
    expect(profiles.directoryCalls, 0);
    expect(find.text('Dr Ada Care'), findsOneWidget);
    expect(find.text('Doctor · Cardiology'), findsOneWidget);
    expect(find.text('Evidence-based heart care.'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.textContaining('No public profile summary'), findsNothing);
    expect(find.textContaining('Meeting Location'), findsNothing);
    expect(find.textContaining('rating'), findsNothing);
    expect(find.textContaining('reviews'), findsNothing);
    expect(find.textContaining('experience'), findsNothing);
  });

  testWidgets('missing ID fails closed without seeded professional data', (
    tester,
  ) async {
    await _pumpDetails(tester, professionalId: null);

    expect(find.text('Professional unavailable'), findsOneWidget);
    expect(find.text('Dr. Uzo Blessing'), findsNothing);
    expect(find.text('10:00am'), findsNothing);
  });

  testWidgets('unknown professional fails closed and offers Find Care', (
    tester,
  ) async {
    await _pumpDetails(
      tester,
      professionalId: 'unknown',
      profileRepository: _FakeProfileRepository(detail: null),
    );

    expect(find.text('Professional unavailable'), findsOneWidget);
    await tester.tap(find.text('Back to Find Care'));
    await tester.pumpAndSettle();
    expect(find.text('canonical-find-care'), findsOneWidget);
  });

  testWidgets('times failure preserves a successfully loaded profile', (
    tester,
  ) async {
    await _pumpDetails(
      tester,
      schedulingRepository: _FakeSchedulingRepository(
        timesFailure: StateError('private failure'),
      ),
    );

    expect(find.text('Dr Ada Care'), findsOneWidget);
    expect(
      find.text('Could not load appointment times. Please try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('private failure'), findsNothing);
  });

  testWidgets('unpriced professional is visibly non-bookable', (tester) async {
    final scheduling = _FakeSchedulingRepository();
    await _pumpDetails(
      tester,
      schedulingRepository: scheduling,
      profileRepository: _FakeProfileRepository(
        detail: const PublicProfessional(
          id: 'pro-1',
          displayName: 'Dr Ada Care',
          category: 'Doctor',
          verified: true,
        ),
      ),
    );

    expect(find.text('Not available for booking'), findsOneWidget);
    expect(find.text('Request selected time'), findsNothing);
    expect(scheduling.requestableIds, isEmpty);
  });

  testWidgets('renders only backend requestable UTC times at fixed duration', (
    tester,
  ) async {
    final scheduling = _FakeSchedulingRepository();
    await _pumpDetails(tester, schedulingRepository: scheduling);

    expect(scheduling.requestableIds, <String>['pro-1']);
    expect(find.text('Professional timezone: Africa/Lagos'), findsOneWidget);
    expect(
      find.textContaining('9:00 am Africa/Lagos - 30 min'),
      findsOneWidget,
    );
    expect(find.textContaining('Day 2:'), findsNothing);
    expect(find.textContaining('45 min'), findsNothing);
  });

  testWidgets('professional booking flow remains usable at 2x text', (
    tester,
  ) async {
    final scheduling = _FakeSchedulingRepository();
    await _pumpDetails(
      tester,
      schedulingRepository: scheduling,
      screenSize: const Size(320, 568),
      textScaler: const TextScaler.linear(2),
    );

    expect(find.text('Dr Ada Care'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final availableTime = find.textContaining('9:00 am Africa/Lagos');
    await tester.scrollUntilVisible(
      availableTime,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final dateChoice = find.byType(ChoiceChip).first;
    expect(tester.getSize(dateChoice).height, greaterThanOrEqualTo(48));
    expect(find.text('Professional timezone: Africa/Lagos'), findsOneWidget);
    await tester.tap(availableTime);
    await tester.pumpAndSettle();

    final requestButton = find.text('Request selected time');
    await tester.ensureVisible(requestButton);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(requestButton);
    await tester.pumpAndSettle();

    expect(find.text('Request this appointment?'), findsOneWidget);
    expect(
      find.textContaining('not confirmed until the professional accepts it'),
      findsOneWidget,
    );
    expect(find.text('Send request'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();
    expect(find.text('Appointment request sent'), findsOneWidget);
    expect(find.textContaining('It is not confirmed yet.'), findsOneWidget);
    expect(find.text('View appointments'), findsOneWidget);
    expect(scheduling.requestCalls, 1);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('View appointments'));
    await tester.pumpAndSettle();
    expect(find.text('appointments-dashboard'), findsOneWidget);
  });

  testWidgets('readiness failure preserves selection and offers a clear retry', (
    tester,
  ) async {
    final store = InMemoryBookingIntentStore();
    final scheduling = _FakeSchedulingRepository();
    final onboarding = _FakeOnboardingRepository(
      failures: <Object?>[StateError('private backend error'), null],
    );
    await _pumpDetails(
      tester,
      schedulingRepository: scheduling,
      bookingIntentStore: store,
      onboardingRepository: onboarding,
    );

    final time = find.textContaining('9:00 am Africa/Lagos');
    await tester.ensureVisible(time);
    await tester.tap(time);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Request selected time'));
    await tester.tap(find.text('Request selected time'));
    await tester.pumpAndSettle();

    final intentAfterFailure = await store.read();
    expect(
      find.text(
        "We couldn't confirm that your account is ready to request an appointment. Please try again.",
      ),
      findsOneWidget,
    );
    expect(find.text('Retry account check'), findsOneWidget);
    expect(intentAfterFailure, isNotNull);
    expect(onboarding.calls, 1);
    expect(scheduling.requestCalls, 0);

    await tester.scrollUntilVisible(
      find.text('Retry account check'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry account check'));
    await tester.pumpAndSettle();

    expect(onboarding.calls, 2);
    expect(find.text('Request this appointment?'), findsOneWidget);
    expect(
      (await store.read())?.idempotencyKey,
      intentAfterFailure!.idempotencyKey,
    );
    expect(scheduling.requestCalls, 0);
  });

  testWidgets('requestable time exposes radio selection semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpDetails(tester);

    try {
      final timeOption = find.bySemanticsLabel(RegExp('9:00 am Africa/Lagos'));
      final initialData = tester.getSemantics(timeOption).getSemanticsData();
      expect(initialData.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(initialData.flagsCollection.isSelected, Tristate.isFalse);

      await tester.ensureVisible(find.textContaining('9:00 am Africa/Lagos'));
      await tester.tap(find.textContaining('9:00 am Africa/Lagos'));
      await tester.pumpAndSettle();

      final selectedData = tester.getSemantics(timeOption).getSemanticsData();
      expect(selectedData.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(selectedData.flagsCollection.isSelected, Tristate.isTrue);
      expect(selectedData.hasAction(SemanticsAction.tap), isTrue);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('empty bounded range offers later backend times', (tester) async {
    final scheduling = _FakeSchedulingRepository(
      response: const RequestableTimes(
        professionalProfileId: 'pro-1',
        timezone: 'Africa/Lagos',
        durationMinutes: 30,
        cadenceMinutes: 30,
        leadTimeMinutes: 120,
        bookingHorizonDays: 60,
        times: <RequestableTime>[],
      ),
    );

    await _pumpDetails(tester, schedulingRepository: scheduling);

    expect(
      find.text('No appointment times are available in this date range.'),
      findsOneWidget,
    );
    expect(find.text('Load later times'), findsOneWidget);
    await tester.tap(find.text('Load later times'));
    await tester.pump();
    expect(scheduling.requestableIds, <String>['pro-1', 'pro-1']);
  });

  testWidgets('mounts only the selected day from a large times response', (
    tester,
  ) async {
    final firstStart = DateTime.parse('2026-07-25T08:00:00.000Z');
    final scheduling = _FakeSchedulingRepository(
      response: RequestableTimes(
        professionalProfileId: 'pro-1',
        timezone: 'Africa/Lagos',
        durationMinutes: 30,
        cadenceMinutes: 30,
        leadTimeMinutes: 120,
        bookingHorizonDays: 60,
        times: <RequestableTime>[
          for (var day = 0; day < 60; day++)
            RequestableTime(
              startAt: firstStart.add(Duration(days: day)),
              endAt: firstStart.add(Duration(days: day, minutes: 30)),
            ),
        ],
      ),
    );

    await _pumpDetails(tester, schedulingRepository: scheduling);

    expect(find.text('Choose a date'), findsOneWidget);
    expect(
      find.textContaining('9:00 am Africa/Lagos - 30 min'),
      findsOneWidget,
    );
  });

  testWidgets('unauthenticated request saves intent before entering auth', (
    tester,
  ) async {
    final intentStore = InMemoryBookingIntentStore();
    await _pumpDetails(
      tester,
      sessionStore: InMemorySessionStore(),
      bookingIntentStore: intentStore,
    );

    await tester.tap(find.textContaining('9:00 am Africa/Lagos'));
    await tester.pump();
    await tester.drag(find.byType(ListView).first, const Offset(0, -120));
    await tester.pump();
    await tester.tap(find.text('Request selected time'));
    await tester.pumpAndSettle();

    expect(find.text('booking-sign-in'), findsOneWidget);
    final intent = await intentStore.read();
    expect(intent?.professionalProfileId, 'pro-1');
    expect(intent?.durationMinutes, 30);
    expect(intent?.idempotencyKey, hasLength(36));
  });

  testWidgets('professional account cannot submit a patient appointment', (
    tester,
  ) async {
    final scheduling = _FakeSchedulingRepository();
    await _pumpDetails(
      tester,
      schedulingRepository: scheduling,
      sessionStore: _professionalSessionStore(),
    );

    await tester.tap(find.textContaining('9:00 am Africa/Lagos'));
    await tester.pump();
    await tester.drag(find.byType(ListView).first, const Offset(0, -120));
    await tester.pump();
    await tester.tap(find.text('Request selected time'));
    await tester.pumpAndSettle();

    expect(scheduling.requestCalls, 0);
    expect(
      find.textContaining('cannot request patient appointments'),
      findsOneWidget,
    );
    expect(find.textContaining('sign in again'), findsNothing);
  });

  testWidgets('ready patient sends exact ID, UTC time, duration and key', (
    tester,
  ) async {
    final scheduling = _FakeSchedulingRepository();
    await _pumpDetails(tester, schedulingRepository: scheduling);

    await tester.tap(find.textContaining('9:00 am Africa/Lagos'));
    await tester.pump();
    await tester.drag(find.byType(ListView).first, const Offset(0, -120));
    await tester.pump();
    await tester.tap(find.text('Request selected time'));
    await tester.pumpAndSettle();
    expect(find.text('Request this appointment?'), findsOneWidget);

    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();

    expect(scheduling.requestCalls, 1);
    expect(scheduling.requestedProfessionalId, 'pro-1');
    expect(
      scheduling.requestedStartAt,
      DateTime.parse('2026-07-25T08:00:00.000Z'),
    );
    expect(scheduling.requestedDuration, 30);
    expect(scheduling.idempotencyKey, hasLength(36));
    expect(find.text('Appointment request sent'), findsOneWidget);
    expect(find.textContaining('not confirmed yet'), findsOneWidget);
  });

  testWidgets(
    'audio selection preserves the shared price and reaches backend',
    (tester) async {
      final scheduling = _FakeSchedulingRepository();
      await _pumpDetails(tester, schedulingRepository: scheduling);

      await tester.tap(find.text('Audio'));
      await tester.pump();
      expect(find.text('NGN 15,000.00'), findsOneWidget);
      expect(
        find.text('Video and audio use the same consultation fee.'),
        findsOneWidget,
      );
      await tester.tap(find.textContaining('9:00 am Africa/Lagos'));
      await tester.pump();
      await tester.drag(find.byType(ListView).first, const Offset(0, -120));
      await tester.pump();
      await tester.tap(find.text('Request selected time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send request'));
      await tester.pumpAndSettle();

      expect(scheduling.requestedConsultationMode, ConsultationMode.audio);
    },
  );
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({
    this.detail = const PublicProfessional(
      id: 'pro-1',
      displayName: 'Dr Ada Care',
      category: 'Doctor',
      specialty: 'Cardiology',
      bio: 'Evidence-based heart care.',
      verified: true,
      bookable: true,
      consultationPrice: ConsultationPrice(
        amountMinor: 1500000,
        currency: 'NGN',
      ),
    ),
  });

  final PublicProfessional? detail;
  final List<String> detailIds = <String>[];
  int directoryCalls = 0;

  @override
  Future<PublicProfessional?> publicProfessionalById({
    required String professionalProfileId,
  }) async {
    detailIds.add(professionalProfileId);
    return detail;
  }

  @override
  Future<List<PublicProfessional>> publicProfessionals() async {
    directoryCalls += 1;
    throw StateError('Directory must not be loaded by detail.');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSchedulingRepository implements SchedulingRepository {
  _FakeSchedulingRepository({this.timesFailure, RequestableTimes? response})
    : _response = response;

  final Object? timesFailure;
  final RequestableTimes? _response;
  final List<String> requestableIds = <String>[];
  int requestCalls = 0;
  String? requestedProfessionalId;
  DateTime? requestedStartAt;
  int? requestedDuration;
  String? idempotencyKey;
  ConsultationMode? requestedConsultationMode;

  RequestableTimes get response =>
      _response ??
      RequestableTimes(
        professionalProfileId: 'pro-1',
        timezone: 'Africa/Lagos',
        durationMinutes: 30,
        cadenceMinutes: 30,
        leadTimeMinutes: 120,
        bookingHorizonDays: 60,
        times: <RequestableTime>[
          RequestableTime(
            startAt: DateTime.parse('2026-07-25T08:00:00.000Z'),
            endAt: DateTime.parse('2026-07-25T08:30:00.000Z'),
          ),
        ],
      );

  @override
  Future<RequestableTimes> publicRequestableTimes({
    required String professionalProfileId,
    DateTime? rangeStartAt,
    DateTime? rangeEndAt,
  }) async {
    requestableIds.add(professionalProfileId);
    if (timesFailure != null) {
      throw timesFailure!;
    }
    return response;
  }

  @override
  Future<AppointmentSummary> requestAppointment({
    required String professionalProfileId,
    required DateTime requestedStartAt,
    required int durationMinutes,
    required String idempotencyKey,
    ConsultationMode consultationMode = ConsultationMode.video,
  }) async {
    requestCalls += 1;
    requestedProfessionalId = professionalProfileId;
    this.requestedStartAt = requestedStartAt;
    requestedDuration = durationMinutes;
    this.idempotencyKey = idempotencyKey;
    requestedConsultationMode = consultationMode;
    return AppointmentSummary(
      id: 'appointment-1',
      patientProfileId: 'patient-1',
      professionalProfileId: professionalProfileId,
      requestedStartAt: requestedStartAt,
      durationMinutes: durationMinutes,
      status: AppointmentStatus.requested,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({this.failures = const <Object?>[]});

  final List<Object?> failures;
  int calls = 0;

  @override
  Future<AccountReadiness> accountReadiness() async {
    final call = calls++;
    if (call < failures.length && failures[call] != null) {
      throw failures[call]!;
    }
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
      nextAction: 'PATIENT_BOOKING_GATE',
      requiredActions: <String>[],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SessionStore _patientSessionStore() {
  return InMemorySessionStore()..save(_session(role: 'PATIENT'));
}

SessionStore _professionalSessionStore() {
  return InMemorySessionStore()..save(_session(role: 'PROFESSIONAL'));
}

AuthSessionModel _session({required String role}) {
  return AuthSessionModel.fromJson(<String, dynamic>{
    'accessToken': 'access-token',
    'refreshToken': 'refresh-token',
    'expiresIn': 900,
    'user': <String, dynamic>{
      'id': 'user-1',
      'email': 'care@example.com',
      'role': role,
      'status': 'ACTIVE',
      'emailVerified': true,
    },
  });
}
