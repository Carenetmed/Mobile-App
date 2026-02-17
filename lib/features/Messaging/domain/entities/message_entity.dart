class MessageEntity {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;
  final MessageType type;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.attachmentUrl,
    required this.type,
  });
}

enum MessageType { text, image, file, voice }
