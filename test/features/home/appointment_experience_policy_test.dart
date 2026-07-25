import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/services/appointment_experience_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = AppointmentExperiencePolicy();
  final now = DateTime.utc(2026, 7, 26, 12);

  group('appointment action policy', () {
    test('patient can cancel or reschedule requested and accepted states', () {
      for (final status in <AppointmentStatus>[
        AppointmentStatus.requested,
        AppointmentStatus.accepted,
      ]) {
        expect(
          policy.actionsFor(
            role: AppointmentViewerRole.patient,
            appointment: _appointment(status: status),
            now: now,
          ),
          <AppointmentUiAction>[
            AppointmentUiAction.cancel,
            AppointmentUiAction.reschedule,
          ],
        );
      }
    });

    test('professional requested mapping is complete and role specific', () {
      expect(
        policy.actionsFor(
          role: AppointmentViewerRole.professional,
          appointment: _appointment(status: AppointmentStatus.requested),
          now: now,
        ),
        <AppointmentUiAction>[
          AppointmentUiAction.accept,
          AppointmentUiAction.decline,
          AppointmentUiAction.cancel,
          AppointmentUiAction.reschedule,
        ],
      );
      expect(
        policy
            .actionsFor(
              role: AppointmentViewerRole.patient,
              appointment: _appointment(status: AppointmentStatus.requested),
              now: now,
            )
            .contains(AppointmentUiAction.accept),
        isFalse,
      );
      expect(
        policy.actionsFor(
          role: AppointmentViewerRole.professional,
          appointment: _appointment(
            status: AppointmentStatus.requested,
            start: now.subtract(const Duration(minutes: 1)),
          ),
          now: now,
        ),
        isNot(contains(AppointmentUiAction.accept)),
      );
    });

    test('completion appears only for professional after scheduled end', () {
      final accepted = _appointment(
        status: AppointmentStatus.accepted,
        start: DateTime.utc(2026, 7, 26, 11, 30),
      );
      expect(
        policy.actionsFor(
          role: AppointmentViewerRole.professional,
          appointment: accepted,
          now: now,
        ),
        contains(AppointmentUiAction.complete),
      );
      expect(
        policy.actionsFor(
          role: AppointmentViewerRole.professional,
          appointment: accepted,
          now: DateTime.utc(2026, 7, 26, 11, 59),
        ),
        isNot(contains(AppointmentUiAction.complete)),
      );
      expect(
        policy.actionsFor(
          role: AppointmentViewerRole.patient,
          appointment: accepted,
          now: now,
        ),
        isNot(contains(AppointmentUiAction.complete)),
      );
    });

    test('terminal, unknown and malformed appointments fail closed', () {
      for (final status in <AppointmentStatus>[
        AppointmentStatus.declined,
        AppointmentStatus.cancelled,
        AppointmentStatus.completed,
        AppointmentStatus.unknown,
      ]) {
        expect(
          policy.actionsFor(
            role: AppointmentViewerRole.professional,
            appointment: _appointment(status: status),
            now: now,
          ),
          isEmpty,
        );
      }
      expect(
        policy.actionsFor(
          role: AppointmentViewerRole.professional,
          appointment: _appointment(
            status: AppointmentStatus.requested,
            start: DateTime.fromMillisecondsSinceEpoch(0),
          ),
          now: now,
        ),
        isEmpty,
      );
    });
  });

  group('appointment grouping', () {
    test(
      'professional requests require action while patient requests do not',
      () {
        final requested = _appointment(status: AppointmentStatus.requested);
        expect(
          policy.sectionFor(
            role: AppointmentViewerRole.professional,
            appointment: requested,
            now: now,
          ),
          AppointmentListSection.actionNeeded,
        );
        expect(
          policy.sectionFor(
            role: AppointmentViewerRole.patient,
            appointment: requested,
            now: now,
          ),
          AppointmentListSection.upcoming,
        );
      },
    );

    test('upcoming and past sorting is deterministic with ID tie break', () {
      final sameTime = DateTime.utc(2026, 7, 27, 9);
      final values = <AppointmentSummary>[
        _appointment(id: 'b', start: sameTime),
        _appointment(id: 'a', start: sameTime),
        _appointment(id: 'c', start: DateTime.utc(2026, 7, 28, 9)),
      ];
      expect(
        policy
            .sortedForSection(
              appointments: values,
              section: AppointmentListSection.upcoming,
            )
            .map((item) => item.id),
        <String>['a', 'b', 'c'],
      );
      expect(
        policy
            .sortedForSection(
              appointments: values,
              section: AppointmentListSection.past,
            )
            .map((item) => item.id),
        <String>['c', 'a', 'b'],
      );
    });
  });
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
  );
}
