class AppointmentRequestTimeOption {
  const AppointmentRequestTimeOption({
    required this.requestedStartAt,
    required this.durationMinutes,
    required this.timezone,
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
  });

  final DateTime requestedStartAt;
  final int durationMinutes;
  final String timezone;
  final int weekday;
  final int startMinute;
  final int endMinute;

  DateTime get requestedEndAt =>
      requestedStartAt.add(Duration(minutes: durationMinutes));

  String get startTimeLabel => _minuteLabel(startMinute);

  String get endTimeLabel => _minuteLabel(startMinute + durationMinutes);

  String get timeRangeLabel => '$startTimeLabel-$endTimeLabel';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppointmentRequestTimeOption &&
            requestedStartAt == other.requestedStartAt &&
            durationMinutes == other.durationMinutes &&
            timezone == other.timezone &&
            weekday == other.weekday &&
            startMinute == other.startMinute &&
            endMinute == other.endMinute;
  }

  @override
  int get hashCode {
    return Object.hash(
      requestedStartAt,
      durationMinutes,
      timezone,
      weekday,
      startMinute,
      endMinute,
    );
  }

  static String _minuteLabel(int minuteOfDay) {
    final hour = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}
