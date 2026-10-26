import 'dart:async';
import 'dart:math';

import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';

import '../../data/repositories/messaging_repository.dart';
import '../../data/services/messaging_realtime_client.dart';
import '../../domain/entities/messaging_models.dart';

String safeMessagingFailure(Object error) {
  if (error is! AuthFailure) {
    return 'Messaging is unavailable. Please try again.';
  }
  return switch (error.statusCode) {
    401 => 'Your session has expired. Please sign in again.',
    403 => 'This account cannot access that conversation.',
    404 => 'This conversation is no longer available.',
    409 => 'The conversation changed. Refresh and try again.',
    _ => switch (error.type) {
      AuthFailureType.missingConfiguration =>
        'Messaging is not configured yet.',
      AuthFailureType.network =>
        'Network error. Your previous messages remain available.',
      AuthFailureType.server => 'Messaging is temporarily unavailable.',
      _ => 'Messaging is unavailable. Please try again.',
    },
  };
}

class ConversationListController extends ChangeNotifier {
  ConversationListController({required MessagingRepository repository})
    : _repository = repository;

  final MessagingRepository _repository;
  List<ConversationSummary> conversations = const <ConversationSummary>[];
  bool isLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  String? errorMessage;
  bool hasMore = false;
  String? _nextCursor;
  String? _userId;
  Future<void>? _activeLoad;
  Future<void>? _activePage;
  bool _refreshQueued = false;
  int _generation = 0;
  bool _disposed = false;

  Future<void> load({bool refresh = false}) {
    if (_disposed) return Future<void>.value();
    final active = _activeLoad;
    if (active != null) {
      if (refresh) _refreshQueued = true;
      return active;
    }
    final completion = Completer<void>();
    _activeLoad = completion.future;
    unawaited(_drainLoads(refresh, completion));
    return completion.future;
  }

  Future<void> _drainLoads(bool refresh, Completer<void> completion) async {
    try {
      do {
        _refreshQueued = false;
        await _load(refresh: refresh);
        refresh = true;
      } while (!_disposed && _refreshQueued);
      completion.complete();
    } catch (error, stack) {
      completion.completeError(error, stack);
    } finally {
      if (identical(_activeLoad, completion.future)) _activeLoad = null;
    }
  }

  Future<void> _load({required bool refresh}) async {
    final generation = ++_generation;
    final hadData = conversations.isNotEmpty;
    isLoading = !hadData;
    isRefreshing = hadData;
    errorMessage = null;
    _notify();
    try {
      final session = await _repository.requireSession();
      if (_userId != null && _userId != session.userId) {
        conversations = const <ConversationSummary>[];
        _nextCursor = null;
        hasMore = false;
      }
      final page = await _repository.conversations();
      if (!_accept(generation)) {
        return;
      }
      _userId = session.userId;
      conversations = List<ConversationSummary>.unmodifiable(
        _orderedUnique(page.conversations),
      );
      _nextCursor = page.nextCursor;
      hasMore = page.hasMore && page.nextCursor != null;
    } catch (error) {
      if (_accept(generation)) {
        errorMessage = safeMessagingFailure(error);
      }
    } finally {
      if (_accept(generation)) {
        isLoading = false;
        isRefreshing = false;
        _notify();
      }
    }
  }

  Future<void> loadMore() {
    final active = _activePage;
    if (active != null) {
      return active;
    }
    if (!hasMore || _nextCursor == null) {
      return Future<void>.value();
    }
    final future = _loadMore();
    _activePage = future;
    return future.whenComplete(() {
      if (identical(_activePage, future)) {
        _activePage = null;
      }
    });
  }

  Future<void> _loadMore() async {
    final cursor = _nextCursor;
    if (cursor == null) {
      return;
    }
    isLoadingMore = true;
    errorMessage = null;
    _notify();
    try {
      final page = await _repository.conversations(cursor: cursor);
      if (_disposed || cursor != _nextCursor) {
        return;
      }
      conversations = List<ConversationSummary>.unmodifiable(
        _orderedUnique(<ConversationSummary>[
          ...conversations,
          ...page.conversations,
        ]),
      );
      _nextCursor = page.nextCursor;
      hasMore = page.hasMore && page.nextCursor != null;
    } catch (error) {
      if (!_disposed) {
        errorMessage = safeMessagingFailure(error);
      }
    } finally {
      if (!_disposed) {
        isLoadingMore = false;
        _notify();
      }
    }
  }

