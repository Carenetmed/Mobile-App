import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/requestable_times.dart';
import 'package:app_t/features/Home/presentation/pages/appointments_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpAppointments(
  WidgetTester tester, {
  SchedulingRepository? schedulingRepository,
  SessionStore? sessionStore,
  String role = 'PATIENT',
  DateTime? now,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: AppointmentsShellPage(
              schedulingRepository:
                  schedulingRepository ?? _FakeSchedulingRepository(),
              sessionStore: sessionStore ?? _sessionStore(role: role),
              now: now,
            ),
            routes: {
              RouteName.bookAppointment:
                  (_) => const BookAppointmentShellPage(),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpPreservedBookingShell(WidgetTester tester) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    const ScreenUtilInit(
      designSize: _phoneSize,
      child: MaterialApp(home: BookAppointmentShellPage()),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeSchedulingRepository implements SchedulingRepository {
  _FakeSchedulingRepository({
    this.appointments = const <AppointmentSummary>[],
    this.failure,
    this.cancelFailure,
    this.acceptFailure,
    this.completeFailure,
    this.rescheduleFailure,
    this.publicAvailabilityFailure,
    this.publicWindows = const <AvailabilityWindow>[],
  });

  final List<AppointmentSummary> appointments;
  final List<AvailabilityWindow> publicWindows;
  final Object? failure;
  final Object? cancelFailure;
  final Object? acceptFailure;
  final Object? completeFailure;
  final Object? rescheduleFailure;
  final Object? publicAvailabilityFailure;
  final List<String> cancelledAppointmentIds = <String>[];
  final List<String> acceptedAppointmentIds = <String>[];
  final List<String> declinedAppointmentIds = <String>[];
  final List<String> completedAppointmentIds = <String>[];
  final List<String> publicAvailabilityProfessionalIds = <String>[];
  final List<String> rescheduledAppointmentIds = <String>[];
  DateTime? requestedRescheduleStartAt;
  int? requestedRescheduleDurationMinutes;

  @override
  Future<List<AppointmentSummary>> ownAppointments() async {
    final error = failure;
    if (error != null) {
      throw error;
    }
    return appointments;
  }

  @override
  Future<AppointmentSummary> acceptAppointment({
    required String appointmentId,
  }) async {
    final error = acceptFailure;
    if (error != null) {
      throw error;
    }
    acceptedAppointmentIds.add(appointmentId);
    return _updatedAppointment(
      appointmentId: appointmentId,
      status: AppointmentStatus.accepted,
    );
  }

  @override
  Future<AppointmentSummary> cancelAppointment({
    required String appointmentId,
  }) async {
    final error = cancelFailure;
    if (error != null) {
      throw error;
    }
    cancelledAppointmentIds.add(appointmentId);
    return _updatedAppointment(
      appointmentId: appointmentId,
      status: AppointmentStatus.cancelled,
    );
  }

  @override
  Future<AppointmentSummary> completeAppointment({
    required String appointmentId,
  }) async {
    final error = completeFailure;
    if (error != null) {
      throw error;
    }
    completedAppointmentIds.add(appointmentId);
    return _updatedAppointment(
      appointmentId: appointmentId,
      status: AppointmentStatus.completed,
    );
  }

  @override
  Future<AppointmentSummary> declineAppointment({
    required String appointmentId,
  }) async {
    declinedAppointmentIds.add(appointmentId);
    return _updatedAppointment(
      appointmentId: appointmentId,
      status: AppointmentStatus.declined,
    );
  }

  @override
  Future<List<AvailabilityWindow>> ownAvailability() {
    throw UnimplementedError();
  }

  @override
  Future<List<AvailabilityWindow>> publicAvailability({
    required String professionalProfileId,
  }) async {
    final error = publicAvailabilityFailure;
    if (error != null) {
      throw error;
    }
    publicAvailabilityProfessionalIds.add(professionalProfileId);
    return publicWindows;
  }

  @override
  Future<RequestableTimes> publicRequestableTimes({
    required String professionalProfileId,
    DateTime? rangeStartAt,
    DateTime? rangeEndAt,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<AvailabilityWindow>> replaceOwnAvailability({
    required List<AvailabilityWindowDraft> windows,
  }) {
    throw UnimplementedError();
  }

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
    final error = rescheduleFailure;
    if (error != null) {
      throw error;
    }
    rescheduledAppointmentIds.add(appointmentId);
    requestedRescheduleStartAt = requestedStartAt;
    requestedRescheduleDurationMinutes = durationMinutes;
    return _updatedAppointment(
      appointmentId: appointmentId,
      status: AppointmentStatus.requested,
      requestedStartAt: requestedStartAt,
      durationMinutes: durationMinutes,
    );
  }

  AppointmentSummary _updatedAppointment({
    required String appointmentId,
    required AppointmentStatus status,
    DateTime? requestedStartAt,
    int? durationMinutes,
  }) {
    final appointment = appointments.firstWhere(
      (item) => item.id == appointmentId,
    );
    return AppointmentSummary(
      id: appointment.id,
      patientProfileId: appointment.patientProfileId,
      professionalProfileId: appointment.professionalProfileId,
      requestedStartAt: requestedStartAt ?? appointment.requestedStartAt,
      durationMinutes: durationMinutes ?? appointment.durationMinutes,
      status: status,
      createdAt: appointment.createdAt,
      updatedAt: DateTime(2026, 7, 14, 9),
    );
  }
}

void main() {
  testWidgets(
    'appointments screen shows backend upcoming and recent sections',
    (tester) async {
      await _pumpAppointments(
        tester,
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: _FakeSchedulingRepository(
          appointments: <AppointmentSummary>[
            _appointment(
              professionalProfileId: 'professional-upcoming',
              requestedStartAt: DateTime(2026, 7, 15, 10, 30),
              status: AppointmentStatus.requested,
            ),
            _appointment(
              id: 'appointment-2',
              professionalProfileId: 'professional-completed',
              requestedStartAt: DateTime(2026, 7, 13, 16),
              status: AppointmentStatus.completed,
            ),
          ],
        ),
      );

      expect(
        find.text('Keep your care schedule in one place.'),
        findsOneWidget,
      );
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
      expect(
        find.text('Appointment with professional-upcoming'),
        findsOneWidget,
      );
      expect(find.text('REQUESTED'), findsOneWidget);
      expect(
        find.text('Appointment with professional-completed'),
        findsOneWidget,
      );
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('Private consult with Dr. Lagbaja'), findsNothing);
      expect(find.text('Nutrition follow-up'), findsNothing);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
      expect(find.text('Cancel appointment'), findsOneWidget);
      expect(find.text('Reschedule'), findsOneWidget);
    },
  );

  testWidgets('eligible appointment can be cancelled through backend', (
    tester,
  ) async {
    final schedulingRepository = _FakeSchedulingRepository(
      appointments: <AppointmentSummary>[
        _appointment(
          professionalProfileId: 'professional-upcoming',
          requestedStartAt: DateTime(2026, 7, 15, 10, 30),
          status: AppointmentStatus.requested,
        ),
      ],
    );

    await _pumpAppointments(
      tester,
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: schedulingRepository,
    );

    await tester.tap(find.text('Cancel appointment'));
    await tester.pumpAndSettle();

    expect(schedulingRepository.cancelledAppointmentIds, <String>[
      'appointment-1',
    ]);
    expect(find.text('CANCELLED'), findsOneWidget);
    expect(
      find.text('Cancellation updated. Backend status: CANCELLED.'),
      findsOneWidget,
    );
    expect(find.text('Cancel appointment'), findsNothing);
  });

  testWidgets(
    'accepted upcoming appointment can be cancelled through backend',
    (tester) async {
      final schedulingRepository = _FakeSchedulingRepository(
        appointments: <AppointmentSummary>[
          _appointment(
            professionalProfileId: 'professional-accepted',
            requestedStartAt: DateTime(2026, 7, 15, 10, 30),
            status: AppointmentStatus.accepted,
          ),
        ],
      );

      await _pumpAppointments(
        tester,
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: schedulingRepository,
      );

      expect(find.text('ACCEPTED'), findsOneWidget);

      await tester.tap(find.text('Cancel appointment'));
      await tester.pumpAndSettle();

      expect(schedulingRepository.cancelledAppointmentIds, <String>[
        'appointment-1',
      ]);
      expect(find.text('CANCELLED'), findsOneWidget);
      expect(find.text('ACCEPTED'), findsNothing);
      expect(find.text('Cancel appointment'), findsNothing);
    },
  );

  testWidgets('terminal appointments do not expose cancellation action', (
    tester,
  ) async {
    await _pumpAppointments(
      tester,
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: _FakeSchedulingRepository(
        appointments: <AppointmentSummary>[
          _appointment(
            professionalProfileId: 'professional-cancelled',
            requestedStartAt: DateTime(2026, 7, 15, 10, 30),
            status: AppointmentStatus.cancelled,
          ),
        ],
      ),
    );

    expect(find.text('CANCELLED'), findsOneWidget);
    expect(find.text('Cancel appointment'), findsNothing);
  });

  testWidgets('recent active-status appointments do not expose cancellation', (
    tester,
  ) async {
    await _pumpAppointments(
      tester,
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: _FakeSchedulingRepository(
        appointments: <AppointmentSummary>[
          _appointment(
            professionalProfileId: 'professional-past',
            requestedStartAt: DateTime(2026, 7, 13, 10, 30),
            status: AppointmentStatus.accepted,
          ),
        ],
      ),
    );

    expect(find.text('ACCEPTED'), findsOneWidget);
    expect(find.text('Cancel appointment'), findsNothing);
  });

  testWidgets('cancellation failure shows safe error without status update', (
    tester,
  ) async {
    await _pumpAppointments(
      tester,
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: _FakeSchedulingRepository(
        appointments: <AppointmentSummary>[
          _appointment(
            professionalProfileId: 'professional-upcoming',
            requestedStartAt: DateTime(2026, 7, 15, 10, 30),
            status: AppointmentStatus.requested,
          ),
        ],
        cancelFailure: const AuthFailure(
          type: AuthFailureType.server,
          message: 'raw cancel failure',
        ),
      ),
    );

    await tester.tap(find.text('Cancel appointment'));
    await tester.pumpAndSettle();

    expect(
      find.text('Service is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('raw cancel failure'), findsNothing);
    expect(find.text('REQUESTED'), findsOneWidget);
  });

  testWidgets(
    'patient can reschedule upcoming accepted appointment through backend',
    (tester) async {
      final schedulingRepository = _FakeSchedulingRepository(
        appointments: <AppointmentSummary>[
          _appointment(
            professionalProfileId: 'professional-accepted',
            requestedStartAt: DateTime(2026, 7, 15, 10, 30),
            status: AppointmentStatus.accepted,
          ),
        ],
        publicWindows: <AvailabilityWindow>[
          _availabilityWindow(
            weekday: DateTime.tuesday,
            startMinute: 9 * 60,
            endMinute: 10 * 60,
          ),
        ],
      );

      await _pumpAppointments(
        tester,
        role: 'PATIENT',
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: schedulingRepository,
      );

      expect(find.text('Reschedule'), findsOneWidget);

      await tester.tap(find.text('Reschedule'));
      await tester.pumpAndSettle();

      expect(schedulingRepository.publicAvailabilityProfessionalIds, <String>[
        'professional-accepted',
      ]);
      expect(find.text('Choose a backend availability time'), findsOneWidget);
      expect(find.text('07/14 09:00-09:30 (30 min)'), findsOneWidget);

      await tester.tap(find.text('Confirm reschedule'));
      await tester.pumpAndSettle();

      expect(schedulingRepository.rescheduledAppointmentIds, <String>[
        'appointment-1',
      ]);
      expect(
        schedulingRepository.requestedRescheduleStartAt,
        DateTime(2026, 7, 14, 9),
      );
      expect(schedulingRepository.requestedRescheduleDurationMinutes, 30);
      expect(find.text('REQUESTED'), findsOneWidget);
      expect(find.text('ACCEPTED'), findsNothing);
      expect(
        find.text('Appointment rescheduled. Backend status: REQUESTED.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('professional can reschedule assigned requested appointment', (
    tester,
  ) async {
    final schedulingRepository = _FakeSchedulingRepository(
      appointments: <AppointmentSummary>[
        _appointment(
          professionalProfileId: 'professional-upcoming',
          requestedStartAt: DateTime(2026, 7, 15, 10, 30),
          status: AppointmentStatus.requested,
        ),
      ],
      publicWindows: <AvailabilityWindow>[
        _availabilityWindow(
          weekday: DateTime.tuesday,
          startMinute: 9 * 60,
          endMinute: 10 * 60,
        ),
      ],
    );

    await _pumpAppointments(
      tester,
      role: 'PROFESSIONAL',
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: schedulingRepository,
    );

    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
    expect(find.text('Reschedule'), findsOneWidget);
    expect(find.text('Cancel appointment'), findsNothing);

    await tester.tap(find.text('Reschedule'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm reschedule'));
    await tester.pumpAndSettle();

    expect(schedulingRepository.rescheduledAppointmentIds, <String>[
      'appointment-1',
    ]);
    expect(
      find.text('Appointment rescheduled. Backend status: REQUESTED.'),
      findsOneWidget,
    );
  });

  testWidgets('reschedule is hidden for recent and terminal appointments', (
    tester,
  ) async {
    await _pumpAppointments(
      tester,
      role: 'PATIENT',
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: _FakeSchedulingRepository(
        appointments: <AppointmentSummary>[
          _appointment(
            professionalProfileId: 'professional-past',
            requestedStartAt: DateTime(2026, 7, 13, 10, 30),
            status: AppointmentStatus.accepted,
          ),
          _appointment(
            id: 'appointment-2',
            professionalProfileId: 'professional-cancelled',
            requestedStartAt: DateTime(2026, 7, 15, 10, 30),
            status: AppointmentStatus.cancelled,
          ),
          _appointment(
            id: 'appointment-3',
            professionalProfileId: 'professional-declined',
            requestedStartAt: DateTime(2026, 7, 15, 11, 30),
            status: AppointmentStatus.declined,
          ),
          _appointment(
            id: 'appointment-4',
            professionalProfileId: 'professional-completed',
            requestedStartAt: DateTime(2026, 7, 15, 12, 30),
            status: AppointmentStatus.completed,
          ),
        ],
      ),
    );

    expect(find.text('ACCEPTED'), findsOneWidget);
    expect(find.text('CANCELLED'), findsOneWidget);
    expect(find.text('DECLINED'), findsOneWidget);
    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('Reschedule'), findsNothing);
  });

  testWidgets('empty generated reschedule options do not submit a request', (
    tester,
  ) async {
    final schedulingRepository = _FakeSchedulingRepository(
      appointments: <AppointmentSummary>[
        _appointment(
          professionalProfileId: 'professional-upcoming',
          requestedStartAt: DateTime(2026, 7, 15, 10, 30),
          status: AppointmentStatus.requested,
        ),
      ],
      publicWindows: const <AvailabilityWindow>[],
    );

    await _pumpAppointments(
      tester,
      role: 'PATIENT',
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: schedulingRepository,
    );

    await tester.tap(find.text('Reschedule'));
    await tester.pumpAndSettle();

    expect(schedulingRepository.publicAvailabilityProfessionalIds, <String>[
      'professional-upcoming',
    ]);
    expect(
      find.text('No backend availability is available for reschedule.'),
      findsOneWidget,
    );
    expect(
      find.text('No generated reschedule times are available.'),
      findsOneWidget,
    );
    expect(find.text('Confirm reschedule'), findsNothing);
    expect(schedulingRepository.rescheduledAppointmentIds, isEmpty);
  });

  testWidgets(
    'reschedule availability failure shows safe error without raw backend text',
    (tester) async {
      await _pumpAppointments(
        tester,
        role: 'PATIENT',
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: _FakeSchedulingRepository(
          appointments: <AppointmentSummary>[
            _appointment(
              professionalProfileId: 'professional-upcoming',
              requestedStartAt: DateTime(2026, 7, 15, 10, 30),
              status: AppointmentStatus.requested,
            ),
          ],
          publicAvailabilityFailure: const AuthFailure(
            type: AuthFailureType.server,
            message: 'raw availability failure',
          ),
        ),
      );

      await tester.tap(find.text('Reschedule'));
      await tester.pumpAndSettle();

      expect(
        find.text('Service is unavailable. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('raw availability failure'), findsNothing);
      expect(find.text('Confirm reschedule'), findsNothing);
    },
  );

  testWidgets('reschedule failure shows safe error without status update', (
    tester,
  ) async {
    await _pumpAppointments(
      tester,
      role: 'PATIENT',
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: _FakeSchedulingRepository(
        appointments: <AppointmentSummary>[
          _appointment(
            professionalProfileId: 'professional-accepted',
            requestedStartAt: DateTime(2026, 7, 15, 10, 30),
            status: AppointmentStatus.accepted,
          ),
        ],
        publicWindows: <AvailabilityWindow>[
          _availabilityWindow(
            weekday: DateTime.tuesday,
            startMinute: 9 * 60,
            endMinute: 10 * 60,
          ),
        ],
        rescheduleFailure: const AuthFailure(
          type: AuthFailureType.validation,
          message: 'raw reschedule conflict',
        ),
      ),
    );

    await tester.tap(find.text('Reschedule'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm reschedule'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please choose an available time and try again.'),
      findsOneWidget,
    );
    expect(find.text('raw reschedule conflict'), findsNothing);
    expect(find.text('ACCEPTED'), findsOneWidget);
  });

  testWidgets('professional can accept requested appointment through backend', (
    tester,
  ) async {
    final schedulingRepository = _FakeSchedulingRepository(
      appointments: <AppointmentSummary>[
        _appointment(
          professionalProfileId: 'professional-upcoming',
          requestedStartAt: DateTime(2026, 7, 15, 10, 30),
          status: AppointmentStatus.requested,
        ),
      ],
    );

    await _pumpAppointments(
      tester,
      role: 'PROFESSIONAL',
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: schedulingRepository,
    );

    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
    expect(find.text('Cancel appointment'), findsNothing);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(schedulingRepository.acceptedAppointmentIds, <String>[
      'appointment-1',
    ]);
    expect(find.text('ACCEPTED'), findsOneWidget);
    expect(
      find.text('Appointment updated. Backend status: ACCEPTED.'),
      findsOneWidget,
    );
    expect(find.text('Accept'), findsNothing);
    expect(find.text('Decline'), findsNothing);
  });

  testWidgets(
    'professional can decline requested appointment through backend',
    (tester) async {
      final schedulingRepository = _FakeSchedulingRepository(
        appointments: <AppointmentSummary>[
          _appointment(
            professionalProfileId: 'professional-upcoming',
            requestedStartAt: DateTime(2026, 7, 15, 10, 30),
            status: AppointmentStatus.requested,
          ),
        ],
      );

      await _pumpAppointments(
        tester,
        role: 'PROFESSIONAL',
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: schedulingRepository,
      );

      await tester.tap(find.text('Decline'));
      await tester.pumpAndSettle();

      expect(schedulingRepository.declinedAppointmentIds, <String>[
        'appointment-1',
      ]);
      expect(find.text('DECLINED'), findsOneWidget);
      expect(
        find.text('Appointment updated. Backend status: DECLINED.'),
        findsOneWidget,
      );
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
    },
  );

  testWidgets(
    'patient session does not expose professional lifecycle actions',
    (tester) async {
      await _pumpAppointments(
        tester,
        role: 'PATIENT',
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: _FakeSchedulingRepository(
          appointments: <AppointmentSummary>[
            _appointment(
              professionalProfileId: 'professional-upcoming',
              requestedStartAt: DateTime(2026, 7, 15, 10, 30),
              status: AppointmentStatus.requested,
            ),
          ],
        ),
      );

      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
      expect(find.text('Cancel appointment'), findsOneWidget);
    },
  );

  testWidgets(
    'professional lifecycle actions only appear for requested state',
    (tester) async {
      await _pumpAppointments(
        tester,
        role: 'PROFESSIONAL',
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: _FakeSchedulingRepository(
          appointments: <AppointmentSummary>[
            _appointment(
              professionalProfileId: 'professional-accepted',
              requestedStartAt: DateTime(2026, 7, 15, 10, 30),
              status: AppointmentStatus.accepted,
            ),
          ],
        ),
      );

      expect(find.text('ACCEPTED'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
      expect(find.text('Complete'), findsNothing);
      expect(find.text('Cancel appointment'), findsNothing);
      expect(find.text('Reschedule'), findsOneWidget);
    },
  );

  testWidgets(
    'non patient and non professional sessions do not expose reschedule',
    (tester) async {
      await _pumpAppointments(
        tester,
        role: 'ADMIN',
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: _FakeSchedulingRepository(
          appointments: <AppointmentSummary>[
            _appointment(
              professionalProfileId: 'professional-upcoming',
              requestedStartAt: DateTime(2026, 7, 15, 10, 30),
              status: AppointmentStatus.requested,
            ),
          ],
        ),
      );

      expect(find.text('REQUESTED'), findsOneWidget);
      expect(find.text('Reschedule'), findsNothing);
    },
  );

  testWidgets(
    'professional can complete accepted past appointment through backend',
    (tester) async {
      final schedulingRepository = _FakeSchedulingRepository(
        appointments: <AppointmentSummary>[
          _appointment(
            professionalProfileId: 'professional-past',
            requestedStartAt: DateTime(2026, 7, 14, 7, 15),
            status: AppointmentStatus.accepted,
          ),
        ],
      );

      await _pumpAppointments(
        tester,
        role: 'PROFESSIONAL',
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: schedulingRepository,
      );

      expect(find.text('ACCEPTED'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
      expect(find.text('Cancel appointment'), findsNothing);

      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle();

      expect(schedulingRepository.completedAppointmentIds, <String>[
        'appointment-1',
      ]);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('ACCEPTED'), findsNothing);
      expect(
        find.text('Appointment completed. Backend status: COMPLETED.'),
        findsOneWidget,
      );
      expect(find.text('Complete'), findsNothing);
    },
  );

  testWidgets(
    'professional cannot complete accepted appointment before scheduled end',
    (tester) async {
      final schedulingRepository = _FakeSchedulingRepository(
        appointments: <AppointmentSummary>[
          _appointment(
            professionalProfileId: 'professional-active',
            requestedStartAt: DateTime(2026, 7, 14, 7, 45),
            status: AppointmentStatus.accepted,
          ),
        ],
      );

      await _pumpAppointments(
        tester,
        role: 'PROFESSIONAL',
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: schedulingRepository,
      );

      expect(find.text('ACCEPTED'), findsOneWidget);
      expect(find.text('Complete'), findsNothing);
      expect(schedulingRepository.completedAppointmentIds, isEmpty);
    },
  );

  testWidgets('professional can complete at the exact scheduled end time', (
    tester,
  ) async {
    final schedulingRepository = _FakeSchedulingRepository(
      appointments: <AppointmentSummary>[
        _appointment(
          professionalProfileId: 'professional-exact-end',
          requestedStartAt: DateTime(2026, 7, 14, 7, 30),
          status: AppointmentStatus.accepted,
        ),
      ],
    );

    await _pumpAppointments(
      tester,
      role: 'PROFESSIONAL',
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: schedulingRepository,
    );

    expect(find.text('Complete'), findsOneWidget);

    await tester.tap(find.text('Complete'));
    await tester.pumpAndSettle();

    expect(schedulingRepository.completedAppointmentIds, <String>[
      'appointment-1',
    ]);
    expect(find.text('COMPLETED'), findsOneWidget);
  });

  testWidgets('patient cannot complete accepted past appointment', (
    tester,
  ) async {
    final schedulingRepository = _FakeSchedulingRepository(
      appointments: <AppointmentSummary>[
        _appointment(
          professionalProfileId: 'professional-past',
          requestedStartAt: DateTime(2026, 7, 14, 7, 15),
          status: AppointmentStatus.accepted,
        ),
      ],
    );

    await _pumpAppointments(
      tester,
      role: 'PATIENT',
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: schedulingRepository,
    );

    expect(find.text('ACCEPTED'), findsOneWidget);
    expect(find.text('Complete'), findsNothing);
    expect(schedulingRepository.completedAppointmentIds, isEmpty);
  });

  testWidgets('cancelled and declined appointments do not expose completion', (
    tester,
  ) async {
    final schedulingRepository = _FakeSchedulingRepository(
      appointments: <AppointmentSummary>[
        _appointment(
          professionalProfileId: 'professional-cancelled',
          requestedStartAt: DateTime(2026, 7, 14, 7, 15),
          status: AppointmentStatus.cancelled,
        ),
        _appointment(
          id: 'appointment-2',
          professionalProfileId: 'professional-declined',
          requestedStartAt: DateTime(2026, 7, 14, 7, 15),
          status: AppointmentStatus.declined,
        ),
      ],
    );

    await _pumpAppointments(
      tester,
      role: 'PROFESSIONAL',
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: schedulingRepository,
    );

    expect(find.text('CANCELLED'), findsOneWidget);
    expect(find.text('DECLINED'), findsOneWidget);
    expect(find.text('Complete'), findsNothing);
    expect(schedulingRepository.completedAppointmentIds, isEmpty);
  });

  testWidgets('completed appointments do not expose duplicate completion', (
    tester,
  ) async {
    final schedulingRepository = _FakeSchedulingRepository(
      appointments: <AppointmentSummary>[
        _appointment(
          professionalProfileId: 'professional-completed',
          requestedStartAt: DateTime(2026, 7, 14, 7, 15),
          status: AppointmentStatus.completed,
        ),
      ],
    );

    await _pumpAppointments(
      tester,
      role: 'PROFESSIONAL',
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: schedulingRepository,
    );

    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('Complete'), findsNothing);
    expect(schedulingRepository.completedAppointmentIds, isEmpty);
  });

  testWidgets(
    'professional completion failure shows safe error without update',
    (tester) async {
      final schedulingRepository = _FakeSchedulingRepository(
        appointments: <AppointmentSummary>[
          _appointment(
            professionalProfileId: 'professional-past',
            requestedStartAt: DateTime(2026, 7, 14, 7, 15),
            status: AppointmentStatus.accepted,
          ),
        ],
        completeFailure: const AuthFailure(
          type: AuthFailureType.server,
          message: 'raw complete failure',
        ),
      );

      await _pumpAppointments(
        tester,
        role: 'PROFESSIONAL',
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: schedulingRepository,
      );

      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle();

      expect(
        find.text('Service is unavailable. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('raw complete failure'), findsNothing);
      expect(find.text('ACCEPTED'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);
    },
  );

  testWidgets('professional accept failure shows safe error without update', (
    tester,
  ) async {
    await _pumpAppointments(
      tester,
      role: 'PROFESSIONAL',
      now: DateTime(2026, 7, 14, 8),
      schedulingRepository: _FakeSchedulingRepository(
        appointments: <AppointmentSummary>[
          _appointment(
            professionalProfileId: 'professional-upcoming',
            requestedStartAt: DateTime(2026, 7, 15, 10, 30),
            status: AppointmentStatus.requested,
          ),
        ],
        acceptFailure: const AuthFailure(
          type: AuthFailureType.server,
          message: 'raw accept failure',
        ),
      ),
    );

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(
      find.text('Service is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('raw accept failure'), findsNothing);
    expect(find.text('REQUESTED'), findsOneWidget);
  });

  testWidgets(
    'appointment lifecycle keeps non-reschedule broader actions deferred',
    (tester) async {
      await _pumpAppointments(
        tester,
        role: 'PROFESSIONAL',
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: _FakeSchedulingRepository(
          appointments: <AppointmentSummary>[
            _appointment(
              professionalProfileId: 'professional-upcoming',
              requestedStartAt: DateTime(2026, 7, 15, 10, 30),
              status: AppointmentStatus.requested,
            ),
          ],
        ),
      );

      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
      expect(find.text('Reschedule'), findsOneWidget);
      expect(find.text('Complete'), findsNothing);
      expect(find.text('Payment'), findsNothing);
      expect(find.text('Notification'), findsNothing);
      expect(find.text('Calendar'), findsNothing);
      expect(find.text('Review'), findsNothing);
      expect(find.text('Notes'), findsNothing);
      expect(find.text('Prescription'), findsNothing);
      expect(find.text('Call'), findsNothing);
      expect(find.text('Admin'), findsNothing);
    },
  );

  testWidgets(
    'completion eligible appointment keeps broader actions deferred',
    (tester) async {
      await _pumpAppointments(
        tester,
        role: 'PROFESSIONAL',
        now: DateTime(2026, 7, 14, 8),
        schedulingRepository: _FakeSchedulingRepository(
          appointments: <AppointmentSummary>[
            _appointment(
              professionalProfileId: 'professional-past',
              requestedStartAt: DateTime(2026, 7, 14, 7, 15),
              status: AppointmentStatus.accepted,
            ),
          ],
        ),
      );

      expect(find.text('Complete'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
      expect(find.text('Cancel appointment'), findsNothing);
      expect(find.text('Reschedule'), findsNothing);
      expect(find.text('Payment'), findsNothing);
      expect(find.text('Notification'), findsNothing);
      expect(find.text('Calendar'), findsNothing);
      expect(find.text('Review'), findsNothing);
      expect(find.text('Notes'), findsNothing);
      expect(find.text('Prescription'), findsNothing);
      expect(find.text('Call'), findsNothing);
      expect(find.text('Admin'), findsNothing);
    },
  );

  testWidgets(
    'appointments screen shows backend empty state without local data',
    (tester) async {
      await _pumpAppointments(tester);

      expect(
        find.text('No backend appointments are available yet.'),
        findsOneWidget,
      );
      expect(find.text('Private consult with Dr. Lagbaja'), findsNothing);
    },
  );

  testWidgets('appointments screen shows safe error without local fallback', (
    tester,
  ) async {
    await _pumpAppointments(
      tester,
      schedulingRepository: _FakeSchedulingRepository(
        failure: const AuthFailure(
          type: AuthFailureType.unauthorized,
          message: 'raw auth failure',
        ),
      ),
    );

    expect(find.text('Please sign in again.'), findsOneWidget);
    expect(find.text('raw auth failure'), findsNothing);
    expect(find.text('Private consult with Dr. Lagbaja'), findsNothing);
  });

  testWidgets('appointments screen does not expose local draft booking', (
    tester,
  ) async {
    await _pumpAppointments(tester);

    expect(find.text('Book appointment'), findsNothing);
    expect(find.text('Booking starts here.'), findsNothing);
  });

  testWidgets('booking form validates and prepares backend-required details', (
    tester,
  ) async {
    await _pumpPreservedBookingShell(tester);

    await tester.tap(find.text('Review request details'));
    await tester.pumpAndSettle();

    expect(find.text('Clinician is required'), findsOneWidget);
    expect(find.text('Visit type is required'), findsOneWidget);
    expect(find.text('Preferred date is required'), findsOneWidget);
    expect(find.text('Reason for visit is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Dr. Bello');
    await tester.tap(find.text('Video visit'));
    await tester.enterText(find.byType(TextFormField).at(1), 'Fri, 31 May');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Review recurring headaches',
    );
    await tester.tap(find.text('Review request details'));
    await tester.pumpAndSettle();

    expect(find.text('Request details'), findsOneWidget);
    expect(find.text('Dr. Bello'), findsWidgets);
    expect(find.text('Review recurring headaches'), findsWidgets);
    expect(find.text('Backend request not sent'), findsOneWidget);
    expect(
      find.text(
        'No appointment request has been sent yet. Choose a backend availability slot in the upcoming request flow before this can be submitted.',
      ),
      findsOneWidget,
    );
    expect(find.text('Confirmed locally'), findsNothing);
  });

  testWidgets('prepared booking details can be cleared but not confirmed', (
    tester,
  ) async {
    await _pumpPreservedBookingShell(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Dr. Bello');
    await tester.tap(find.text('Video visit'));
    await tester.enterText(find.byType(TextFormField).at(1), 'Fri, 31 May');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Review recurring headaches',
    );
    await tester.tap(find.text('Review request details'));
    await tester.pumpAndSettle();

    expect(find.text('Backend request not sent'), findsOneWidget);
    expect(find.text('Confirm request'), findsNothing);

    await tester.tap(find.text('Clear details'));
    await tester.pumpAndSettle();

    expect(find.text('Request details'), findsNothing);
  });
}

SessionStore _sessionStore({required String role}) {
  return InMemorySessionStore()..save(_session(role: role));
}

AuthSessionModel _session({required String role}) {
  return AuthSessionModel.fromJson(<String, dynamic>{
    'accessToken': 'access-token',
    'refreshToken': 'refresh-token',
    'tokenType': 'Bearer',
    'expiresIn': 900,
    'user': <String, dynamic>{
      'id': 'user-1',
      'email': 'user@example.com',
      'role': role,
      'status': 'ACTIVE',
      'emailVerified': true,
    },
  });
}

AppointmentSummary _appointment({
  String id = 'appointment-1',
  String patientProfileId = 'patient-1',
  required String professionalProfileId,
  required DateTime requestedStartAt,
  required AppointmentStatus status,
}) {
  return AppointmentSummary(
    id: id,
    patientProfileId: patientProfileId,
    professionalProfileId: professionalProfileId,
    requestedStartAt: requestedStartAt,
    durationMinutes: 30,
    status: status,
  );
}

AvailabilityWindow _availabilityWindow({
  String id = 'availability-1',
  required int weekday,
  required int startMinute,
  required int endMinute,
}) {
  return AvailabilityWindow(
    id: id,
    weekday: weekday,
    startMinute: startMinute,
    endMinute: endMinute,
    timezone: 'Africa/Lagos',
    active: true,
  );
}
