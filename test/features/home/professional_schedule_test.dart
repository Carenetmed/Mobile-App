import 'dart:async';

import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/requestable_times.dart';
import 'package:app_t/features/Home/presentation/pages/selected_dates_shell.dart';
import 'package:app_t/features/Home/presentation/state/professional_schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'professional schedule loads and orders backend weekday zero first',
    () async {
      final repository = _ScheduleRepository(
        windows: <AvailabilityWindow>[
          _window(id: 'monday', weekday: 1),
          _window(id: 'sunday', weekday: 0),
        ],
      );
      final controller = ProfessionalScheduleController(
        schedulingRepository: repository,
        sessionStore: _sessionStore('PROFESSIONAL'),
      );

      await controller.load();

      expect(controller.isAuthorizedProfessional, isTrue);
      expect(controller.windows.map((window) => window.id), <String>[
        'sunday',
        'monday',
      ]);
      controller.dispose();
    },
  );

  test('patient role fails closed without calling own availability', () async {
    final repository = _ScheduleRepository();
    final controller = ProfessionalScheduleController(
      schedulingRepository: repository,
      sessionStore: _sessionStore('PATIENT'),
    );

    await controller.load();

    expect(controller.isAuthorizedProfessional, isFalse);
    expect(repository.readCalls, 0);
    controller.dispose();
  });

  test('validation rejects invalid timezone, interval and overlap', () async {
    final controller = ProfessionalScheduleController(
      schedulingRepository: _ScheduleRepository(
        windows: <AvailabilityWindow>[_window()],
      ),
      sessionStore: _sessionStore('PROFESSIONAL'),
    );
    await controller.load();

    expect(
      controller.validate(
        const AvailabilityWindowDraft(
          weekday: 1,
          startMinute: 600,
          endMinute: 540,
          timezone: 'Africa/Lagos',
          active: true,
        ),
      ),
      contains('after'),
    );
    expect(
      controller.validate(
        const AvailabilityWindowDraft(
          weekday: 1,
          startMinute: 600,
          endMinute: 660,
          timezone: 'Not/A_Timezone',
          active: true,
        ),
      ),
      contains('IANA'),
    );
    expect(
      controller.validate(
        const AvailabilityWindowDraft(
          weekday: 1,
          startMinute: 570,
          endMinute: 630,
          timezone: 'Africa/Lagos',
          active: true,
        ),
      ),
      contains('overlaps'),
    );
    controller.dispose();
  });

  test('save replaces weekly set and reloads authoritative response', () async {
    final repository = _ScheduleRepository(
      windows: <AvailabilityWindow>[_window()],
    );
    final controller = ProfessionalScheduleController(
      schedulingRepository: repository,
      sessionStore: _sessionStore('PROFESSIONAL'),
    );
    await controller.load();

    final error = await controller.save(
      draft: const AvailabilityWindowDraft(
        weekday: 0,
        startMinute: 600,
        endMinute: 660,
        timezone: 'Africa/Lagos',
        active: true,
      ),
    );

    expect(error, isNull);
    expect(repository.replaceCalls, 1);
    expect(repository.readCalls, 2);
    expect(repository.lastReplacement.map((draft) => draft.weekday), <int>[
      1,
      0,
    ]);
    expect(controller.successMessage, 'Availability added.');
    controller.dispose();
  });

  test('repeated mutation is serialized', () async {
    final completer = Completer<List<AvailabilityWindow>>();
    final repository = _ScheduleRepository(
      windows: <AvailabilityWindow>[_window()],
      pendingReplace: completer,
    );
    final controller = ProfessionalScheduleController(
      schedulingRepository: repository,
      sessionStore: _sessionStore('PROFESSIONAL'),
    );
    await controller.load();
    const draft = AvailabilityWindowDraft(
      weekday: 0,
      startMinute: 600,
      endMinute: 660,
      timezone: 'Africa/Lagos',
      active: true,
    );

    final first = controller.save(draft: draft);
    final second = await controller.save(draft: draft);
    expect(second, contains('in progress'));
    expect(repository.replaceCalls, 1);
    completer.complete(repository.windows);
    await first;
    controller.dispose();
  });

  testWidgets('professional Schedule shows recurring rules, not slots', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder:
            (_, __) => MaterialApp(
              home: SelectedDatesShellPage(
                schedulingRepository: _ScheduleRepository(
                  windows: <AvailabilityWindow>[_window(weekday: 0)],
                ),
                sessionStore: _sessionStore('PROFESSIONAL'),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Weekly availability'), findsOneWidget);
    expect(find.text('Sunday'), findsOneWidget);
    expect(
      find.textContaining('Africa/Lagos', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'not confirmed appointment slots',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Generated slot'), findsNothing);
  });

  testWidgets('patient cannot access professional Schedule authority', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder:
            (_, __) => MaterialApp(
              home: SelectedDatesShellPage(
                schedulingRepository: _ScheduleRepository(),
                sessionStore: _sessionStore('PATIENT'),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Schedule unavailable'), findsOneWidget);
    expect(find.text('Add availability window'), findsNothing);
  });
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

AvailabilityWindow _window({String id = 'window-1', int weekday = 1}) {
  return AvailabilityWindow(
    id: id,
    weekday: weekday,
    startMinute: 540,
    endMinute: 600,
    timezone: 'Africa/Lagos',
    active: true,
  );
}

class _ScheduleRepository implements SchedulingRepository {
  _ScheduleRepository({List<AvailabilityWindow>? windows, this.pendingReplace})
    : windows = windows ?? <AvailabilityWindow>[];

  List<AvailabilityWindow> windows;
  final Completer<List<AvailabilityWindow>>? pendingReplace;
  int readCalls = 0;
  int replaceCalls = 0;
  List<AvailabilityWindowDraft> lastReplacement = const [];

  @override
  Future<List<AvailabilityWindow>> ownAvailability() async {
    readCalls++;
    return windows;
  }

  @override
  Future<List<AvailabilityWindow>> replaceOwnAvailability({
    required List<AvailabilityWindowDraft> windows,
  }) async {
    replaceCalls++;
    lastReplacement = List<AvailabilityWindowDraft>.from(windows);
    final pending = pendingReplace;
    if (pending != null && !pending.isCompleted) {
      return pending.future;
    }
    this.windows =
        windows
            .asMap()
            .entries
            .map(
              (entry) => AvailabilityWindow(
                id: 'saved-${entry.key}',
                weekday: entry.value.weekday,
                startMinute: entry.value.startMinute,
                endMinute: entry.value.endMinute,
                timezone: entry.value.timezone,
                active: entry.value.active,
              ),
            )
            .toList();
    return this.windows;
  }

  @override
  Future<List<AppointmentSummary>> ownAppointments() async => const [];

  @override
  Future<AppointmentSummary> acceptAppointment({
    required String appointmentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppointmentSummary> cancelAppointment({
    required String appointmentId,
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<AvailabilityWindow>> publicAvailability({
    required String professionalProfileId,
  }) async => const [];

  @override
  Future<RequestableTimes> publicRequestableTimes({
    required String professionalProfileId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppointmentSummary> requestAppointment({
    required String professionalProfileId,
    required DateTime requestedStartAt,
    required int durationMinutes,
    required String idempotencyKey,
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
}
