import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/auth_api_client.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/services/onboarding_api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Onboarding repository boundary', () {
    test(
      'real onboarding client preserves HTTP 401 unauthorized semantics',
      () async {
        const internalMessage =
            'Internal authentication detail: token rejected';
        final adapter = _FakeAdapter(
          statusCodes: <int>[401],
          responseJson: <String, dynamic>{'message': internalMessage},
        );
        final repository = _repository(adapter: adapter, withSession: true);

        await expectLater(
          repository.accountReadiness(),
          throwsA(
            isA<AuthFailure>()
                .having(
                  (failure) => failure.type,
                  'type',
                  AuthFailureType.unauthorized,
                )
                .having((failure) => failure.statusCode, 'statusCode', 401)
                .having(
                  (failure) => failure.message,
                  'safe message',
                  'Please sign in again.',
                )
                .having(
                  (failure) => failure.toString(),
                  'no internal body leak',
                  isNot(contains(internalMessage)),
                )
                .having(
                  (failure) => failure.shouldClearSession,
                  'shouldClearSession',
                  isTrue,
                ),
          ),
        );
        expect(adapter.options, hasLength(1));
        expect(adapter.options.single.uri.path, '/account/readiness');
        expect(
          adapter.options.single.headers['Authorization'],
          'Bearer access-token',
        );
      },
    );

    test(
      'real onboarding HTTP 403 never refreshes or replays readiness and preserves the session',
      () async {
        const internalMessage =
            'Internal policy detail: readiness permission denied';
        final store = InMemorySessionStore();
        final session = _session();
        await store.save(session);
        final before = (await store.capture())!;
        final readinessAdapter = _FakeAdapter(
          statusCodes: <int>[403],
          responseJson: <String, dynamic>{'message': internalMessage},
        );
        final refreshAdapter = _FakeAdapter(
          responseJson: <String, dynamic>{
            ...session.toJson(),
            'accessToken': 'unexpected-refreshed-access-token',
            'refreshToken': 'unexpected-refreshed-refresh-token',
          },
        );
        final repository = OnboardingRepository(
          apiClient: OnboardingApiClient(
            config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
            dio: Dio()..httpClientAdapter = readinessAdapter,
          ),
          sessionStore: store,
          authRepository: AuthRepository(
            apiClient: AuthApiClient(
              config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
              dio: Dio()..httpClientAdapter = refreshAdapter,
            ),
            sessionStore: store,
          ),
        );

        await expectLater(
          repository.accountReadiness(),
          throwsA(
            isA<AuthFailure>()
                .having(
                  (failure) => failure.type,
                  'type',
                  AuthFailureType.forbidden,
                )
                .having((failure) => failure.statusCode, 'statusCode', 403)
                .having(
                  (failure) => failure.message,
                  'safe permission message',
                  'This account does not have permission for this action.',
                )
                .having(
                  (failure) => failure.toString(),
                  'no internal body leak',
                  isNot(contains(internalMessage)),
                )
                .having(
                  (failure) => failure.shouldClearSession,
                  'shouldClearSession',
                  isFalse,
                ),
          ),
        );
        expect(refreshAdapter.options, isEmpty);
        expect(readinessAdapter.options, hasLength(1));
        expect(readinessAdapter.options.single.uri.path, '/account/readiness');
        expect(
          readinessAdapter.options.single.headers['Authorization'],
          'Bearer access-token',
        );
        final after = (await store.capture())!;
        expect(after.generation, before.generation);
        expect(after.session.toJson(), before.session.toJson());
      },
    );

    test(
      'catalog read uses public backend route without auth headers',
      () async {
        final adapter = _FakeAdapter(
          responseJson: <String, dynamic>{
            'launchCountry': 'NG',
            'countries': <Map<String, dynamic>>[
              <String, dynamic>{
                'code': 'NG',
                'name': 'Nigeria',
                'status': 'SUPPORTED',
              },
            ],
            'nigeriaStates': <Map<String, dynamic>>[
              <String, dynamic>{'code': 'LA', 'name': 'Lagos'},
              <String, dynamic>{
                'code': 'FC',
                'name': 'Federal Capital Territory',
              },
            ],
            'professionalCatalog': <Map<String, dynamic>>[
              <String, dynamic>{
                'code': 'MEDICAL_DOCTOR',
                'label': 'Medical doctor',
                'regulatorCode': 'MDCN',
                'regulatorName': 'Medical and Dental Council of Nigeria',
                'requiredEvidence': <String>[
                  'GOVERNMENT_IDENTITY',
                  'PROFESSIONAL_REGISTRATION_OR_LICENSE',
                  'QUALIFICATION_CERTIFICATE',
                ],
              },
            ],
            'verificationEvidenceTypes': <Map<String, dynamic>>[
              <String, dynamic>{
                'code': 'PROFESSIONAL_REGISTRATION_OR_LICENSE',
                'label': 'Professional registration or licence',
                'documentType': 'LICENSE',
              },
            ],
            'patientHealthInterestCatalog': <Map<String, dynamic>>[
              <String, dynamic>{
                'code': 'PRIMARY_CARE',
                'label': 'Primary care',
              },
            ],
          },
        );
        final repository = _repository(adapter: adapter, withSession: false);

        final catalog = await repository.onboardingCatalog();

        expect(catalog.launchCountry, 'NG');
        expect(catalog.countries.single.name, 'Nigeria');
        expect(
          catalog.nigeriaStates.map((state) => state.code),
          contains('LA'),
        );
        expect(catalog.professionalCatalog.single.code, 'MEDICAL_DOCTOR');
        expect(catalog.professionalCatalog.single.regulatorCode, 'MDCN');
        expect(
          catalog.professionalCatalog.single.requiredEvidence,
          contains('QUALIFICATION_CERTIFICATE'),
        );
        expect(
          catalog.verificationEvidenceTypes.single.documentType,
          'LICENSE',
        );
        expect(
          catalog.patientHealthInterestCatalog.single.code,
          'PRIMARY_CARE',
        );
        expect(adapter.lastOptions?.method, 'GET');
        expect(
          adapter.lastOptions?.uri.toString(),
          endsWith('/catalogs/onboarding'),
        );
        expect(
          adapter.lastOptions?.headers.containsKey('Authorization'),
          isFalse,
        );
        expect(adapter.lastOptions?.headers.containsKey('Cookie'), isFalse);
      },
    );

    test(
      'account readiness uses bearer auth and parses professional state',
      () async {
        final adapter = _FakeAdapter(
          responseJson: <String, dynamic>{
            'account': <String, dynamic>{
              'role': 'PROFESSIONAL',
              'status': 'ACTIVE',
              'emailVerified': true,
            },
            'professional': <String, dynamic>{
              'applicationStatus': 'DRAFT',
              'verificationStatus': 'NOT_SUBMITTED',
              'countryCode': 'NG',
              'professionCode': 'MEDICAL_DOCTOR',
              'regulatorCode': 'MDCN',
              'requiredProfileFields': <String>[],
              'requiredEvidence': <String>[
                'GOVERNMENT_IDENTITY',
                'PROFESSIONAL_REGISTRATION_OR_LICENSE',
                'QUALIFICATION_CERTIFICATE',
              ],
              'missingEvidence': <String>[
                'PROFESSIONAL_REGISTRATION_OR_LICENSE',
              ],
            },
            'nextAction': 'PROFESSIONAL_UPLOAD_EVIDENCE',
            'requiredActions': <String>[
              'UPLOAD_PROFESSIONAL_REGISTRATION_OR_LICENSE',
            ],
          },
        );
        final repository = _repository(adapter: adapter, withSession: true);

        final readiness = await repository.accountReadiness();

        expect(readiness.account.role, 'PROFESSIONAL');
        expect(readiness.professional?.countryCode, 'NG');
        expect(readiness.professional?.professionCode, 'MEDICAL_DOCTOR');
        expect(readiness.professional?.regulatorCode, 'MDCN');
        expect(readiness.nextAction, 'PROFESSIONAL_UPLOAD_EVIDENCE');
        expect(
          readiness.requiredActions,
          contains('UPLOAD_PROFESSIONAL_REGISTRATION_OR_LICENSE'),
        );
        expect(adapter.lastOptions?.method, 'GET');
        expect(
          adapter.lastOptions?.uri.toString(),
          endsWith('/account/readiness'),
        );
        expect(
          adapter.lastOptions?.headers['Authorization'],
          'Bearer access-token',
        );
        expect(adapter.lastOptions?.headers.containsKey('Cookie'), isFalse);
      },
    );

    test(
      'account readiness refreshes once after an expired access token',
      () async {
        final store = InMemorySessionStore();
        await store.save(_session());
        final readinessAdapter = _FakeAdapter(
          responseJson: <String, dynamic>{
            'account': <String, dynamic>{
              'role': 'PATIENT',
              'status': 'ACTIVE',
              'emailVerified': true,
            },
            'patient': <String, dynamic>{
              'profileStatus': 'COMPLETE',
              'requiredFields': <String>[],
            },
            'nextAction': 'DASHBOARD',
            'requiredActions': <String>[],
          },
          statusCodes: <int>[401, 200],
        );
        final refreshAdapter = _FakeAdapter(
          responseJson: <String, dynamic>{
            'accessToken': 'fresh-access-token',
            'refreshToken': 'fresh-refresh-token',
            'tokenType': 'Bearer',
            'expiresIn': 900,
            'user': <String, dynamic>{
              'id': 'user-1',
              'email': 'doctor@example.com',
              'role': 'PROFESSIONAL',
              'status': 'ACTIVE',
              'emailVerified': true,
            },
          },
        );
        final authRepository = AuthRepository(
          apiClient: AuthApiClient(
            config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
            dio: Dio()..httpClientAdapter = refreshAdapter,
          ),
          sessionStore: store,
        );
        final repository = OnboardingRepository(
          apiClient: OnboardingApiClient(
            config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
            dio: Dio()..httpClientAdapter = readinessAdapter,
          ),
          sessionStore: store,
          authRepository: authRepository,
        );

        final readiness = await repository.accountReadiness();

        expect(readiness.nextAction, 'DASHBOARD');
        expect(readinessAdapter.options, hasLength(2));
        expect(
          readinessAdapter.options.first.headers['Authorization'],
          'Bearer access-token',
        );
        expect(
          readinessAdapter.options.last.headers['Authorization'],
          'Bearer fresh-access-token',
        );
        expect(refreshAdapter.options, hasLength(1));
        expect(refreshAdapter.options.single.uri.path, '/auth/refresh');
      },
    );

    test('account readiness requires a stored session', () async {
      final repository = _repository(
        adapter: _FakeAdapter(responseJson: <String, dynamic>{}),
        withSession: false,
      );

      await expectLater(
        repository.accountReadiness(),
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
      final repository = OnboardingRepository(
        apiClient: OnboardingApiClient(
          config: const CareNetApiConfig(baseUrl: ''),
          dio: Dio(),
        ),
        sessionStore: InMemorySessionStore()..save(_session()),
      );

      await expectLater(
        repository.onboardingCatalog(),
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

OnboardingRepository _repository({
  required _FakeAdapter adapter,
  required bool withSession,
}) {
  final store = InMemorySessionStore();
  if (withSession) {
    unawaited(store.save(_session()));
  }
  return OnboardingRepository(
    apiClient: OnboardingApiClient(
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
      'email': 'doctor@example.com',
      'role': 'PROFESSIONAL',
      'status': 'ACTIVE',
      'emailVerified': true,
    },
  });
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.responseJson, this.statusCodes = const <int>[]});

  final Map<String, dynamic> responseJson;
  final List<int> statusCodes;
  RequestOptions? lastOptions;
  final List<RequestOptions> options = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    this.options.add(options);
    final body = jsonEncode(responseJson);
    final responseIndex = this.options.length - 1;
    final statusCode =
        responseIndex < statusCodes.length ? statusCodes[responseIndex] : 200;
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
