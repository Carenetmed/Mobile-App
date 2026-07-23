import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

class ProfessionalTimeLabels {
  const ProfessionalTimeLabels({
    required this.professionalDate,
    required this.professionalTime,
    required this.professionalTimezone,
    this.patientLocalTime,
  });

  final String professionalDate;
  final String professionalTime;
  final String professionalTimezone;
  final String? patientLocalTime;
}

class ProfessionalTimeFormatter {
  ProfessionalTimeFormatter() {
    _initialize();
  }

  static bool _initialized = false;

  static void _initialize() {
    if (_initialized) {
      return;
    }
    timezone_data.initializeTimeZones();
    _initialized = true;
  }

  ProfessionalTimeLabels format({
    required DateTime utcStartAt,
    required String professionalTimezone,
  }) {
    final utc = utcStartAt.toUtc();
    final location = timezone.getLocation(professionalTimezone);
    final professional = timezone.TZDateTime.from(utc, location);
    final local = utc.toLocal();
    final professionalOffset = professional.timeZoneOffset;
    final localOffset = local.timeZoneOffset;
    return ProfessionalTimeLabels(
      professionalDate: DateFormat('EEE, d MMM y').format(professional),
      professionalTime: DateFormat('h:mm a').format(professional),
      professionalTimezone: professionalTimezone,
      patientLocalTime:
          professionalOffset == localOffset
              ? null
              : '${DateFormat('EEE, d MMM, h:mm a').format(local)} local time',
    );
  }

  bool isValidTimezone(String value) {
    try {
      timezone.getLocation(value);
      return true;
    } catch (_) {
      return false;
    }
  }
}
