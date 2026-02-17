import 'package:app_t/features/Messaging/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required String id,
    required String title,
    required String message,
    required DateTime timestamp,
    required bool isRead,
    required String type,
    String? actionUrl,
  }) : super(
    id: id,
    title: title,
    message: message,
    timestamp: timestamp,
    isRead: isRead,
    type: type,
    actionUrl: actionUrl,
  );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool,
      type: json['type'] as String,
      actionUrl: json['actionUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'actionUrl': actionUrl,
    };
  }
}
