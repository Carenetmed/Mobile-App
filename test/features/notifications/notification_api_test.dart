import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Notifications/data/services/notification_api_client.dart';
import 'package:app_t/features/Notifications/domain/entities/notification_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('inbox API uses bearer ownership and parses the bounded page', () async {
    final adapter = _NotificationAdapter((options) {
      expect(options.path, 'https://api.carenet.test/notifications');
      expect(options.queryParameters, <String, dynamic>{
        'limit': 10,
        'category': 'APPOINTMENTS',
        'read': 'unread',
      });
      return _response(<String, dynamic>{
        'items': [_notificationJson()],
        'pageInfo': <String, dynamic>{
          'hasMore': true,
          'nextCursor': 'opaque-cursor',
        },
      });
    });
    final client = _client(adapter);

    final page = await client.notifications(
      accessToken: 'owner-token',
      category: NotificationCategory.appointments,
      read: 'unread',
      limit: 10,
    );

    expect(adapter.last?.headers['Authorization'], 'Bearer owner-token');
    expect(adapter.last?.headers.containsKey('Cookie'), isFalse);
    expect(page.items.single.entityId, 'appointment-1');
    expect(page.nextCursor, 'opaque-cursor');
    expect(page.hasMore, isTrue);
  });

  test(
    'installation registration sends the opaque FCM endpoint only in body',
    () async {
      final adapter = _NotificationAdapter((options) {
        expect(
          options.path,
          'https://api.carenet.test/notification-installations',
        );
        expect(options.method, 'POST');
        expect(options.data, containsPair('endpoint', 'opaque-fcm-token'));
        expect(options.headers.toString(), isNot(contains('opaque-fcm-token')));
        return _response(<String, dynamic>{'id': 'installation-row'});
      });
      final client = _client(adapter);

      await client.registerInstallation(
        accessToken: 'owner-token',
        payload: <String, dynamic>{
          'installationId': 'installation-000000000000000000000001',
          'platform': 'ANDROID',
          'endpoint': 'opaque-fcm-token',
          'endpointKind': 'FCM_REGISTRATION_TOKEN',
          'appId': 'com.carenet.app',
          'permissionState': 'AUTHORIZED',
        },
      );

      expect(adapter.calls, 1);
    },
  );

  test('preference API preserves every explicit category choice', () async {
    final values = NotificationCategory.values
        .map(
          (category) => <String, dynamic>{
            'category': category.wireName,
            'pushEnabled': category != NotificationCategory.messages,
            'emailEnabled': true,
          },
        )
        .toList(growable: false);
    final adapter = _NotificationAdapter((options) {
      expect(options.method, 'PATCH');
      expect(options.data, <String, dynamic>{'preferences': values});
      return _response(<String, dynamic>{'preferences': values});
    });

    final result = await _client(adapter).updatePreferences(
      accessToken: 'owner-token',
      preferences: values
          .map(NotificationPreference.fromJson)
          .toList(growable: false),
    );

    expect(result, hasLength(NotificationCategory.values.length));
    expect(
      result
          .firstWhere((item) => item.category == NotificationCategory.messages)
          .pushEnabled,
      isFalse,
    );
  });

  test('owner-scoped not found maps to a safe unavailable failure', () async {
    final adapter = _NotificationAdapter(
      (_) => _response(<String, dynamic>{'message': 'Not found'}, status: 404),
    );

    await expectLater(
      () => _client(adapter).notification(
        accessToken: 'owner-token',
        notificationId: 'another-users-notification',
      ),
      throwsA(
        isA<AuthFailure>()
            .having((failure) => failure.statusCode, 'status', 404)
            .having(
              (failure) => failure.message,
              'message',
              'This notification is no longer available.',
            ),
      ),
    );
  });

  test('unknown categories and malformed timestamps fail closed', () {
    expect(
      () => CareNotification.fromJson(
        _notificationJson()..['category'] = 'UNRECOGNIZED',
      ),
      throwsFormatException,
    );
    expect(
      () => CareNotification.fromJson(
        _notificationJson()..['latestOccurredAt'] = 'not-a-date',
      ),
      throwsFormatException,
    );
  });
}

NotificationApiClient _client(HttpClientAdapter adapter) {
  return NotificationApiClient(
    config: const CareNetApiConfig(baseUrl: 'https://api.carenet.test'),
    dio: Dio()..httpClientAdapter = adapter,
  );
}

Map<String, dynamic> _notificationJson() => <String, dynamic>{
  'id': 'notification-1',
  'category': 'APPOINTMENTS',
  'priority': 'NORMAL',
  'title': 'Appointment update',
  'body': 'Open CareNet to view the latest appointment status.',
  'routeCode': 'APPOINTMENT_DETAIL',
  'entityId': 'appointment-1',
  'occurrenceCount': 1,
  'firstOccurredAt': '2026-08-02T08:00:00.000Z',
  'latestOccurredAt': '2026-08-02T08:00:00.000Z',
  'readAt': null,
};

ResponseBody _response(Map<String, dynamic> json, {int status = 200}) {
  return ResponseBody.fromString(
    jsonEncode(json),
    status,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

class _NotificationAdapter implements HttpClientAdapter {
  _NotificationAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  RequestOptions? last;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    last = options;
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
