import '../../domain/entities/availability_window.dart';

class AvailabilityWindowModel extends AvailabilityWindow {
  const AvailabilityWindowModel({
    required super.id,
    required super.weekday,
    required super.startMinute,
    required super.endMinute,
    required super.timezone,
    required super.active,
    super.createdAt,
    super.updatedAt,
  });

  factory AvailabilityWindowModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityWindowModel(
      id: (json['id'] as String?) ?? '',
      weekday: _asInt(json['weekday']),
      startMinute: _asInt(json['startMinute']),
      endMinute: _asInt(json['endMinute']),
      timezone: (json['timezone'] as String?) ?? '',
      active: json['active'] == true,
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  static int _asInt(Object? value) {
    return switch (value) {
      int parsed => parsed,
      num parsed => parsed.toInt(),
      String text => int.tryParse(text) ?? 0,
      _ => 0,
    };
  }

  static DateTime? _asDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

extension AvailabilityWindowDraftPayload on AvailabilityWindowDraft {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'weekday': weekday,
      'startMinute': startMinute,
      'endMinute': endMinute,
      'timezone': timezone,
      'active': active,
    };
  }
}
