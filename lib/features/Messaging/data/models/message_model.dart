import 'package:app_t/features/Messaging/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required String id,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String content,
    required DateTime timestamp,
    required bool isRead,
    String? attachmentUrl,
    required MessageType type,
  }) : super(
    id: id,
    senderId: senderId,
    senderName: senderName,
    senderAvatar: senderAvatar,
    content: content,
    timestamp: timestamp,
    isRead: isRead,
    attachmentUrl: attachmentUrl,
    type: type,
  );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatar: json['senderAvatar'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool,
      attachmentUrl: json['attachmentUrl'] as String?,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'attachmentUrl': attachmentUrl,
      'type': type.toString().split('.').last,
    };
  }
}
