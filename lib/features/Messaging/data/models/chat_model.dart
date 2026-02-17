import 'package:app_t/features/Messaging/domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  ChatModel({
    required String id,
    required String participantId,
    required String participantName,
    required String participantAvatar,
    required String lastMessage,
    required DateTime lastMessageTime,
    required int unreadCount,
    required bool isOnline,
    String? profession,
  }) : super(
    id: id,
    participantId: participantId,
    participantName: participantName,
    participantAvatar: participantAvatar,
    lastMessage: lastMessage,
    lastMessageTime: lastMessageTime,
    unreadCount: unreadCount,
    isOnline: isOnline,
    profession: profession,
  );

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      participantId: json['participantId'] as String,
      participantName: json['participantName'] as String,
      participantAvatar: json['participantAvatar'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: json['unreadCount'] as int,
      isOnline: json['isOnline'] as bool,
      profession: json['profession'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'participantAvatar': participantAvatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'profession': profession,
    };
  }
}
