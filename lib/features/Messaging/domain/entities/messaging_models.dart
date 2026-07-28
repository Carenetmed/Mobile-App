class MessagingParticipant {
  const MessagingParticipant({
    required this.userId,
    required this.displayName,
    required this.role,
  });

  final String userId;
  final String displayName;
  final String role;

  factory MessagingParticipant.fromJson(Map<String, dynamic> json) {
    return MessagingParticipant(
      userId: _requiredString(json, 'userId'),
      displayName: _requiredString(json, 'displayName'),
      role: _requiredString(json, 'role'),
    );
  }
}

class ConversationLastMessage {
  const ConversationLastMessage({
    required this.messageId,
    required this.sequence,
    required this.authorUserId,
    required this.createdAt,
    required this.preview,
  });

  final String messageId;
  final BigInt sequence;
  final String authorUserId;
  final DateTime createdAt;
  final String preview;

  factory ConversationLastMessage.fromJson(Map<String, dynamic> json) {
    return ConversationLastMessage(
      messageId: _requiredString(json, 'messageId'),
      sequence: _requiredBigInt(json, 'sequence'),
      authorUserId: _requiredString(json, 'authorUserId'),
      createdAt: _requiredDate(json, 'createdAt'),
      preview: _requiredString(json, 'preview'),
    );
  }
}

class ConversationSummary {
  const ConversationSummary({
    required this.conversationId,
    required this.appointmentId,
    required this.appointmentStatus,
    required this.requestedStartAt,
    required this.durationMinutes,
    required this.writable,
    required this.counterpart,
    required this.unreadCount,
    required this.readThroughSequence,
    required this.lastActivityAt,
    required this.updatedAt,
    this.writableUntil,
    this.lastMessage,
  });

  final String conversationId;
  final String appointmentId;
  final String appointmentStatus;
  final DateTime requestedStartAt;
  final int durationMinutes;
  final bool writable;
  final DateTime? writableUntil;
  final MessagingParticipant counterpart;
  final ConversationLastMessage? lastMessage;
  final int unreadCount;
  final BigInt readThroughSequence;
  final DateTime lastActivityAt;
  final DateTime updatedAt;

  bool get isReadableLifecycle {
    return const <String>{
      'ACCEPTED',
      'COMPLETED',
      'REQUESTED',
      'CANCELLED',
    }.contains(appointmentStatus.toUpperCase());
  }

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    final counterpart = _map(json['counterpart'], 'counterpart');
    final lastMessage = json['lastMessage'];
    return ConversationSummary(
      conversationId: _requiredString(json, 'conversationId'),
      appointmentId: _requiredString(json, 'appointmentId'),
      appointmentStatus: _requiredString(json, 'appointmentStatus'),
      requestedStartAt: _requiredDate(json, 'requestedStartAt'),
      durationMinutes: _requiredInt(json, 'durationMinutes'),
      writable: json['writable'] == true,
      writableUntil: _optionalDate(json['writableUntil']),
      counterpart: MessagingParticipant.fromJson(counterpart),
      lastMessage:
          lastMessage is Map<String, dynamic>
              ? ConversationLastMessage.fromJson(lastMessage)
              : null,
      unreadCount: _requiredIntLike(json, 'unreadCount'),
      readThroughSequence: _requiredBigInt(json, 'readThroughSequence'),
      lastActivityAt: _requiredDate(json, 'lastActivityAt'),
      updatedAt: _requiredDate(json, 'updatedAt'),
    );
  }
}

class ConversationPage {
  const ConversationPage({
    required this.conversations,
    required this.hasMore,
    required this.serverTime,
    this.nextCursor,
  });

  final List<ConversationSummary> conversations;
  final bool hasMore;
  final String? nextCursor;
  final DateTime serverTime;

  factory ConversationPage.fromJson(Map<String, dynamic> json) {
    final pageInfo = _map(json['pageInfo'], 'pageInfo');
    final items = json['conversations'];
    if (items is! List) {
      throw const FormatException('Invalid conversations response.');
    }
    return ConversationPage(
      conversations: items
          .map((item) => ConversationSummary.fromJson(_map(item, 'item')))
          .toList(growable: false),
      hasMore: pageInfo['hasMore'] == true,
      nextCursor: _optionalString(pageInfo['nextCursor']),
      serverTime: _requiredDate(json, 'serverTime'),
    );
  }
}

class ConversationDetail {
  const ConversationDetail({
    required this.conversationId,
    required this.appointmentId,
    required this.appointmentStatus,
    required this.patient,
    required this.professional,
    required this.writable,
    required this.patientLastReadSequence,
    required this.professionalLastReadSequence,
    this.lastMessageSequence,
    required this.lastActivityAt,
    required this.serverTime,
    this.writableUntil,
  });

