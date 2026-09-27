import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/requestable_times.dart';
import 'package:app_t/features/Home/presentation/pages/appointment_experience_shell.dart';
import 'package:app_t/features/Home/presentation/state/appointment_experience_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('patient list is truthful and opens exact canonical detail', (
    tester,
  ) async {
    final repository = _SchedulingFake(
      appointments: <AppointmentSummary>[
        _appointment(id: 'appointment-b', status: AppointmentStatus.accepted),
        _appointment(
          id: 'appointment-a',
          status: AppointmentStatus.requested,
          start: DateTime.utc(2026, 7, 27, 9),
        ),
      ],
    );
    await _pumpList(tester, repository: repository, role: 'PATIENT');

    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('REQUEST SENT'), findsOneWidget);
    expect(find.text('Appointment with Professional'), findsNWidgets(2));
    expect(find.textContaining('confirmed'), findsNothing);
    expect(find.textContaining('payment'), findsNothing);

    await tester.tap(find.byKey(const Key('appointment-appointment-a')));
    await tester.pumpAndSettle();

    expect(find.text('Appointment details'), findsOneWidget);
    expect(find.text('REQUEST SENT'), findsOneWidget);
    expect(repository.listCalls, 2);
  });

  testWidgets('professional request is action needed and can be accepted', (
    tester,
  ) async {
    final repository = _SchedulingFake(
      appointments: <AppointmentSummary>[
        _appointment(status: AppointmentStatus.requested),
      ],
    );
    await _pumpDetail(tester, repository: repository, role: 'PROFESSIONAL');

    expect(find.byKey(const Key('appointment-action-accept')), findsOneWidget);
    expect(find.byKey(const Key('appointment-action-decline')), findsOneWidget);
    expect(find.text('Join consultation'), findsNothing);
    expect(find.text('Payment'), findsNothing);

    await tester.tap(find.byKey(const Key('appointment-action-accept')));
    await tester.pumpAndSettle();

    expect(repository.acceptCalls, 1);
    expect(find.text('ACCEPTED'), findsOneWidget);
    expect(find.text('Appointment accepted.'), findsOneWidget);
  });

  testWidgets('unknown roles fail closed without loading appointments', (
    tester,
  ) async {
    final repository = _SchedulingFake();
    await _pumpList(tester, repository: repository, role: 'ADMIN');

    expect(find.text('Appointments unavailable'), findsOneWidget);
    expect(repository.listCalls, 0);
  });

  testWidgets('missing detail ID fails closed without seeded appointment', (
    tester,
  ) async {
    final repository = _SchedulingFake();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder:
            (_, __) => MaterialApp(
              home: AppointmentDetailShellPage(
                appointmentId: null,
                schedulingRepository: repository,
                sessionStore: _sessionStore('PATIENT'),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Appointment unavailable'), findsOneWidget);
    expect(repository.listCalls, 0);
    expect(find.textContaining('Lagbaja'), findsNothing);
  });

  test('refresh preserves valid data and serializes repeated loads', () async {
    final completer = Completer<List<AppointmentSummary>>();
    final repository = _SchedulingFake(
      appointments: <AppointmentSummary>[_appointment()],
    );
    final controller = AppointmentListController(
      schedulingRepository: repository,
      sessionStore: _sessionStore('PATIENT'),
    );
    await controller.load();
    repository.nextList = completer.future;

    final first = controller.load();
    final second = controller.load();
    await Future<void>.delayed(Duration.zero);
    expect(repository.listCalls, 2);
    completer.completeError(
      const AuthFailure(
        type: AuthFailureType.network,
        message: 'raw network detail',
      ),
    );
    await Future.wait(<Future<void>>[first, second]);

    expect(controller.appointments, hasLength(1));
    expect(controller.errorMessage, contains('uncertain'));
    expect(controller.errorMessage, isNot(contains('raw network detail')));
    controller.dispose();
  });

  test('detail clears stale appointment when refresh returns 404', () async {
    final repository = _SchedulingFake(
      appointments: <AppointmentSummary>[_appointment()],
    );
    final controller = AppointmentDetailController(
      appointmentId: 'appointment-1',
      schedulingRepository: repository,
      sessionStore: _sessionStore('PATIENT'),
      now: () => DateTime.utc(2026, 7, 26, 12),
    );
    await controller.load();
    final completer = Completer<List<AppointmentSummary>>();
    repository.nextList = completer.future;
    final refresh = controller.load();
    completer.completeError(
      const AuthFailure(
        type: AuthFailureType.validation,
        message: 'private backend detail',
        statusCode: 404,
      ),
    );

    await refresh;

    expect(controller.appointment, isNull);
    expect(controller.loadError, 'This appointment is no longer available.');
    expect(controller.loadError, isNot(contains('private backend detail')));
    controller.dispose();
  });

  testWidgets('patient cannot see professional-only lifecycle actions', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      repository: _SchedulingFake(
        appointments: <AppointmentSummary>[
          _appointment(status: AppointmentStatus.requested),
        ],
      ),
      role: 'PATIENT',
    );

    expect(find.byKey(const Key('appointment-action-accept')), findsNothing);
    expect(find.byKey(const Key('appointment-action-decline')), findsNothing);
    expect(find.byKey(const Key('appointment-action-cancel')), findsOneWidget);
  });

  testWidgets('reschedule uses only backend-returned time at fixed duration', (
    tester,
  ) async {
    final selected = DateTime.utc(2026, 7, 29, 9);
    final repository = _SchedulingFake(
      appointments: <AppointmentSummary>[
        _appointment(status: AppointmentStatus.accepted),
      ],
      requestableTimes: <RequestableTime>[
        RequestableTime(
          startAt: selected,
          endAt: selected.add(const Duration(minutes: 30)),
        ),
      ],
    );
    await _pumpDetail(tester, repository: repository, role: 'PATIENT');

    await tester.tap(find.text('Choose a new time'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pump();
    await tester.tap(find.text('Request selected time'));
    await tester.pumpAndSettle();

    expect(repository.rescheduleCalls, 1);
    expect(repository.rescheduledStartAt, selected);
    expect(repository.rescheduledDuration, 30);
    expect(find.text('REQUEST SENT'), findsOneWidget);
  });

  testWidgets('409 conflict refreshes authority without false accepted state', (
    tester,
  ) async {
    final repository = _SchedulingFake(
      appointments: <AppointmentSummary>[
        _appointment(status: AppointmentStatus.requested),
      ],
      acceptFailure: const AuthFailure(
        type: AuthFailureType.validation,
        message: 'raw accepted conflict',
        statusCode: 409,
      ),
    );
    await _pumpDetail(tester, repository: repository, role: 'PROFESSIONAL');

    await tester.tap(find.byKey(const Key('appointment-action-accept')));
    await tester.pumpAndSettle();

    expect(repository.acceptCalls, 1);
    expect(repository.listCalls, 2);
    expect(find.text('REQUEST SENT'), findsOneWidget);
    expect(
      find.text('This appointment changed. Refresh and review it again.'),
      findsOneWidget,
    );
    expect(find.text('raw accepted conflict'), findsNothing);
  });
}

Future<void> _pumpList(
  WidgetTester tester, {
  required _SchedulingFake repository,
  required String role,
}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(430, 932),
      builder:
          (_, __) => MaterialApp(
            home: AppointmentsShellPage(
              schedulingRepository: repository,
              sessionStore: _sessionStore(role),
              now: DateTime.utc(2026, 7, 26, 12),
            ),
            onGenerateRoute: (settings) {
              if (settings.name == RouteName.appointmentDetail) {
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder:
                      (_) => AppointmentDetailShellPage(
                        appointmentId: settings.arguments as String?,
                        schedulingRepository: repository,
                        sessionStore: _sessionStore(role),
                        now: DateTime.utc(2026, 7, 26, 12),
                      ),
                );
              }
              return null;
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  required _SchedulingFake repository,
  required String role,
}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(430, 932),
      builder:
          (_, __) => MaterialApp(
            home: AppointmentDetailShellPage(
              appointmentId: 'appointment-1',
              schedulingRepository: repository,
              sessionStore: _sessionStore(role),
              now: DateTime.utc(2026, 7, 26, 12),
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

InMemorySessionStore _sessionStore(String role) {
  return InMemorySessionStore()..save(
    AuthSessionModel.fromJson(<String, dynamic>{
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'user': <String, dynamic>{
        'id': 'user-1',
        'email': 'person@example.com',
        'role': role,
        'status': 'ACTIVE',
        'emailVerified': true,
      },
    }),
  );
}

AppointmentSummary _appointment({
  String id = 'appointment-1',
  AppointmentStatus status = AppointmentStatus.requested,
  DateTime? start,
}) {
  return AppointmentSummary(
    id: id,
    patientProfileId: 'patient-1',
    professionalProfileId: 'professional-1',
    requestedStartAt: start ?? DateTime.utc(2026, 7, 27, 10),
    durationMinutes: 30,
    status: status,
    createdAt: DateTime.utc(2026, 7, 25, 10),
  );
}

class _SchedulingFake implements SchedulingRepository {
  _SchedulingFake({
    List<AppointmentSummary>? appointments,
    this.requestableTimes = const <RequestableTime>[],
    this.acceptFailure,
  }) : appointments = appointments ?? <AppointmentSummary>[];

  List<AppointmentSummary> appointments;
  final List<RequestableTime> requestableTimes;
  final Object? acceptFailure;
  Future<List<AppointmentSummary>>? nextList;
  int listCalls = 0;
  int acceptCalls = 0;
  int rescheduleCalls = 0;
  DateTime? rescheduledStartAt;
  int? rescheduledDuration;

  @override
  Future<List<AppointmentSummary>> ownAppointments() {
    listCalls++;
    final next = nextList;
    nextList = null;
    return next ?? Future<List<AppointmentSummary>>.value(appointments);
  }

  @override
  Future<AppointmentSummary> acceptAppointment({
    required String appointmentId,
  }) async {
    acceptCalls++;
    final failure = acceptFailure;
    if (failure != null) {
      throw failure;
    }
    _setStatus(appointmentId, AppointmentStatus.accepted);
    return appointments.firstWhere((item) => item.id == appointmentId);
  }

  void _setStatus(String id, AppointmentStatus status) {
    appointments =
        appointments
            .map(
              (item) =>
                  item.id == id
                      ? AppointmentSummary(
                        id: item.id,
                        patientProfileId: item.patientProfileId,
                        professionalProfileId: item.professionalProfileId,
                        requestedStartAt: item.requestedStartAt,
                        durationMinutes: item.durationMinutes,
                        status: status,
                        createdAt: item.createdAt,
                        updatedAt: DateTime.utc(2026, 7, 26, 12),
                      )
                      : item,
            )
            .toList();
  }

  @override
  Future<AppointmentSummary> cancelAppointment({
    required String appointmentId,
  }) async {
    _setStatus(appointmentId, AppointmentStatus.cancelled);
    return appointments.firstWhere((item) => item.id == appointmentId);
  }

  @override
  Future<AppointmentSummary> completeAppointment({
    required String appointmentId,
  }) async {
    _setStatus(appointmentId, AppointmentStatus.completed);
    return appointments.firstWhere((item) => item.id == appointmentId);
  }

  @override
  Future<AppointmentSummary> declineAppointment({
    required String appointmentId,
  }) async {
    _setStatus(appointmentId, AppointmentStatus.declined);
    return appointments.firstWhere((item) => item.id == appointmentId);
  }

  @override
  Future<List<AvailabilityWindow>> ownAvailability() async => const [];

  @override
  Future<List<AvailabilityWindow>> publicAvailability({
    required String professionalProfileId,
  }) async => const [];

  @override
  Future<RequestableTimes> publicRequestableTimes({
    required String professionalProfileId,
    DateTime? rangeStartAt,
    DateTime? rangeEndAt,
  }) async {
    return RequestableTimes(
      professionalProfileId: professionalProfileId,
      timezone: 'Africa/Lagos',
      durationMinutes: 30,
      cadenceMinutes: 30,
      leadTimeMinutes: 120,
      bookingHorizonDays: 60,
      times: requestableTimes,
    );
  }

  @override
  Future<List<AvailabilityWindow>> replaceOwnAvailability({
    required List<AvailabilityWindowDraft> windows,
  }) async => const [];

  @override
  Future<AppointmentSummary> requestAppointment({
    required String professionalProfileId,
    required DateTime requestedStartAt,
    required int durationMinutes,
    required String idempotencyKey,
    ConsultationMode consultationMode = ConsultationMode.video,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppointmentSummary> rescheduleAppointment({
    required String appointmentId,
    required DateTime requestedStartAt,
    required int durationMinutes,
  }) async {
    rescheduleCalls++;
    rescheduledStartAt = requestedStartAt;
    rescheduledDuration = durationMinutes;
    appointments =
        appointments
            .map(
              (item) =>
                  item.id == appointmentId
                      ? AppointmentSummary(
                        id: item.id,
                        patientProfileId: item.patientProfileId,
                        professionalProfileId: item.professionalProfileId,
                        requestedStartAt: requestedStartAt,
                        durationMinutes: durationMinutes,
                        status: AppointmentStatus.requested,
                        createdAt: item.createdAt,
                      )
                      : item,
            )
            .toList();
    return appointments.firstWhere((item) => item.id == appointmentId);
  }
}
