import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
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

class _FakeSchedulingRepository implements SchedulingRepository {
  _FakeSchedulingRepository({
    this.appointments = const <AppointmentSummary>[],
    this.failure,
    this.cancelFailure,
    this.acceptFailure,
  });

  final List<AppointmentSummary> appointments;
  final Object? failure;
  final Object? cancelFailure;
  final Object? acceptFailure;
  final List<String> cancelledAppointmentIds = <String>[];
  final List<String> acceptedAppointmentIds = <String>[];
  final List<String> declinedAppointmentIds = <String>[];

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
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppointmentSummary> rescheduleAppointment({
    required String appointmentId,
    required DateTime requestedStartAt,
    required int durationMinutes,
  }) {
    throw UnimplementedError();
  }

  AppointmentSummary _updatedAppointment({
    required String appointmentId,
    required AppointmentStatus status,
  }) {
    final appointment = appointments.firstWhere(
      (item) => item.id == appointmentId,
    );
    return AppointmentSummary(
      id: appointment.id,
      patientProfileId: appointment.patientProfileId,
      professionalProfileId: appointment.professionalProfileId,
      requestedStartAt: appointment.requestedStartAt,
      durationMinutes: appointment.durationMinutes,
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
      expect(find.text('Cancel appointment'), findsNothing);
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

  testWidgets('book appointment CTA opens booking route', (tester) async {
    await _pumpAppointments(tester);

    await tester.tap(find.text('Book appointment'));
    await tester.pumpAndSettle();

    expect(find.text('Book Appointment'), findsOneWidget);
    expect(find.text('Booking starts here.'), findsOneWidget);
  });

  testWidgets('booking form validates and prepares backend-required details', (
    tester,
  ) async {
    await _pumpAppointments(tester);

    await tester.tap(find.text('Book appointment'));
    await tester.pumpAndSettle();

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
    await _pumpAppointments(tester);

    await tester.tap(find.text('Book appointment'));
    await tester.pumpAndSettle();

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
