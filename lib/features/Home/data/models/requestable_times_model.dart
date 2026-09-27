import '../../domain/entities/requestable_times.dart';

class RequestableTimesModel extends RequestableTimes {
  const RequestableTimesModel({
    required super.professionalProfileId,
    required super.timezone,
    required super.durationMinutes,
    required super.cadenceMinutes,
    required super.leadTimeMinutes,
    required super.bookingHorizonDays,
    required super.times,
    super.rangeStartAt,
    super.rangeEndAt,
  });

  factory RequestableTimesModel.fromJson(Map<String, dynamic> json) {
    final rawTimes = json['times'];
    return RequestableTimesModel(
      professionalProfileId: json['professionalProfileId'] as String? ?? '',
      timezone: json['timezone'] as String?,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      cadenceMinutes: json['cadenceMinutes'] as int? ?? 0,
      leadTimeMinutes: json['leadTimeMinutes'] as int? ?? 0,
      bookingHorizonDays: json['bookingHorizonDays'] as int? ?? 0,
      rangeStartAt: RequestableTimeModel.utcInstant(json['rangeStartAt']),
      rangeEndAt: RequestableTimeModel.utcInstant(json['rangeEndAt']),
      times:
          rawTimes is List
              ? rawTimes
                  .whereType<Map<String, dynamic>>()
                  .map(RequestableTimeModel.tryFromJson)
                  .whereType<RequestableTimeModel>()
                  .toList(growable: false)
              : const <RequestableTime>[],
    );
  }
}

class RequestableTimeModel extends RequestableTime {
  const RequestableTimeModel({required super.startAt, required super.endAt});

  static RequestableTimeModel? tryFromJson(Map<String, dynamic> json) {
    final startAt = utcInstant(json['startAt']);
    final endAt = utcInstant(json['endAt']);
    if (startAt == null || endAt == null || !endAt.isAfter(startAt)) {
      return null;
    }
    return RequestableTimeModel(startAt: startAt, endAt: endAt);
  }

  static DateTime? utcInstant(Object? value) {
    final parsed = DateTime.tryParse(value is String ? value : '');
    if (parsed == null || !parsed.isUtc) {
      return null;
    }
    return parsed;
  }
}
