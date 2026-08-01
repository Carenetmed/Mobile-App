import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Consultation/data/models/consultation_models.dart';
import 'package:app_t/features/Consultation/data/services/consultation_api_client.dart';
import 'package:app_t/features/Consultation/domain/entities/consultation_entities.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('consultation client follows the protected appointment contract', () async {
    final projection = _projectionJson();
    final adapter = _QueueAdapter(<Object>[
      projection,
      projection,
      projection,
      <String, dynamic>{
        'provider': 'LIVEKIT',
        'serverUrl': 'wss://rtc.example.test',
        'token': 'opaque-media-token',
        'expiresAt': '2026-07-30T10:05:00.000Z',
        'participantRole': 'PATIENT',
        'initialMediaPermissions': <String, dynamic>{
          'microphone': true,
          'camera': true,
        },
        'sessionId': 'session-1',
        'replacedPriorDevice': false,
      },
      projection,
      <String, dynamic>{
        'id': 'incident-1',
        'status': 'OPEN',
        'createdAt': '2026-07-30T10:00:00.000Z',
      },
    ]);
    final client = ConsultationApiClient(
      config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
      dio: Dio()..httpClientAdapter = adapter,
    );

    final loaded = await client.projection(
      accessToken: 'access-token',
      appointmentId: 'appointment 1',
    );
    await client.enterWaitingRoom(
      accessToken: 'access-token',
      appointmentId: 'appointment 1',
    );
    await client.admitPatient(
      accessToken: 'access-token',
      appointmentId: 'appointment 1',
    );
    final grant = await client.joinGrant(
      accessToken: 'access-token',
      appointmentId: 'appointment 1',
      deviceSessionId: 'device-session-1',
      cameraEnabled: true,
    );
    await client.endConsultation(
      accessToken: 'access-token',
      appointmentId: 'appointment 1',
    );
    await client.reportIncident(
      accessToken: 'access-token',
      appointmentId: 'appointment 1',
      category: ConsultationIncidentCategory.noAudio,
      reporterRole: ConsultationParticipantRole.patient,
      description: 'No audio from the other participant.',
    );

    expect(loaded.mode, ConsultationMode.video);
    expect(loaded.canEnterWaitingRoom, isTrue);
    expect(grant.serverUrl.toString(), 'wss://rtc.example.test');
    expect(grant.participantRole, ConsultationParticipantRole.patient);
    expect(adapter.requests.map((request) => request.path), <String>[
      'https://api.example.test/appointments/appointment%201/consultation',
      'https://api.example.test/appointments/appointment%201/consultation/waiting-room',
      'https://api.example.test/appointments/appointment%201/consultation/admit',
      'https://api.example.test/appointments/appointment%201/consultation/join-grants',
      'https://api.example.test/appointments/appointment%201/consultation/end',
      'https://api.example.test/appointments/appointment%201/consultation/incidents',
    ]);
    for (final request in adapter.requests) {
      expect(request.headers['Authorization'], 'Bearer access-token');
    }
    expect(adapter.requests[3].data, <String, dynamic>{
      'deviceSessionId': 'device-session-1',
      'cameraEnabled': true,
      'platform': 'flutter',
    });
    expect(adapter.requests[5].data, <String, dynamic>{
      'category': 'AUDIO_FAILURE',
      'description': 'No audio from the other participant.',
    });
  });

  test(
    'join grant rejects insecure or incomplete provider credentials',
    () async {
      final adapter = _QueueAdapter(<Object>[
        <String, dynamic>{
          'provider': 'LIVEKIT',
          'serverUrl': 'http://rtc.example.test',
          'token': 'token',
          'expiresAt': '2026-07-30T10:05:00.000Z',
          'participantRole': 'PATIENT',
          'initialMediaPermissions': <String, dynamic>{
            'microphone': true,
            'camera': true,
          },
          'sessionId': 'session-1',
          'replacedPriorDevice': false,
        },
      ]);
      final client = ConsultationApiClient(
        config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
        dio: Dio()..httpClientAdapter = adapter,
      );

      await expectLater(
        client.joinGrant(
          accessToken: 'access-token',
          appointmentId: 'appointment-1',
          deviceSessionId: 'device-session-1',
          cameraEnabled: true,
        ),
        throwsA(isA<FormatException>()),
      );
    },
  );

  test(
    'join grant rejects an unexpected provider or missing microphone grant',
    () async {
      final invalidGrants = <Map<String, dynamic>>[
        _joinGrantJson()..['provider'] = 'DAILY',
        _joinGrantJson()
          ..['initialMediaPermissions'] = <String, dynamic>{
            'microphone': false,
            'camera': true,
          },
      ];

      for (final response in invalidGrants) {
        final client = ConsultationApiClient(
          config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
          dio: Dio()..httpClientAdapter = _QueueAdapter(<Object>[response]),
        );

        await expectLater(
          client.joinGrant(
            accessToken: 'access-token',
            appointmentId: 'appointment-1',
            deviceSessionId: 'device-session-1',
            cameraEnabled: true,
          ),
          throwsA(isA<FormatException>()),
        );
      }
    },
  );

  test(
    'network incident category follows the authenticated reporter role',
    () async {
      final adapter = _QueueAdapter(<Object>[
        <String, dynamic>{
          'id': 'incident-1',
          'status': 'OPEN',
          'createdAt': '2026-07-30T10:00:00.000Z',
        },
      ]);
      final client = ConsultationApiClient(
        config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
        dio: Dio()..httpClientAdapter = adapter,
      );

      await client.reportIncident(
        accessToken: 'access-token',
        appointmentId: 'appointment-1',
        category: ConsultationIncidentCategory.disconnectedRepeatedly,
        reporterRole: ConsultationParticipantRole.patient,
      );

      expect(adapter.requests.single.data, <String, dynamic>{
        'category': 'PATIENT_NETWORK_FAILURE',
      });
    },
  );

  test('projection rejects unknown backend session status', () async {
    final response = _projectionJson()..['sessionStatus'] = 'NEW_STATUS';
    final client = ConsultationApiClient(
      config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
      dio: Dio()..httpClientAdapter = _QueueAdapter(<Object>[response]),
    );

    await expectLater(
      client.projection(
        accessToken: 'access-token',
        appointmentId: 'appointment-1',
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test(
    'projection accepts a requested appointment before a session exists',
    () async {
      final response =
          _projectionJson()
            ..['sessionStatus'] = null
            ..['joinOpensAt'] = null
            ..['lateJoinDeadlineAt'] = null
            ..['scheduledEndsAt'] = null
            ..['closesAt'] = null
            ..['canEnterWaitingRoom'] = false
            ..['blockingReason'] = 'APPOINTMENT_REQUESTED';
      final client = ConsultationApiClient(
        config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
        dio: Dio()..httpClientAdapter = _QueueAdapter(<Object>[response]),
      );

      final projection = await client.projection(
        accessToken: 'access-token',
        appointmentId: 'appointment-1',
      );

      expect(projection.sessionStatus, isNull);
      expect(projection.blockingReason, 'APPOINTMENT_REQUESTED');
      expect(projection.canJoin, isFalse);
    },
  );

  test('incident receipt rejects missing audit identity or timestamp', () {
    expect(
      () => ConsultationIncidentReceiptModel.fromJson(<String, dynamic>{
        'id': '',
        'status': 'OPEN',
        'createdAt': null,
      }),
      throwsFormatException,
    );
  });
}

Map<String, dynamic> _projectionJson() {
  return <String, dynamic>{
    'appointmentId': 'appointment-1',
    'mode': 'VIDEO',
    'sessionStatus': 'WAITING',
    'joinOpensAt': '2026-07-30T09:50:00.000Z',
    'lateJoinDeadlineAt': '2026-07-30T10:15:00.000Z',
    'scheduledEndsAt': '2026-07-30T10:30:00.000Z',
    'closesAt': '2026-07-30T10:40:00.000Z',
    'canEnterWaitingRoom': true,
    'canJoin': false,
    'canAdmit': false,
    'canRejoin': false,
    'patientWaiting': false,
    'patientAdmitted': false,
    'patientPresent': false,
    'professionalPresent': false,
    'blockingReason': null,
    'reviewRequired': false,
  };
}

Map<String, dynamic> _joinGrantJson() {
  return <String, dynamic>{
    'provider': 'LIVEKIT',
    'serverUrl': 'wss://rtc.example.test',
    'token': 'opaque-media-token',
    'expiresAt': '2026-07-30T10:05:00.000Z',
    'participantRole': 'PATIENT',
    'initialMediaPermissions': <String, dynamic>{
      'microphone': true,
      'camera': true,
    },
    'sessionId': 'session-1',
    'replacedPriorDevice': false,
  };
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