  List<ConversationSummary> _orderedUnique(
    Iterable<ConversationSummary> values,
  ) {
    final byId = <String, ConversationSummary>{};
    for (final value in values) {
      byId[value.conversationId] = value;
    }
    final result = byId.values.toList();
    result.sort((a, b) {
      final byActivity = b.lastActivityAt.compareTo(a.lastActivityAt);
      return byActivity != 0
          ? byActivity
          : a.conversationId.compareTo(b.conversationId);
    });
    return result;
  }

  bool _accept(int generation) => !_disposed && generation == _generation;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _refreshQueued = false;
    _generation++;
    conversations = const <ConversationSummary>[];
    super.dispose();
  }
}

class AppointmentConversationRouteArgs {
  const AppointmentConversationRouteArgs({
    this.conversationId,
    this.appointmentId,
  }) : assert(conversationId != null || appointmentId != null);

  final String? conversationId;
  final String? appointmentId;
}

class PendingCareMessage {
  const PendingCareMessage({
    required this.clientMessageId,
    required this.text,
    required this.createdAt,
    required this.retryable,
  });

  final String clientMessageId;
  final String text;
  final DateTime createdAt;
  final bool retryable;

  PendingCareMessage copyWith({bool? retryable}) {
    return PendingCareMessage(
      clientMessageId: clientMessageId,
      text: text,
      createdAt: createdAt,
      retryable: retryable ?? this.retryable,
    );
  }
}

class AppointmentChatController extends ChangeNotifier {
  AppointmentChatController({
    required MessagingRepository repository,
    required MessagingRealtimeConnection realtime,
    this.conversationId,
    this.appointmentId,
    DateTime Function()? now,
    String Function()? idFactory,
    Duration disconnectedPollInterval = const Duration(seconds: 15),
  }) : _repository = repository,
       _realtime = realtime,
       _now = now ?? DateTime.now,
       _idFactory = idFactory ?? _secureUuid,
       _pollInterval = disconnectedPollInterval;

  final MessagingRepository _repository;
  final MessagingRealtimeConnection _realtime;
  final String? conversationId;
  final String? appointmentId;
  final DateTime Function() _now;
  final String Function() _idFactory;
  final Duration _pollInterval;
  final InMemoryChatController flyerController = InMemoryChatController();

  ConversationSummary? summary;
  ConversationDetail? detail;
  String? currentUserId;
  String? errorMessage;
  bool isLoading = false;
  bool isRefreshing = false;
  bool isLoadingOlder = false;
  bool isSending = false;
  bool realtimeConnected = false;
  bool _backgrounded = false;
  bool hasMoreBefore = false;
  List<PendingCareMessage> pendingMessages = const <PendingCareMessage>[];

  final Map<BigInt, CareMessage> _committed = <BigInt, CareMessage>{};
  BigInt _lastMarkedRead = BigInt.zero;
  StreamSubscription<MessagingRealtimeHint>? _hintSubscription;
  StreamSubscription<bool>? _stateSubscription;
  Timer? _pollTimer;
  Future<void>? _activeLoad;
  Future<void>? _activeOlder;
  Future<void>? _activeCatchUp;
  Future<void>? _activeSend;
  int _generation = 0;
  bool _disposed = false;

  bool get writable => detail?.writable == true;

  String get readOnlyReason {
    final status = detail?.appointmentStatus.toUpperCase();
    return switch (status) {
      'REQUESTED' =>
        'Messaging is paused until the appointment is accepted again.',
      'CANCELLED' =>
        'This appointment was cancelled. The conversation is read-only.',
      'COMPLETED' when !writable =>
        'The consultation messaging window has closed.',
      _ => 'This conversation is read-only.',
    };
  }

  MessagingParticipant? get counterpart {
    final current = currentUserId;
    final value = detail;
    if (current == null || value == null) {
      return summary?.counterpart;
    }
    return value.patient.userId == current ? value.professional : value.patient;
  }

  Future<void> load() {
    final active = _activeLoad;
    if (active != null) {
      return active;
    }
    final future = _load();
    _activeLoad = future;
    return future.whenComplete(() {
      if (identical(_activeLoad, future)) {
        _activeLoad = null;
      }
    });
  }

