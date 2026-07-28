import 'dart:async';

import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/models/auth_user_model.dart';
import 'package:app_t/features/Messaging/data/repositories/messaging_repository.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_client.dart';
import 'package:app_t/features/Messaging/domain/entities/messaging_models.dart';

class FakeMessagingRepository implements MessagingRepository {
  FakeMessagingRepository({
    this.userId = 'patient-user',
    this.role = 'PATIENT',
    List<ConversationSummary>? conversations,
    ConversationDetail? detail,
    List<CareMessage>? messages,
  }) : conversationsValue = conversations ?? <ConversationSummary>[],
       detailValue = detail ?? conversationDetail(),
       messagesValue = messages ?? <CareMessage>[];

  String userId;
  String role;
  List<ConversationSummary> conversationsValue;
  ConversationDetail detailValue;
  List<CareMessage> messagesValue;
  Object? conversationsError;
  Object? conversationError;
  Object? messagesError;
  Object? sessionError;
  Object? sendError;
  Completer<ConversationPage>? conversationsCompleter;
  List<ConversationPage> conversationPages = <ConversationPage>[];
  List<MessagePage> messagePages = <MessagePage>[];
  Completer<CareMessage>? sendCompleter;
  int conversationsCalls = 0;
  int conversationCalls = 0;
  int messagesCalls = 0;
  int markReadCalls = 0;
  int sendCalls = 0;
  final List<String> sentClientIds = <String>[];
  final List<String> sentTexts = <String>[];
  final List<String?> requestedCursors = <String?>[];
  final List<BigInt?> requestedBeforeSequences = <BigInt?>[];
  final List<BigInt?> requestedAfterSequences = <BigInt?>[];

  @override
  Future<MessagingSession> requireSession() async {
    final error = sessionError;
    if (error != null) {
      throw error;
    }
    return MessagingSession(
      AuthSessionModel(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        tokenType: 'Bearer',
        expiresIn: 900,
        user: AuthUserModel(
          id: userId,
          email: '$userId@example.test',
          role: role,
          status: 'ACTIVE',
          emailVerified: true,
        ),
      ),
    );
  }

  @override
  Future<ConversationPage> conversations({
    String? cursor,
    int limit = 30,
  }) async {
    conversationsCalls++;
    requestedCursors.add(cursor);
    final error = conversationsError;
    if (error != null) {
      throw error;
    }
    final completer = conversationsCompleter;
    if (completer != null) {
      conversationsCompleter = null;
      return completer.future;
    }
    if (conversationPages.isNotEmpty) {
      return conversationPages.removeAt(0);
    }
    return ConversationPage(
      conversations: conversationsValue,
      hasMore: false,
      serverTime: DateTime.utc(2026, 7, 26, 12),
    );
  }

  @override
  Future<ConversationDetail> conversation(String conversationId) async {
    conversationCalls++;
    final error = conversationError;
    if (error != null) {
      throw error;
    }
    return detailValue;
  }

  @override
  Future<ConversationSummary?> conversationForAppointment(
    String appointmentId,
  ) async {
    return conversationsValue
        .where((item) => item.appointmentId == appointmentId)
        .firstOrNull;
  }

  @override
  Future<MessagePage> messages({
    required String conversationId,
    BigInt? beforeSequence,
    BigInt? afterSequence,
    int limit = 50,
  }) async {
    messagesCalls++;
    requestedBeforeSequences.add(beforeSequence);
    requestedAfterSequences.add(afterSequence);
    final error = messagesError;
    if (error != null) {
      throw error;
    }
    if (messagePages.isNotEmpty) {
      return messagePages.removeAt(0);
    }
    final filtered =
        messagesValue.where((message) {
          if (beforeSequence != null) {
            return message.sequence < beforeSequence;
          }
          if (afterSequence != null) {
            return message.sequence > afterSequence;
          }
          return true;
        }).toList();
    return MessagePage(
      messages: filtered,
      hasMoreBefore: false,
      hasMoreAfter: false,
      firstSequence: filtered.isEmpty ? null : filtered.first.sequence,
      lastSequence: filtered.isEmpty ? null : filtered.last.sequence,
    );
  }

