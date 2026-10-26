import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_t/core/config/messaging_realtime_config.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_client.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_session_provider.dart';
import 'package:app_t/features/Messaging/domain/entities/messaging_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  test('conversation contract parses decimal sequence and stable activity', () {
    final page = ConversationPage.fromJson(<String, dynamic>{
      'conversations': <Map<String, dynamic>>[
        <String, dynamic>{
          'conversationId': 'conversation-1',
          'appointmentId': 'appointment-1',
          'appointmentStatus': 'ACCEPTED',
          'requestedStartAt': '2026-07-27T10:00:00.000Z',
          'durationMinutes': 30,
          'writable': true,
          'writableUntil': '2026-07-28T10:30:00.000Z',
          'counterpart': <String, dynamic>{
            'userId': 'professional-user',
            'displayName': 'Dr. Ada Okafor',
            'role': 'PROFESSIONAL',
          },
          'lastMessage': <String, dynamic>{
            'messageId': 'message-1',
            'sequence': '9007199254740993',
            'authorUserId': 'professional-user',
            'createdAt': '2026-07-26T12:00:00.000Z',
            'preview': 'Appointment update',
          },
          'unreadCount': '2',
          'readThroughSequence': '0',
          'lastActivityAt': '2026-07-26T12:00:00.000Z',
          'updatedAt': '2026-07-26T12:05:00.000Z',
        },
      ],
      'pageInfo': <String, dynamic>{'hasMore': false, 'nextCursor': null},
      'serverTime': '2026-07-26T12:06:00.000Z',
    });

    expect(
      page.conversations.single.lastMessage?.sequence,
      BigInt.parse('9007199254740993'),
    );
    expect(
      page.conversations.single.lastActivityAt,
      DateTime.utc(2026, 7, 26, 12),
    );
    expect(page.conversations.single.unreadCount, 2);
  });

  test('empty backend conversation accepts a null last message sequence', () {
    final detail = ConversationDetail.fromJson(<String, dynamic>{
      'conversationId': 'conversation-1',
      'appointmentId': 'appointment-1',
      'appointmentStatus': 'ACCEPTED',
      'patient': <String, dynamic>{
        'userId': 'patient-user',
        'displayName': 'Patient',
        'role': 'PATIENT',
      },
      'professional': <String, dynamic>{
        'userId': 'professional-user',
        'displayName': 'Professional',
        'role': 'PROFESSIONAL',
      },
      'writable': true,
      'writableUntil': '2026-07-28T10:30:00.000Z',
      'patientLastReadSequence': '0',
      'professionalLastReadSequence': '0',
      'lastMessageSequence': null,
      'lastActivityAt': '2026-07-26T12:00:00.000Z',
      'serverTime': '2026-07-26T12:00:00.000Z',
    });

    expect(detail.lastMessageSequence, isNull);
  });

  test('malformed required authority fields fail closed', () {
    expect(
      () => ConversationPage.fromJson(<String, dynamic>{
        'conversations': <Map<String, dynamic>>[
          <String, dynamic>{'conversationId': 'conversation-1'},
        ],
        'pageInfo': <String, dynamic>{'hasMore': false},
        'serverTime': '2026-07-26T12:00:00.000Z',
      }),
      throwsFormatException,
    );
  });

  test(
    'socket uses explicit canonical staging endpoint without token',
    () async {
      final client = MessagingRealtimeClient(
        config: _config,
        sessions: _Sessions(),
      );

      expect(client.endpoint.toString(), _config.url);
      expect(client.endpoint?.query, isEmpty);
      await client.dispose();
    },
  );

  test(
    'missing explicit socket endpoint makes no connection attempt',
    () async {
      var attempts = 0;
      final client = MessagingRealtimeClient(
        config: const MessagingRealtimeConfig(environment: 'staging', url: ''),
        sessions: _Sessions(),
        channelFactory: (_) {
          attempts++;
          throw StateError('unexpected connection');
        },
      );
      await client.start(_identity);
      expect(client.endpoint, isNull);
      expect(attempts, 0);
      await client.dispose();
    },
  );

  test(
    'socket sends strict auth frame without resume or token in URL',
    () async {
      final channel = _FakeWebSocketChannel();
      Uri? capturedUri;
      final client = MessagingRealtimeClient(
        config: _config,
        sessions: _Sessions(),
        channelFactory: (uri) {
          capturedUri = uri;
          return channel;
        },
      );

      await client.start(_identity);
      await Future<void>.delayed(Duration.zero);

      expect(capturedUri.toString(), _config.url);
      expect(capturedUri?.query, isEmpty);
      final frame =
          jsonDecode(channel.sent.single as String) as Map<String, dynamic>;
      expect(frame, <String, dynamic>{
        'type': 'auth',
        'accessToken': 'secret-access-token',
        'protocolVersion': 1,
      });
      expect(frame.containsKey('resume'), isFalse);
      await client.dispose();
    },
  );

  test('malformed and unknown-version hints are ignored safely', () async {
    final channel = _FakeWebSocketChannel();
    final client = MessagingRealtimeClient(
      config: _config,
      sessions: _Sessions(),
      channelFactory: (_) => channel,
    );
    final hints = <MessagingRealtimeHint>[];
    final subscription = client.hints.listen(hints.add);
    await client.start(_identity);

    channel.addIncoming(
      jsonEncode({'protocolVersion': 1, 'eventType': 'auth.accepted'}),
    );
    await Future<void>.delayed(Duration.zero);

    channel.addIncoming('not-json');
    channel.addIncoming(
      jsonEncode(<String, dynamic>{
        'protocolVersion': 2,
        'eventType': 'message.created',
        'conversationId': 'conversation-1',
      }),
    );
    channel.addIncoming(
      jsonEncode(<String, dynamic>{
        'protocolVersion': 1,
        'eventType': 'message.created',
        'conversationId': 'conversation-1',
        'sequence': '9007199254740993',
      }),
    );
    await Future<void>.delayed(Duration.zero);

    expect(hints, hasLength(1));
    expect(hints.single.sequence, BigInt.parse('9007199254740993'));
    await subscription.cancel();
    await client.dispose();
  });

  test('reconnect remains serialized and stops after disposal', () async {
    final channels = <_FakeWebSocketChannel>[];
    final client = MessagingRealtimeClient(
      config: _config,
      sessions: _Sessions(),
      initialReconnectDelay: const Duration(milliseconds: 2),
      maximumReconnectDelay: const Duration(milliseconds: 4),
      random: Random(1),
      channelFactory: (_) {
        final channel = _FakeWebSocketChannel();
        channels.add(channel);
        return channel;
      },
    );
    await client.start(_identity);
    expect(channels, hasLength(1));

    await channels.single.closeIncoming();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(channels, hasLength(2));
    await client.dispose();
    final countAfterDispose = channels.length;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(channels, hasLength(countAfterDispose));
  });

  test('failed pre-auth connection is closed before retry', () async {
    final ready = Completer<void>();
    final failed = _FakeWebSocketChannel(ready: ready.future);
    final client = MessagingRealtimeClient(
      config: _config,
      sessions: _Sessions(),
      initialReconnectDelay: const Duration(seconds: 1),
      channelFactory: (_) => failed,
    );

    final starting = client.start(_identity);
    await Future<void>.delayed(Duration.zero);
    ready.completeError(StateError('connection failed'));
    await starting;

    await expectLater(failed.sink.done, completes);
    await client.dispose();
  });
}

