import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/data/services/scheduling_api_client.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Scheduling repository boundary', () {
    test('public availability read sends no auth header', () async {
      final adapter = _FakeAdapter(
        responseJson: <String, dynamic>{
          'availabilityWindows': <Map<String, dynamic>>[
            _availabilityJson(id: 'availability-1'),
          ],
        },
      );
      final repository = _repository(adapter: adapter, withSession: false);

      final windows = await repository.publicAvailability(
        professionalProfileId: 'professional 1',
      );

      expect(windows, hasLength(1));
      expect(windows.single.id, 'availability-1');
      expect(adapter.lastOptions?.method, 'GET');
      expect(
        adapter.lastOptions?.uri.toString(),
        endsWith('/professionals/professional%201/availability'),
      );
      expect(
        adapter.lastOptions?.headers.containsKey('Authorization'),
        isFalse,
      );
      expect(adapter.lastOptions?.headers.containsKey('Cookie'), isFalse);
    });

    test(
      'public availability parses backend envelope with omitted active flag',
      () async {
        final adapter = _FakeAdapter(
          responseJson: <String, dynamic>{
            'professionalProfileId': 'professional-1',
            'availabilityWindows': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'availability-1',
                'weekday': 6,
                'startMinute': 540,
                'endMinute': 1020,
                'timezone': 'UTC',
              },
            ],
          },
        );
        final repository = _repository(adapter: adapter, withSession: false);

        final windows = await repository.publicAvailability(
          professionalProfileId: 'professional-1',
        );

        expect(windows, hasLength(1));
        expect(windows.single.id, 'availability-1');
        expect(windows.single.weekday, 6);
        expect(windows.single.active, isTrue);
      },
    );

    test('explicit inactive availability remains inactive', () async {
      final adapter = _FakeAdapter(
        responseJson: <String, dynamic>{
          'items': <Map<String, dynamic>>[
            _availabilityJson(id: 'availability-1', active: false),
          ],
        },
      );
      final repository = _repository(adapter: adapter, withSession: false);

      final windows = await repository.publicAvailability(
        professionalProfileId: 'professional-1',
      );

      expect(windows.single.active, isFalse);
    });

    test('own availability read sends bearer auth', () async {
      final adapter = _FakeAdapter(
        responseJson: <String, dynamic>{
          'items': <Map<String, dynamic>>[
            _availabilityJson(id: 'availability-1'),
          ],
        },
      );
      final repository = _repository(adapter: adapter, withSession: true);

      await repository.ownAvailability();

      expect(adapter.lastOptions?.method, 'GET');
      expect(adapter.lastOptions?.uri.toString(), endsWith('/availability/me'));
      expect(
        adapter.lastOptions?.headers['Authorization'],
        'Bearer access-token',
      );
      expect(adapter.lastOptions?.headers.containsKey('Cookie'), isFalse);
    });

    test('replace availability sends only allowed window fields', () async {
      final adapter = _FakeAdapter(
        responseJson: <String, dynamic>{
          'items': <Map<String, dynamic>>[
            _availabilityJson(id: 'availability-1'),
          ],
        },
      );
      final repository = _repository(adapter: adapter, withSession: true);

      await repository.replaceOwnAvailability(
        windows: const <AvailabilityWindowDraft>[
          AvailabilityWindowDraft(
            weekday: 1,
            startMinute: 540,
            endMinute: 1020,
            timezone: 'Africa/Lagos',
            active: true,
          ),
        ],
      );

      expect(adapter.lastOptions?.method, 'PUT');
      expect(adapter.lastOptions?.uri.toString(), endsWith('/availability/me'));
      expect(adapter.lastOptions?.data, <String, dynamic>{
        'windows': <Map<String, dynamic>>[
          <String, dynamic>{
            'weekday': 1,
            'startMinute': 540,
            'endMinute': 1020,
            'timezone': 'Africa/Lagos',
            'active': true,
          },
        ],
      });
      final payload = adapter.lastOptions?.data as Map<String, dynamic>;
      expect(payload.containsKey('professionalProfileId'), isFalse);
      expect(payload.containsKey('userId'), isFalse);
      expect(payload.containsKey('verificationStatus'), isFalse);
    });

    test('appointment request sends only backend-accepted fields', () async {
      final adapter = _FakeAdapter(
        responseJson: _appointmentJson(status: 'REQUESTED'),
      );
      final repository = _repository(adapter: adapter, withSession: true);

      final appointment = await repository.requestAppointment(
        professionalProfileId: 'professional-1',
        requestedStartAt: DateTime.parse('2026-07-14T10:30:00+01:00'),
        durationMinutes: 30,
      );

      expect(appointment.status, AppointmentStatus.requested);
      expect(adapter.lastOptions?.method, 'POST');
      expect(adapter.lastOptions?.uri.toString(), endsWith('/appointments'));
      expect(adapter.lastOptions?.data, <String, dynamic>{
        'professionalProfileId': 'professional-1',
        'requestedStartAt': '2026-07-14T09:30:00.000Z',
        'durationMinutes': 30,
      });
      final payload = adapter.lastOptions?.data as Map<String, dynamic>;
      expect(payload.containsKey('patientProfileId'), isFalse);
      expect(payload.containsKey('status'), isFalse);
      expect(payload.containsKey('paymentState'), isFalse);
      expect(payload.containsKey('calendarState'), isFalse);
      expect(payload.containsKey('medicalNotes'), isFalse);
    });

    test('own appointment list parses safe appointment statuses', () async {
      final adapter = _FakeAdapter(
        responseJson: <String, dynamic>{
          'items': <Map<String, dynamic>>[
            _appointmentJson(id: 'appointment-1', status: 'ACCEPTED'),
            _appointmentJson(id: 'appointment-2', status: 'COMPLETED'),
          ],
        },
      );
      final repository = _repository(adapter: adapter, withSession: true);

      final appointments = await repository.ownAppointments();

      expect(appointments, hasLength(2));
      expect(appointments.first.status, AppointmentStatus.accepted);
      expect(appointments.last.status, AppointmentStatus.completed);
      expect(adapter.lastOptions?.method, 'GET');
      expect(adapter.lastOptions?.uri.toString(), endsWith('/appointments'));
    });

    test('lifecycle actions send no trusted status body', () async {
      final adapter = _FakeAdapter(
        responseJson: _appointmentJson(status: 'ACCEPTED'),
      );
      final repository = _repository(adapter: adapter, withSession: true);

      await repository.acceptAppointment(appointmentId: 'appointment-1');

      expect(adapter.lastOptions?.method, 'POST');
      expect(
        adapter.lastOptions?.uri.toString(),
        endsWith('/appointments/appointment-1/accept'),
      );
      expect(adapter.lastOptions?.data, isNull);
    });

    test('reschedule sends only requested time and duration', () async {
      final adapter = _FakeAdapter(
        responseJson: _appointmentJson(status: 'REQUESTED'),
      );
      final repository = _repository(adapter: adapter, withSession: true);

      await repository.rescheduleAppointment(
        appointmentId: 'appointment-1',
        requestedStartAt: DateTime.parse('2026-07-15T11:00:00Z'),
        durationMinutes: 45,
      );

      expect(
        adapter.lastOptions?.uri.toString(),
        endsWith('/appointments/appointment-1/reschedule'),
      );
      expect(adapter.lastOptions?.data, <String, dynamic>{
        'requestedStartAt': '2026-07-15T11:00:00.000Z',
        'durationMinutes': 45,
      });
      final payload = adapter.lastOptions?.data as Map<String, dynamic>;
      expect(payload.containsKey('status'), isFalse);
      expect(payload.containsKey('professionalProfileId'), isFalse);
      expect(payload.containsKey('notificationState'), isFalse);
    });

    test('protected scheduling calls require a stored session', () async {
      final repository = _repository(
        adapter: _FakeAdapter(responseJson: <String, dynamic>{}),
        withSession: false,
      );

      await expectLater(
        repository.ownAppointments(),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.type,
            'type',
            AuthFailureType.unauthorized,
          ),
        ),
      );
    });

    test('missing backend config fails closed', () async {
      final repository = SchedulingRepository(
        apiClient: SchedulingApiClient(
          config: const CareNetApiConfig(baseUrl: ''),
          dio: Dio(),
        ),
        sessionStore: InMemorySessionStore()..save(_session()),
      );

      await expectLater(
        repository.ownAvailability(),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.type,
            'type',
            AuthFailureType.missingConfiguration,
          ),
        ),
      );
    });

    test('unavailable or conflicting slots map to safe validation failure', () {
      final repository = _repository(
        adapter: _FakeAdapter(
          responseJson: <String, dynamic>{'message': 'raw conflict'},
          statusCode: 409,
        ),
        withSession: true,
      );

      expectLater(
        repository.requestAppointment(
          professionalProfileId: 'professional-1',
          requestedStartAt: DateTime.parse('2026-07-14T10:30:00Z'),
          durationMinutes: 30,
        ),
        throwsA(
          isA<AuthFailure>()
              .having(
                (failure) => failure.type,
                'type',
                AuthFailureType.validation,
              )
              .having(
                (failure) => failure.message,
                'message',
                'Please choose an available time and try again.',
              ),
        ),
      );
    });
  });
}