  Future<void> _load() async {
    final generation = ++_generation;
    final hadData = detail != null;
    isLoading = !hadData;
    isRefreshing = hadData;
    errorMessage = null;
    _notify();
    try {
      final session = await _repository.requireSession();
      if (currentUserId != null && currentUserId != session.userId) {
        await _clearPrivateState();
      }
      currentUserId = session.userId;
      final resolved = await _resolveConversation();
      if (resolved == null) {
        throw const AuthFailure(
          type: AuthFailureType.validation,
          message: 'No conversation exists for this appointment.',
          statusCode: 404,
        );
      }
      final results = await Future.wait<Object>(<Future<Object>>[
        _repository.conversation(resolved.conversationId),
        _repository.messages(conversationId: resolved.conversationId),
      ]);
      if (!_accept(generation)) {
        return;
      }
      final loadedDetail = results[0] as ConversationDetail;
      if (!_isCurrentParticipant(loadedDetail, session.userId)) {
        throw const AuthFailure(
          type: AuthFailureType.validation,
          message: 'This account cannot access that conversation.',
          statusCode: 403,
        );
      }
      summary = resolved;
      detail = loadedDetail;
      _mergePage(results[1] as MessagePage, replace: true);
      await _syncFlyer();
      final realtimeIdentity = session.realtimeIdentity;
      if (realtimeIdentity != null) {
        await _startRealtime(realtimeIdentity);
      } else {
        _startPolling();
      }
    } catch (error) {
      if (_accept(generation)) {
        errorMessage = safeMessagingFailure(error);
      }
    } finally {
      if (_accept(generation)) {
        isLoading = false;
        isRefreshing = false;
        _notify();
      }
    }
  }

  Future<ConversationSummary?> _resolveConversation() async {
    final direct = conversationId?.trim();
    if (direct != null && direct.isNotEmpty) {
      final page = await _repository.conversations(limit: 50);
      for (final item in page.conversations) {
        if (item.conversationId == direct) {
          return item;
        }
      }
      String? cursor = page.hasMore ? page.nextCursor : null;
      while (cursor != null) {
        final next = await _repository.conversations(cursor: cursor, limit: 50);
        for (final item in next.conversations) {
          if (item.conversationId == direct) {
            return item;
          }
        }
        cursor = next.hasMore ? next.nextCursor : null;
      }
      return null;
    }
    final appointment = appointmentId?.trim();
    return appointment == null || appointment.isEmpty
        ? null
        : _repository.conversationForAppointment(appointment);
  }

  bool _isCurrentParticipant(ConversationDetail value, String userId) {
    return value.patient.userId == userId ||
        value.professional.userId == userId;
  }

  Future<void> loadOlder() {
    final active = _activeOlder;
    if (active != null) {
      return active;
    }
    if (!hasMoreBefore || _committed.isEmpty || summary == null) {
      return Future<void>.value();
    }
    final future = _loadOlder();
    _activeOlder = future;
    return future.whenComplete(() {
      if (identical(_activeOlder, future)) {
        _activeOlder = null;
      }
    });
  }

  Future<void> _loadOlder() async {
    isLoadingOlder = true;
    _notify();
    try {
      if (!await _identityStillCurrent()) {
        return;
      }
      final page = await _repository.messages(
        conversationId: summary!.conversationId,
        beforeSequence: _committed.keys.reduce(minBigInt),
      );
      if (_disposed) {
        return;
      }
      _mergePage(page, updateHasMoreBefore: true);
      await _syncFlyer();
    } catch (error) {
      if (!_disposed) {
        errorMessage = safeMessagingFailure(error);
      }
    } finally {
      if (!_disposed) {
        isLoadingOlder = false;
        _notify();
      }
    }
  }

  Future<void> catchUp() {
    final active = _activeCatchUp;
    if (active != null) {
      return active;
    }
    final value = summary;
    if (value == null) {
      return Future<void>.value();
    }
    final future = _catchUp(value.conversationId);
    _activeCatchUp = future;
    return future.whenComplete(() {
      if (identical(_activeCatchUp, future)) {
        _activeCatchUp = null;
      }
    });
  }

  Future<void> _catchUp(String id) async {
    try {
      if (!await _identityStillCurrent()) {
        return;
      }
      final last =
          _committed.isEmpty ? null : _committed.keys.reduce(maxBigInt);
      final results = await Future.wait<Object>(<Future<Object>>[
        _repository.conversation(id),
        _repository.messages(conversationId: id, afterSequence: last),
      ]);
      if (_disposed || summary?.conversationId != id) {
        return;
      }
      detail = results[0] as ConversationDetail;
      _mergePage(results[1] as MessagePage);
      await _syncFlyer();
      _notify();
    } catch (error) {
      if (!_disposed) {
        errorMessage = safeMessagingFailure(error);
        _notify();
      }
    }
  }

