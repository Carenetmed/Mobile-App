class AvailabilityWindow {
  const AvailabilityWindow({
    required this.id,
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
    required this.timezone,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final int weekday;
  final int startMinute;
  final int endMinute;
  final String timezone;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class AvailabilityWindowDraft {
  const AvailabilityWindowDraft({
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
    required this.timezone,
    required this.active,
  });

  final int weekday;
  final int startMinute;
  final int endMinute;
  final String timezone;
  final bool active;
}
