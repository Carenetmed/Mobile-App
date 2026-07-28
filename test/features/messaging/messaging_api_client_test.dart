import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Messaging/data/services/messaging_api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('messaging API client uses the authoritative HTTP contract', () async {
    final adapter = _QueueAdapter(<Object>[
      <String, dynamic>{
        'conversations': <Object>[],
        'pageInfo': <String, dynamic>{'hasMore': false, 'nextCursor': null},
        'serverTime': '2026-07-26T12:00:00.000Z',
      },
      <String, dynamic>{
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
      },
      <String, dynamic>{
        'messages': <Object>[],
        'pageInfo': <String, dynamic>{
          'hasMoreBefore': false,
          'hasMoreAfter': false,
          'firstSequence': null,
          'lastSequence': null,
        },
      },
      <String, dynamic>{
        'id': 'message-2',
        'conversationId': 'conversation-1',
        'sequence': '2',
        'clientMessageId': '00000000-0000-4000-8000-000000000001',
        'authorUserId': 'patient-user',
        'text': 'Appointment message',
        'createdAt': '2026-07-26T12:01:00.000Z',
        'seenByOther': false,
      },
      <String, dynamic>{
        'conversationId': 'conversation-1',
        'throughSequence': '2',
        'advanced': true,
      },
    ]);
    final dio = Dio()..httpClientAdapter = adapter;
    final client = MessagingApiClient(
      config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
      dio: dio,
    );
    const token = 'private-access-token';

    await client.conversations(
      accessToken: token,
      cursor: 'opaque-cursor',
      limit: 30,
    );
    await client.conversation(
      accessToken: token,
      conversationId: 'conversation-1',
    );
    await client.messages(
      accessToken: token,
      conversationId: 'conversation-1',
      beforeSequence: BigInt.from(10),
      limit: 50,
    );
    await client.sendMessage(
      accessToken: token,
      conversationId: 'conversation-1',
      clientMessageId: '00000000-0000-4000-8000-000000000001',
      text: 'Appointment message',
    );
    await client.markRead(
      accessToken: token,
      conversationId: 'conversation-1',
      throughSequence: BigInt.two,
    );

    expect(adapter.requests.map((request) => request.path), <String>[
      'https://api.example.test/conversations',
      'https://api.example.test/conversations/conversation-1',
      'https://api.example.test/conversations/conversation-1/messages',
      'https://api.example.test/conversations/conversation-1/messages',
      'https://api.example.test/conversations/conversation-1/read',
    ]);
    for (final request in adapter.requests) {
      expect(request.headers['Authorization'], 'Bearer $token');
    }
    expect(adapter.requests[0].queryParameters, <String, dynamic>{
      'limit': 30,
      'cursor': 'opaque-cursor',
    });
    expect(adapter.requests[2].queryParameters, <String, dynamic>{
      'limit': 50,
      'beforeSequence': '10',
    });
    expect(adapter.requests[3].data, <String, dynamic>{
      'clientMessageId': '00000000-0000-4000-8000-000000000001',
      'text': 'Appointment message',
    });
    expect(adapter.requests[4].data, <String, dynamic>{'throughSequence': '2'});
  });
}

class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this.responses);

  final List<Object> responses;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(responses.removeAt(0)),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