  final String conversationId;
  final String appointmentId;
  final String appointmentStatus;
  final MessagingParticipant patient;
  final MessagingParticipant professional;
  final bool writable;
  final DateTime? writableUntil;
  final BigInt patientLastReadSequence;
  final BigInt professionalLastReadSequence;
  final BigInt? lastMessageSequence;
  final DateTime lastActivityAt;
  final DateTime serverTime;

  BigInt counterpartReadSequence(String currentUserId) {
    return currentUserId == patient.userId
        ? professionalLastReadSequence
        : patientLastReadSequence;
  }

  factory ConversationDetail.fromJson(Map<String, dynamic> json) {
    return ConversationDetail(
      conversationId: _requiredString(json, 'conversationId'),
      appointmentId: _requiredString(json, 'appointmentId'),
      appointmentStatus: _requiredString(json, 'appointmentStatus'),
      patient: MessagingParticipant.fromJson(_map(json['patient'], 'patient')),
      professional: MessagingParticipant.fromJson(
        _map(json['professional'], 'professional'),
      ),
      writable: json['writable'] == true,
      writableUntil: _optionalDate(json['writableUntil']),
      patientLastReadSequence: _requiredBigInt(json, 'patientLastReadSequence'),
      professionalLastReadSequence: _requiredBigInt(
        json,
        'professionalLastReadSequence',
      ),
      lastMessageSequence: _optionalBigInt(json['lastMessageSequence']),
      lastActivityAt: _requiredDate(json, 'lastActivityAt'),
      serverTime: _requiredDate(json, 'serverTime'),
    );
  }
}

class CareMessage {
  const CareMessage({
    required this.id,
    required this.conversationId,
    required this.sequence,
    required this.clientMessageId,
    required this.authorUserId,
    required this.text,
    required this.createdAt,
    required this.seenByOther,
  });

  final String id;
  final String conversationId;
  final BigInt sequence;
  final String clientMessageId;
  final String authorUserId;
  final String text;
  final DateTime createdAt;
  final bool seenByOther;

  factory CareMessage.fromJson(Map<String, dynamic> json) {
    return CareMessage(
      id: _requiredString(json, 'id'),
      conversationId: _requiredString(json, 'conversationId'),
      sequence: _requiredBigInt(json, 'sequence'),
      clientMessageId: _requiredString(json, 'clientMessageId'),
      authorUserId: _requiredString(json, 'authorUserId'),
      text: _requiredString(json, 'text'),
      createdAt: _requiredDate(json, 'createdAt'),
      seenByOther: json['seenByOther'] == true,
    );
  }
}

class MessagePage {
  const MessagePage({
    required this.messages,
    required this.hasMoreBefore,
    required this.hasMoreAfter,
    this.firstSequence,
    this.lastSequence,
  });

  final List<CareMessage> messages;
  final bool hasMoreBefore;
  final bool hasMoreAfter;
  final BigInt? firstSequence;
  final BigInt? lastSequence;

  factory MessagePage.fromJson(Map<String, dynamic> json) {
    final items = json['messages'];
    final pageInfo = _map(json['pageInfo'], 'pageInfo');
    if (items is! List) {
      throw const FormatException('Invalid messages response.');
    }
    return MessagePage(
      messages: items
          .map((item) => CareMessage.fromJson(_map(item, 'message')))
          .toList(growable: false),
      hasMoreBefore: pageInfo['hasMoreBefore'] == true,
      hasMoreAfter: pageInfo['hasMoreAfter'] == true,
      firstSequence: _optionalBigInt(pageInfo['firstSequence']),
      lastSequence: _optionalBigInt(pageInfo['lastSequence']),
    );
  }
}

Map<String, dynamic> _map(Object? value, String name) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException('Invalid $name.');
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw FormatException('Invalid $key.');
}

String? _optionalString(Object? value) {
  return value is String && value.trim().isNotEmpty ? value : null;
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  throw FormatException('Invalid $key.');
}

int _requiredIntLike(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  final parsed = value is String ? int.tryParse(value) : null;
  if (parsed != null) {
    return parsed;
  }
  throw FormatException('Invalid $key.');
}

BigInt _requiredBigInt(Map<String, dynamic> json, String key) {
  final parsed = _optionalBigInt(json[key]);
  if (parsed != null) {
    return parsed;
  }
  throw FormatException('Invalid $key.');
}

BigInt? _optionalBigInt(Object? value) {
  if (value is int) {
    return BigInt.from(value);
  }
  return value is String ? BigInt.tryParse(value) : null;
}

DateTime _requiredDate(Map<String, dynamic> json, String key) {
  final parsed = _optionalDate(json[key]);
  if (parsed != null) {
    return parsed;
  }
  throw FormatException('Invalid $key.');
}

DateTime? _optionalDate(Object? value) {
  return value is String ? DateTime.tryParse(value)?.toUtc() : null;
}
