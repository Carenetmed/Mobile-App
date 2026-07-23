class RequestableTime {
  const RequestableTime({required this.startAt, required this.endAt});

  final DateTime startAt;
  final DateTime endAt;

  int get durationMinutes => endAt.difference(startAt).inMinutes;
}

class RequestableTimes {
  const RequestableTimes({
    required this.professionalProfileId,
    required this.timezone,
    required this.durationMinutes,
    required this.cadenceMinutes,
    required this.leadTimeMinutes,
    required this.bookingHorizonDays,
    required this.times,
  });

  final String professionalProfileId;
  final String? timezone;
  final int durationMinutes;
  final int cadenceMinutes;
  final int leadTimeMinutes;
  final int bookingHorizonDays;
  final List<RequestableTime> times;
}
