import 'package:app_t/features/Home/domain/entities/appointment_request_time_option.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';

class AppointmentRequestTimeOptions {
  const AppointmentRequestTimeOptions();

  static const List<int> defaultDurations = <int>[30, 45, 60];
  static const int _minutesPerDay = 24 * 60;

  List<AppointmentRequestTimeOption> generate({
    required List<AvailabilityWindow> windows,
    required DateTime now,
    List<int> durationMinutes = defaultDurations,
    int daysAhead = 7,
  }) {
    if (windows.isEmpty || durationMinutes.isEmpty || daysAhead <= 0) {
      return const <AppointmentRequestTimeOption>[];
    }

    final options = <AppointmentRequestTimeOption>[];
    final startDate = DateTime(now.year, now.month, now.day);
    final allowedDurations =
        durationMinutes.where((duration) => duration > 0).toSet().toList()
          ..sort();

    for (var dayOffset = 0; dayOffset < daysAhead; dayOffset += 1) {
      final date = startDate.add(Duration(days: dayOffset));
      for (final window in windows) {
        if (!_isUsableWindow(window) || window.weekday != date.weekday) {
          continue;
        }

        final requestedStartAt = DateTime(
          date.year,
          date.month,
          date.day,
          window.startMinute ~/ 60,
          window.startMinute % 60,
        );

        if (!requestedStartAt.isAfter(now)) {
          continue;
        }

        for (final duration in allowedDurations) {
          if (window.startMinute + duration > window.endMinute) {
            continue;
          }

          options.add(
            AppointmentRequestTimeOption(
              requestedStartAt: requestedStartAt,
              durationMinutes: duration,
              timezone: window.timezone,
              weekday: window.weekday,
              startMinute: window.startMinute,
              endMinute: window.endMinute,
            ),
          );
        }
      }
    }

    options.sort((a, b) {
      final dateComparison = a.requestedStartAt.compareTo(b.requestedStartAt);
      if (dateComparison != 0) {
        return dateComparison;
      }
      return a.durationMinutes.compareTo(b.durationMinutes);
    });

    return options;
  }

  bool _isUsableWindow(AvailabilityWindow window) {
    return window.active &&
        window.weekday >= DateTime.monday &&
        window.weekday <= DateTime.sunday &&
        window.startMinute >= 0 &&
        window.endMinute <= _minutesPerDay &&
        window.startMinute < window.endMinute;
  }
}