const _config = MessagingRealtimeConfig(
  environment: 'staging',
  url: 'wss://carenet-messaging-staging-tkgduhftha-el.a.run.app/messaging',
);
const _identity = MessagingRealtimeIdentity(
  userId: 'patient',
  generation: 'generation-1',
  role: 'PATIENT',
);

class _Sessions implements MessagingRealtimeSessionProvider {
  @override
  Future<MessagingRealtimeCredentials?> read() async =>
      const MessagingRealtimeCredentials(
        identity: _identity,
        accessToken: 'secret-access-token',
      );
  @override
  Future<MessagingRealtimeCredentials?> refresh(
    MessagingRealtimeCredentials expected,
  ) async => read();
}

class _FakeWebSocketChannel implements WebSocketChannel {
  _FakeWebSocketChannel({Future<void>? ready})
    : _ready = ready ?? Future<void>.value();

  final Future<void> _ready;
  final StreamController<dynamic> _incoming = StreamController<dynamic>();
  final List<dynamic> sent = <dynamic>[];
  late final WebSocketSink _sink = _FakeWebSocketSink(sent);

  void addIncoming(Object value) => _incoming.add(value);

  Future<void> closeIncoming() => _incoming.close();

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  String? get protocol => null;

  @override
  Future<void> get ready => _ready;

  @override
  WebSocketSink get sink => _sink;

  @override
  Stream<dynamic> get stream => _incoming.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWebSocketSink implements WebSocketSink {
  _FakeWebSocketSink(this.sent);

  final List<dynamic> sent;
  final Completer<void> _done = Completer<void>();

  @override
  void add(Object? data) => sent.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream stream) async {
    await for (final value in stream) {
      sent.add(value);
    }
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    if (!_done.isCompleted) {
      _done.complete();
    }
  }

  @override
  Future<void> get done => _done.future;
}