  Future<void> send(String text) {
    final normalized = text.trim();
    if (!writable ||
        normalized.isEmpty ||
        normalized.runes.length > 4000 ||
        _activeSend != null) {
      if (normalized.runes.length > 4000) {
        errorMessage = 'Messages can contain at most 4,000 characters.';
        _notify();
      }
      return _activeSend ?? Future<void>.value();
    }
    final pending = PendingCareMessage(
      clientMessageId: _idFactory(),
      text: normalized,
      createdAt: _now().toUtc(),
      retryable: false,
    );
    pendingMessages = List<PendingCareMessage>.unmodifiable(
      <PendingCareMessage>[...pendingMessages, pending],
    );
    final future = _submit(pending);
    _activeSend = future;
    return future.whenComplete(() {
      if (identical(_activeSend, future)) {
        _activeSend = null;
      }
    });
  }

  Future<void> retry(String clientMessageId) {
    final pending =
        pendingMessages
            .where((item) => item.clientMessageId == clientMessageId)
            .firstOrNull;
    if (pending == null || !pending.retryable || _activeSend != null) {
      return _activeSend ?? Future<void>.value();
    }
    final retrying = pending.copyWith(retryable: false);
    pendingMessages = List<PendingCareMessage>.unmodifiable(
      pendingMessages
          .map(
            (item) => item.clientMessageId == clientMessageId ? retrying : item,
          )
          .toList(),
    );
    final future = _submit(retrying);
    _activeSend = future;
    return future.whenComplete(() {
      if (identical(_activeSend, future)) {
        _activeSend = null;
      }
    });
  }

  Future<void> _submit(PendingCareMessage pending) async {
    isSending = true;
    errorMessage = null;
    await _syncFlyer();
    _notify();
    try {
      if (!await _identityStillCurrent()) {
        return;
      }
      final committed = await _repository.sendMessage(
        conversationId: summary!.conversationId,
        clientMessageId: pending.clientMessageId,
        text: pending.text,
      );
      if (_disposed) {
        return;
      }
      _committed[committed.sequence] = committed;
      pendingMessages = List<PendingCareMessage>.unmodifiable(
        pendingMessages
            .where((item) => item.clientMessageId != pending.clientMessageId)
            .toList(),
      );
      await _syncFlyer();
      await catchUp();
    } catch (error) {
      if (!_disposed) {
        pendingMessages = List<PendingCareMessage>.unmodifiable(
          pendingMessages
              .map(
                (item) =>
                    item.clientMessageId == pending.clientMessageId
                        ? item.copyWith(retryable: true)
                        : item,
              )
              .toList(),
        );
        errorMessage =
            'The send result is uncertain. Retry will use the same message ID.';
        await _syncFlyer();
      }
    } finally {
      if (!_disposed) {
        isSending = false;
        _notify();
      }
    }
  }

  void _mergePage(
    MessagePage page, {
    bool replace = false,
    bool updateHasMoreBefore = false,
  }) {
    if (replace) {
      _committed.clear();
    }
    for (final message in page.messages) {
      final duplicateClientId =
          _committed.values
              .where(
                (current) =>
                    current.clientMessageId == message.clientMessageId &&
                    current.authorUserId == message.authorUserId,
              )
              .toList();
      if (duplicateClientId.any(
        (current) => current.sequence >= message.sequence,
      )) {
        continue;
      }
      for (final duplicate in duplicateClientId) {
        _committed.remove(duplicate.sequence);
      }
      _committed[message.sequence] = message;
      pendingMessages = List<PendingCareMessage>.unmodifiable(
        pendingMessages
            .where(
              (pending) => pending.clientMessageId != message.clientMessageId,
            )
            .toList(),
      );
    }
    if (replace || updateHasMoreBefore) {
      hasMoreBefore = page.hasMoreBefore;
    }
  }

