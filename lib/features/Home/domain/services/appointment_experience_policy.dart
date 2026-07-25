import '../entities/appointment_summary.dart';

enum AppointmentViewerRole { patient, professional, unsupported }

enum AppointmentUiAction { accept, decline, cancel, reschedule, complete }

enum AppointmentListSection { actionNeeded, upcoming, past, closed }

class AppointmentExperiencePolicy {
  const AppointmentExperiencePolicy();

  List<AppointmentUiAction> actionsFor({
    required AppointmentViewerRole role,
    required AppointmentSummary appointment,
    required DateTime now,
  }) {
    if (role == AppointmentViewerRole.unsupported ||
        !_hasUsableTime(appointment)) {
      return const <AppointmentUiAction>[];
    }

    return switch ((role, appointment.status)) {
      (
        AppointmentViewerRole.patient,
        AppointmentStatus.requested || AppointmentStatus.accepted,
      ) =>
        const <AppointmentUiAction>[
          AppointmentUiAction.cancel,
          AppointmentUiAction.reschedule,
        ],
      (AppointmentViewerRole.professional, AppointmentStatus.requested) =>
        <AppointmentUiAction>[
          if (appointment.requestedStartAt.isAfter(now))
            AppointmentUiAction.accept,
          AppointmentUiAction.decline,
          AppointmentUiAction.cancel,
          AppointmentUiAction.reschedule,
        ],
      (AppointmentViewerRole.professional, AppointmentStatus.accepted) =>
        <AppointmentUiAction>[
          AppointmentUiAction.cancel,
          AppointmentUiAction.reschedule,
          if (!_scheduledEnd(appointment).isAfter(now))
            AppointmentUiAction.complete,
        ],
      _ => const <AppointmentUiAction>[],
    };
  }

  AppointmentListSection sectionFor({
    required AppointmentViewerRole role,
    required AppointmentSummary appointment,
    required DateTime now,
  }) {
    if (appointment.status == AppointmentStatus.cancelled ||
        appointment.status == AppointmentStatus.declined ||
        appointment.status == AppointmentStatus.unknown) {
      return AppointmentListSection.closed;
    }
    if (appointment.status == AppointmentStatus.completed ||
        !_hasUsableTime(appointment) ||
        appointment.requestedStartAt.isBefore(now)) {
      return AppointmentListSection.past;
    }
    if (role == AppointmentViewerRole.professional &&
        appointment.status == AppointmentStatus.requested) {
      return AppointmentListSection.actionNeeded;
    }
    return AppointmentListSection.upcoming;
  }

  List<AppointmentSummary> sortedForSection({
    required Iterable<AppointmentSummary> appointments,
    required AppointmentListSection section,
  }) {
    final sorted = appointments.toList(growable: false);
    sorted.sort((left, right) {
      final timeComparison =
          section == AppointmentListSection.past ||
                  section == AppointmentListSection.closed
              ? right.requestedStartAt.compareTo(left.requestedStartAt)
              : left.requestedStartAt.compareTo(right.requestedStartAt);
      return timeComparison != 0 ? timeComparison : left.id.compareTo(right.id);
    });
    return sorted;
  }

  static bool _hasUsableTime(AppointmentSummary appointment) {
    return appointment.requestedStartAt.millisecondsSinceEpoch > 0 &&
        appointment.durationMinutes > 0;
  }

  static DateTime _scheduledEnd(AppointmentSummary appointment) {
    return appointment.requestedStartAt.add(
      Duration(minutes: appointment.durationMinutes),
    );
  }
}
