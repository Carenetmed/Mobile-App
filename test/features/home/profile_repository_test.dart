import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/services/profile_api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Profile repository boundary', () {
    test(
      'patient self-read sends bearer auth and treats 404 as empty profile',
      () async {
        final adapter = _FakeAdapter(
          statusCode: 404,
          responseJson: <String, dynamic>{'message': 'Not found'},
        );
        final repository = _repository(adapter: adapter, withSession: true);

        final profile = await repository.patientMe();

        expect(profile, isNull);
        expect(adapter.lastOptions?.method, 'GET');
        expect(adapter.lastOptions?.uri.toString(), endsWith('/patients/me'));
        expect(
          adapter.lastOptions?.headers['Authorization'],
          'Bearer access-token',
        );
        expect(adapter.lastOptions?.headers.containsKey('Cookie'), isFalse);
      },
    );

    test('patient update sends only allowed patient fields', () async {
      final adapter = _FakeAdapter(
        responseJson: <String, dynamic>{
          'id': 'patient-1',
          'name': 'Jane Patient',
          'age': 32,
          'location': 'Lagos',
        },
      );
      final repository = _repository(adapter: adapter, withSession: true);

      final profile = await repository.updatePatientMe(
        name: 'Jane Patient',
        age: 32,
        location: 'Lagos',
      );

      expect(profile.name, 'Jane Patient');
      expect(adapter.lastOptions?.method, 'PUT');
      expect(adapter.lastOptions?.uri.toString(), endsWith('/patients/me'));
      expect(adapter.lastOptions?.data, <String, dynamic>{
        'name': 'Jane Patient',
        'age': 32,
        'location': 'Lagos',
      });
      expect(
        (adapter.lastOptions?.data as Map<String, dynamic>).containsKey(
          'patientProfileId',
        ),
        isFalse,
      );
    });

    test(
      'professional update does not send forbidden verification fields',
      () async {
        final adapter = _FakeAdapter(
          responseJson: <String, dynamic>{
            'id': 'professional-1',
            'displayName': 'Dr. Care',
            'category': 'Cardiologist',
            'specialty': 'Heart health',
            'bio': 'Focused on prevention.',
            'verificationStatus': 'PENDING',
          },
        );
        final repository = _repository(adapter: adapter, withSession: true);

        final profile = await repository.updateProfessionalMe(
          displayName: 'Dr. Care',
          category: 'Cardiologist',
          specialty: 'Heart health',
          bio: 'Focused on prevention.',
        );

        expect(profile.displayName, 'Dr. Care');
        expect(adapter.lastOptions?.method, 'PUT');
        expect(
          adapter.lastOptions?.uri.toString(),
          endsWith('/professionals/me'),
        );
        expect(adapter.lastOptions?.data, <String, dynamic>{
          'displayName': 'Dr. Care',
          'category': 'Cardiologist',
          'specialty': 'Heart health',
          'bio': 'Focused on prevention.',
        });
        expect(
          (adapter.lastOptions?.data as Map<String, dynamic>).containsKey(
            'verificationStatus',
          ),
          isFalse,
        );
      },
    );

    test('public professional list parses safe verified projection', () async {
      final adapter = _FakeAdapter(
        responseJson: <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'professional-1',
              'displayName': 'Dr. Care',
              'category': 'Cardiologist',
              'specialty': 'Heart health',
              'bio': 'Focused on prevention.',
              'verified': true,
              'email': 'private@example.com',
              'verificationDocuments': <String>['hidden'],
            },
          ],
        },
      );
      final repository = _repository(adapter: adapter, withSession: false);

      final professionals = await repository.publicProfessionals();

      expect(professionals, hasLength(1));
      expect(professionals.single.id, 'professional-1');
      expect(professionals.single.verified, isTrue);
      expect(adapter.lastOptions?.method, 'GET');
      expect(adapter.lastOptions?.uri.toString(), endsWith('/professionals'));
      expect(
        adapter.lastOptions?.headers.containsKey('Authorization'),
        isFalse,
      );
      expect(adapter.lastOptions?.headers.containsKey('Cookie'), isFalse);
    });

    test('protected profile calls require a stored session', () async {
      final repository = _repository(
        adapter: _FakeAdapter(responseJson: <String, dynamic>{}),
        withSession: false,
      );

      await expectLater(
        repository.professionalMe(),
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
      final repository = ProfileRepository(
        apiClient: ProfileApiClient(
          config: const CareNetApiConfig(baseUrl: ''),
          dio: Dio(),
        ),
        sessionStore: InMemorySessionStore()..save(_session()),
      );

      await expectLater(
        repository.patientMe(),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.type,
            'type',
            AuthFailureType.missingConfiguration,
          ),
        ),
      );
    });
  });
}

ProfileRepository _repository({
  required _FakeAdapter adapter,
  required bool withSession,
}) {
  final store = InMemorySessionStore();
  if (withSession) {
    unawaited(store.save(_session()));
  }
  return ProfileRepository(
    apiClient: ProfileApiClient(
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

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.responseJson, this.statusCode = 200});

  final Map<String, dynamic> responseJson;
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