  Future<void> _syncFlyer() async {
    final current = currentUserId;
    if (current == null || _disposed) {
      return;
    }
    final committed =
        _committed.values.toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final projected = <Message>[
      ...committed.map(
        (message) => Message.text(
          id: message.id,
          authorId: message.authorUserId,
          text: message.text,
          createdAt: message.createdAt,
          sentAt: message.createdAt,
          status:
              message.authorUserId == current && message.seenByOther
                  ? MessageStatus.seen
                  : MessageStatus.sent,
          metadata: <String, dynamic>{
            'sequence': message.sequence.toString(),
            'clientMessageId': message.clientMessageId,
          },
        ),
      ),
      ...pendingMessages.map(
        (pending) => Message.text(
          id: 'pending:${pending.clientMessageId}',
          authorId: current,
          text: pending.text,
          createdAt: pending.createdAt,
          status:
              pending.retryable ? MessageStatus.error : MessageStatus.sending,
          metadata: <String, dynamic>{
            'clientMessageId': pending.clientMessageId,
            'retryable': pending.retryable,
          },
        ),
      ),
    ];
    projected.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.compareTo(bTime);
    });
    await flyerController.setMessages(projected, animated: false);
  }

  Future<void> markVisibleRead() async {
    if (_committed.isEmpty || summary == null || _disposed) {
      return;
    }
    final through = _committed.keys.reduce(maxBigInt);
    if (through <= _lastMarkedRead || !await _identityStillCurrent()) {
      return;
    }
    try {
      await _repository.markRead(
        conversationId: summary!.conversationId,
        throughSequence: through,
      );
      _lastMarkedRead = through;
    } catch (_) {
      // Message visibility remains valid; the next catch-up retries read state.
    }
  }

  Future<bool> _identityStillCurrent() async {
    try {
      final session = await _repository.requireSession();
      if (_disposed) {
        return false;
      }
      if (currentUserId == null || currentUserId == session.userId) {
        return true;
      }
      await _clearPrivateState();
      currentUserId = session.userId;
      errorMessage =
          'The signed-in account changed. Reopen the conversation for this account.';
      _notify();
      return false;
    } catch (_) {
      if (!_disposed) {
        await _clearPrivateState();
        currentUserId = null;
        errorMessage = 'Your session has ended. Sign in to view messages.';
        _notify();
      }
      return false;
    }
  }

  Future<void> _startRealtime(MessagingRealtimeIdentity identity) async {
    if (_hintSubscription != null || _disposed) {
      return;
    }
    _hintSubscription = _realtime.hints.listen((hint) {
      if (!_disposed &&
          !_backgrounded &&
          hint.conversationId == summary?.conversationId) {
        catchUp();
      }
    });
    _stateSubscription = _realtime.connectionState.listen((connected) {
      if (_disposed) {
        return;
      }
      realtimeConnected = connected && !_backgrounded;
      if (realtimeConnected) {
        _pollTimer?.cancel();
        _pollTimer = null;
        catchUp();
      } else {
        _startPolling();
      }
      _notify();
    });
    if (_backgrounded) {
      await _realtime.suspend();
    }
    if (_disposed) return;
    unawaited(_realtime.start(identity));
    _startPolling();
  }

  void _startPolling() {
    if (_disposed || _backgrounded || _pollTimer != null || realtimeConnected) {
      return;
    }
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!_disposed && !_backgrounded && !realtimeConnected) {
        catchUp();
      }
    });
  }

  Future<void> onAppResumed() async {
    if (_disposed) return;
    _backgrounded = false;
    await catchUp();
    if (_disposed || _backgrounded) return;
    await _realtime.resume();
    _startPolling();
  }

  Future<void> onAppPaused() async {
    if (_disposed) return;
    _backgrounded = true;
    _pollTimer?.cancel();
    _pollTimer = null;
    realtimeConnected = false;
    _notify();
    await _realtime.suspend();
  }

  bool _accept(int generation) => !_disposed && generation == _generation;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> _clearPrivateState() async {
    _committed.clear();
    _lastMarkedRead = BigInt.zero;
    pendingMessages = const <PendingCareMessage>[];
    summary = null;
    detail = null;
    await flyerController.setMessages(const <Message>[], animated: false);
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _pollTimer?.cancel();
    _hintSubscription?.cancel();
    _stateSubscription?.cancel();
    _realtime.dispose();
    _committed.clear();
    pendingMessages = const <PendingCareMessage>[];
    flyerController.dispose();
    super.dispose();
  }
}

BigInt minBigInt(BigInt a, BigInt b) => a < b ? a : b;
BigInt maxBigInt(BigInt a, BigInt b) => a > b ? a : b;

String _secureUuid() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex =
      bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
