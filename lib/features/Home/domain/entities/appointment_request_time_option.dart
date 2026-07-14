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

  static String _minuteLabel(int minuteOfDay) {
    final hour = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}
