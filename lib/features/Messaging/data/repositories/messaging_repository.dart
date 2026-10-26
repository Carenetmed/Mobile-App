import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';

import '../../domain/entities/messaging_models.dart';
import '../../domain/entities/messaging_realtime_session.dart';
import '../services/messaging_api_client.dart';

class MessagingRepository {
  const MessagingRepository({
    required MessagingApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final MessagingApiClient _apiClient;
  final SessionStore _sessionStore;

  Future<MessagingSession> requireSession() async {
    final snapshot = await _sessionStore.capture();
    if (snapshot == null || snapshot.session.user.id.trim().isEmpty) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }
    return MessagingSession(snapshot.session, generation: snapshot.generation);
  }

  Future<ConversationPage> conversations({
    String? cursor,
    int limit = 30,
  }) async {
    final session = await requireSession();
    return _apiClient.conversations(
      accessToken: session.accessToken,
      cursor: cursor,
      limit: limit,
    );
  }

  Future<ConversationDetail> conversation(String conversationId) async {
    final session = await requireSession();
    return _apiClient.conversation(
      accessToken: session.accessToken,
      conversationId: conversationId,
    );
  }

  Future<MessagePage> messages({
    required String conversationId,
    BigInt? beforeSequence,
    BigInt? afterSequence,
    int limit = 50,
  }) async {
    final session = await requireSession();
    return _apiClient.messages(
      accessToken: session.accessToken,
      conversationId: conversationId,
      beforeSequence: beforeSequence,
      afterSequence: afterSequence,
      limit: limit,
    );
  }

  Future<CareMessage> sendMessage({
    required String conversationId,
    required String clientMessageId,
    required String text,
  }) async {
    final session = await requireSession();
    return _apiClient.sendMessage(
      accessToken: session.accessToken,
      conversationId: conversationId,
      clientMessageId: clientMessageId,
      text: text,
    );
  }

  Future<void> markRead({
    required String conversationId,
    required BigInt throughSequence,
  }) async {
    final session = await requireSession();
    await _apiClient.markRead(
      accessToken: session.accessToken,
      conversationId: conversationId,
      throughSequence: throughSequence,
    );
  }

  Future<ConversationSummary?> conversationForAppointment(
    String appointmentId,
  ) async {
    String? cursor;
    do {
      final page = await conversations(cursor: cursor, limit: 50);
      for (final conversation in page.conversations) {
        if (conversation.appointmentId == appointmentId) {
          return conversation;
        }
      }
      cursor = page.hasMore ? page.nextCursor : null;
    } while (cursor != null);
    return null;
  }
}

class MessagingSession {
  const MessagingSession(this._session, {this.generation});

  final AuthSessionModel _session;
  final String? generation;

  MessagingRealtimeIdentity? get realtimeIdentity {
    final currentGeneration = generation;
    if (currentGeneration == null) return null;
    return MessagingRealtimeIdentity(
      userId: userId,
      generation: currentGeneration,
      role: role,
    );
  }

  String get userId => _session.user.id;
  String get role => _session.user.role;
  String get accessToken => _session.accessToken;
}