  @override
  Future<void> markRead({
    required String conversationId,
    required BigInt throughSequence,
  }) async {
    markReadCalls++;
  }

  @override
  Future<CareMessage> sendMessage({
    required String conversationId,
    required String clientMessageId,
    required String text,
  }) async {
    sendCalls++;
    sentClientIds.add(clientMessageId);
    sentTexts.add(text);
    final error = sendError;
    if (error != null) {
      throw error;
    }
    final completer = sendCompleter;
    if (completer != null) {
      sendCompleter = null;
      return completer.future;
    }
    final message = careMessage(
      id: 'server-$clientMessageId',
      clientMessageId: clientMessageId,
      text: text,
      authorUserId: userId,
      sequence: BigInt.from(messagesValue.length + 1),
    );
    messagesValue = <CareMessage>[...messagesValue, message];
    return message;
  }
}

class FakeRealtimeConnection implements MessagingRealtimeConnection {
  final StreamController<MessagingRealtimeHint> hintController =
      StreamController<MessagingRealtimeHint>.broadcast();
  final StreamController<bool> stateController =
      StreamController<bool>.broadcast();
  bool disposed = false;
  String? startedToken;

  @override
  Stream<bool> get connectionState => stateController.stream;

  @override
  Stream<MessagingRealtimeHint> get hints => hintController.stream;

  @override
  Future<void> start(String accessToken) async {
    startedToken = accessToken;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await hintController.close();
    await stateController.close();
  }
}

ConversationSummary conversationSummary({
  String conversationId = 'conversation-1',
  String appointmentId = 'appointment-1',
  String status = 'ACCEPTED',
  bool writable = true,
  int unreadCount = 0,
  DateTime? lastActivityAt,
  ConversationLastMessage? lastMessage,
}) {
  return ConversationSummary(
    conversationId: conversationId,
    appointmentId: appointmentId,
    appointmentStatus: status,
    requestedStartAt: DateTime.utc(2026, 7, 27, 10),
    durationMinutes: 30,
    writable: writable,
    writableUntil: DateTime.utc(2026, 7, 28, 10, 30),
    counterpart: const MessagingParticipant(
      userId: 'professional-user',
      displayName: 'Dr. Ada Okafor',
      role: 'PROFESSIONAL',
    ),
    lastMessage: lastMessage,
    unreadCount: unreadCount,
    readThroughSequence: BigInt.zero,
    lastActivityAt: lastActivityAt ?? DateTime.utc(2026, 7, 26, 12),
    updatedAt: DateTime.utc(2026, 7, 26, 12),
  );
}

ConversationDetail conversationDetail({
  String status = 'ACCEPTED',
  bool writable = true,
  BigInt? professionalRead,
}) {
  return ConversationDetail(
    conversationId: 'conversation-1',
    appointmentId: 'appointment-1',
    appointmentStatus: status,
    patient: const MessagingParticipant(
      userId: 'patient-user',
      displayName: 'Amaka Patient',
      role: 'PATIENT',
    ),
    professional: const MessagingParticipant(
      userId: 'professional-user',
      displayName: 'Dr. Ada Okafor',
      role: 'PROFESSIONAL',
    ),
    writable: writable,
    writableUntil: DateTime.utc(2026, 7, 28, 10, 30),
    patientLastReadSequence: BigInt.zero,
    professionalLastReadSequence: professionalRead ?? BigInt.zero,
    lastMessageSequence: BigInt.one,
    lastActivityAt: DateTime.utc(2026, 7, 26, 12),
    serverTime: DateTime.utc(2026, 7, 26, 12),
  );
}

CareMessage careMessage({
  String id = 'message-1',
  String clientMessageId = 'client-1',
  String authorUserId = 'professional-user',
  String text = 'Please arrive a few minutes early.',
  BigInt? sequence,
  bool seenByOther = false,
}) {
  return CareMessage(
    id: id,
    conversationId: 'conversation-1',
    sequence: sequence ?? BigInt.one,
    clientMessageId: clientMessageId,
    authorUserId: authorUserId,
    text: text,
    createdAt: DateTime.utc(2026, 7, 26, 12),
    seenByOther: seenByOther,
  );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
