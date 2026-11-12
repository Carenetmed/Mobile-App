import 'package:intl/intl.dart';
import 'package:app_t/core/presentation/carenet_presentation.dart';
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
  static final Map<String, timezone.Location> _locations =
      <String, timezone.Location>{};
  static final Map<String, DateFormat> _formats = <String, DateFormat>{};

  final Map<String, String> _professionalDates = <String, String>{};

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
    final location = _location(professionalTimezone);
    final professional = timezone.TZDateTime.from(utc, location);
    final local = utc.toLocal();
    final professionalOffset = professional.timeZoneOffset;
    final localOffset = local.timeZoneOffset;
    return ProfessionalTimeLabels(
      professionalDate: _dateFormat('EEE, d MMM y').format(professional),
      professionalTime: _dateFormat('h:mm a').format(professional),
      professionalTimezone: professionalTimezone,
      patientLocalTime:
          professionalOffset == localOffset
              ? null
              : '${_dateFormat('EEE, d MMM, h:mm a').format(local)} local time',
    );
  }

  String professionalDateLabel({
    required DateTime utcStartAt,
    required String professionalTimezone,
  }) {
    final professional = timezone.TZDateTime.from(
      utcStartAt.toUtc(),
      _location(professionalTimezone),
    );
    final key =
        '$professionalTimezone|${professional.year}-${professional.month}-${professional.day}';
    return _professionalDates.putIfAbsent(
      key,
      () => _dateFormat('EEE, d MMM y').format(professional),
    );
  }

  bool isValidTimezone(String value) {
    try {
      _location(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  static timezone.Location _location(String name) {
    return _locations.putIfAbsent(name, () => timezone.getLocation(name));
  }

  static DateFormat _dateFormat(String pattern) {
    final key = '${CareNetPresentation.dateLocale}|$pattern';
    return _formats.putIfAbsent(
      key,
      () => DateFormat(pattern, CareNetPresentation.dateLocale),
    );
  }
}