SchedulingRepository _repository({
  required _FakeAdapter adapter,
  required bool withSession,
}) {
  final store = InMemorySessionStore();
  if (withSession) {
    unawaited(store.save(_session()));
  }
  return SchedulingRepository(
    apiClient: SchedulingApiClient(
      config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
      dio: Dio()..httpClientAdapter = adapter,
    ),
    sessionStore: store,
  );
}

AuthSessionModel _session() {
  return AuthSessionModel.fromJson(<String, dynamic>{
    'accessToken': 'access-token',
    'refreshToken': 'refresh-token',
    'tokenType': 'Bearer',
    'expiresIn': 900,
    'user': <String, dynamic>{
      'id': 'user-1',
      'email': 'patient@example.com',
      'role': 'PATIENT',
      'status': 'ACTIVE',
      'emailVerified': true,
    },
  });
}

Map<String, dynamic> _availabilityJson({
  String id = 'availability-1',
  bool active = true,
}) {
  return <String, dynamic>{
    'id': id,
    'weekday': 1,
    'startMinute': 540,
    'endMinute': 1020,
    'timezone': 'Africa/Lagos',
    'active': active,
    'createdAt': '2026-07-14T08:00:00.000Z',
    'updatedAt': '2026-07-14T08:00:00.000Z',
    'professionalProfileId': 'private-owner',
  };
}

Map<String, dynamic> _appointmentJson({
  String id = 'appointment-1',
  String status = 'REQUESTED',
}) {
  return <String, dynamic>{
    'id': id,
    'patientProfileId': 'patient-1',
    'professionalProfileId': 'professional-1',
    'requestedStartAt': '2026-07-14T10:30:00.000Z',
    'durationMinutes': 30,
    'status': status,
    'createdAt': '2026-07-14T08:00:00.000Z',
    'updatedAt': '2026-07-14T08:00:00.000Z',
    'paymentState': 'SHOULD_NOT_BE_AUTHORITY',
  };
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.responseJson, this.statusCode = 200});

  final dynamic responseJson;
  final int statusCode;
  RequestOptions? lastOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    final body = jsonEncode(responseJson);
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
