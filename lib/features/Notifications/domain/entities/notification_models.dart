enum NotificationCategory {
  appointments('APPOINTMENTS', 'Appointments'),
  messages('MESSAGES', 'Messages'),
  consultations('CONSULTATIONS', 'Consultations'),
  payments('PAYMENTS', 'Payments'),
  earningsAndPayouts('EARNINGS_AND_PAYOUTS', 'Earnings and payouts'),
  accountAndSecurity('ACCOUNT_AND_SECURITY', 'Account and security'),
  professionalVerification(
    'PROFESSIONAL_VERIFICATION',
    'Professional verification',
  );

  const NotificationCategory(this.wireName, this.label);

  final String wireName;
  final String label;

  static NotificationCategory fromWire(String value) {
    return values.firstWhere(
      (category) => category.wireName == value,
      orElse:
          () => throw const FormatException('Unknown notification category.'),
    );
  }
}

class CareNotification {
  const CareNotification({
    required this.id,
    required this.category,
    required this.priority,
    required this.title,
    required this.body,
    required this.occurrenceCount,
    required this.firstOccurredAt,
    required this.latestOccurredAt,
    required this.readAt,
    this.routeCode,
    this.entityId,
  });

  factory CareNotification.fromJson(Map<String, dynamic> json) {
    return CareNotification(
      id: _requiredString(json, 'id'),
      category: NotificationCategory.fromWire(
        _requiredString(json, 'category'),
      ),
      priority: _requiredString(json, 'priority'),
      title: _requiredString(json, 'title'),
      body: _requiredString(json, 'body'),
      routeCode: _optionalString(json['routeCode']),
      entityId: _optionalString(json['entityId']),
      occurrenceCount: _positiveInt(json['occurrenceCount']),
      firstOccurredAt: _date(json, 'firstOccurredAt'),
      latestOccurredAt: _date(json, 'latestOccurredAt'),
      readAt: _optionalDate(json['readAt']),
    );
  }

  final String id;
  final NotificationCategory category;
  final String priority;
  final String title;
  final String body;
  final String? routeCode;
  final String? entityId;
  final int occurrenceCount;
  final DateTime firstOccurredAt;
  final DateTime latestOccurredAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  CareNotification markRead(DateTime value) {
    return CareNotification(
      id: id,
      category: category,
      priority: priority,
      title: title,
      body: body,
      routeCode: routeCode,
      entityId: entityId,
      occurrenceCount: occurrenceCount,
      firstOccurredAt: firstOccurredAt,
      latestOccurredAt: latestOccurredAt,
      readAt: value,
    );
  }
}

class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawPageInfo = json['pageInfo'];
    if (rawItems is! List || rawPageInfo is! Map<String, dynamic>) {
      throw const FormatException('Invalid notification page.');
    }
    return NotificationPage(
      items: rawItems
          .map(
            (item) =>
                CareNotification.fromJson(_object(item, 'notification item')),
          )
          .toList(growable: false),
      hasMore: rawPageInfo['hasMore'] == true,
      nextCursor: _optionalString(rawPageInfo['nextCursor']),
    );
  }

  final List<CareNotification> items;
  final bool hasMore;
  final String? nextCursor;
}

class NotificationPreference {
  const NotificationPreference({
    required this.category,
    required this.pushEnabled,
    required this.emailEnabled,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      category: NotificationCategory.fromWire(
        _requiredString(json, 'category'),
      ),
      pushEnabled: json['pushEnabled'] == true,
      emailEnabled: json['emailEnabled'] == true,
    );
  }

  final NotificationCategory category;
  final bool pushEnabled;
  final bool emailEnabled;

  NotificationPreference copyWith({bool? pushEnabled, bool? emailEnabled}) {
    return NotificationPreference(
      category: category,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'category': category.wireName,
    'pushEnabled': pushEnabled,
    'emailEnabled': emailEnabled,
  };
}

Map<String, dynamic> _object(Object? value, String label) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Invalid $label.');
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw FormatException('Missing $key.');
}

String? _optionalString(Object? value) {
  if (value == null) return null;
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}

int _positiveInt(Object? value) {
  if (value is int && value > 0) return value;
  throw const FormatException('Invalid occurrence count.');
}

DateTime _date(Map<String, dynamic> json, String key) {
  final value = _optionalDate(json[key]);
  if (value == null) throw FormatException('Missing $key.');
  return value;
}

DateTime? _optionalDate(Object? value) {
  if (value == null) return null;
  if (value is! String) throw const FormatException('Invalid timestamp.');
  final parsed = DateTime.tryParse(value);
  if (parsed == null) throw const FormatException('Invalid timestamp.');
  return parsed.toUtc();
}
