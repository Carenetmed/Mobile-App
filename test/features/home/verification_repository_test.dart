import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/verification_repository.dart';
import 'package:app_t/features/Home/data/services/verification_api_client.dart';
import 'package:app_t/features/Home/domain/entities/verification_upload_request.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Verification repository boundary', () {
    test(
      'document list sends bearer auth and parses safe projection',
      () async {
        final adapter = _QueueAdapter(<_QueuedResponse>[
          _QueuedResponse.json(<String, dynamic>{
            'documents': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'document-1',
                'documentType': 'license',
                'storageProvider': 'gcs',
                'storageObjectKey': 'private/object/key.pdf',
                'mimeType': 'application/pdf',
                'fileSizeBytes': 2048,
                'checksumSha256': 'raw-secret-checksum',
                'checksumProvided': true,
                'status': 'PENDING',
                'uploadedAt': '2026-07-15T08:00:00.000Z',
              },
            ],
          }),
        ]);
        final repository = _repository(apiAdapter: adapter, withSession: true);

        final documents = await repository.documents();

        expect(documents, hasLength(1));
        expect(documents.single.id, 'document-1');
        expect(documents.single.documentType, 'license');
        expect(documents.single.status, 'PENDING');
        expect(documents.single.checksumProvided, isTrue);
        expect(adapter.requests.single.method, 'GET');
        expect(
          adapter.requests.single.uri.toString(),
          endsWith('/verification/documents'),
        );
        expect(
          adapter.requests.single.headers['Authorization'],
          'Bearer access-token',
        );
        expect(adapter.requests.single.headers.containsKey('Cookie'), isFalse);
        expect(
          documents.single.toString().contains('private/object/key.pdf'),
          isFalse,
        );
        expect(
          documents.single.toString().contains('raw-secret-checksum'),
          isFalse,
        );
      },
    );

    test(
      'upload flow keeps signed URL internal and sends allowed metadata',
      () async {
        final apiAdapter = _QueueAdapter(<_QueuedResponse>[
          _QueuedResponse.json(<String, dynamic>{
            'document': <String, dynamic>{
              'id': 'document-1',
              'documentType': 'license',
              'storageProvider': 'gcs',
              'mimeType': 'application/pdf',
              'fileSizeBytes': 3,
              'status': 'PENDING',
              'uploadedAt': '2026-07-15T08:00:00.000Z',
            },
            'upload': <String, dynamic>{
              'signedUrl': 'https://storage.example/signed-upload',
              'expiresInSeconds': 900,
            },
          }),
          _QueuedResponse.json(<String, dynamic>{
            'document': <String, dynamic>{
              'id': 'document-1',
              'documentType': 'license',
              'storageProvider': 'gcs',
              'mimeType': 'application/pdf',
              'fileSizeBytes': 3,
              'checksumSha256': sha256.convert(<int>[1, 2, 3]).toString(),
              'status': 'PENDING',
              'uploadedAt': '2026-07-15T08:00:00.000Z',
            },
          }),
        ]);
        final uploadAdapter = _QueueAdapter(<_QueuedResponse>[
          _QueuedResponse.json(<String, dynamic>{}),
        ]);
        final repository = _repository(
          apiAdapter: apiAdapter,
          uploadAdapter: uploadAdapter,
          withSession: true,
        );
        final progress = <double>[];

        final document = await repository.uploadDocument(
          VerificationUploadRequest(
            documentType: 'license',
            originalFileName: 'license.pdf',
            mimeType: 'application/pdf',
            fileBytes: const <int>[1, 2, 3],
            onProgress: progress.add,
          ),
        );

        expect(document.id, 'document-1');
        expect(document.status, 'PENDING');
        expect(apiAdapter.requests, hasLength(2));
        expect(uploadAdapter.requests, hasLength(1));

        final initRequest = apiAdapter.requests.first;
        expect(initRequest.method, 'POST');
        expect(
          initRequest.uri.toString(),
          endsWith('/verification/documents/upload-init'),
        );
        expect(initRequest.headers['Authorization'], 'Bearer access-token');
        expect(initRequest.data, <String, dynamic>{
          'documentType': 'license',
          'originalFileName': 'license.pdf',
          'mimeType': 'application/pdf',
          'fileSizeBytes': 3,
        });
        expect(
          (initRequest.data as Map<String, dynamic>).containsKey(
            'professionalProfileId',
          ),
          isFalse,
        );
        expect(
          (initRequest.data as Map<String, dynamic>).containsKey('status'),
          isFalse,
        );
        expect(
          (initRequest.data as Map<String, dynamic>).containsKey(
            'storageObjectKey',
          ),
          isFalse,
        );

        final signedPutRequest = uploadAdapter.requests.single;
        expect(signedPutRequest.method, 'PUT');
        expect(
          signedPutRequest.uri.toString(),
          'https://storage.example/signed-upload',
        );
        expect(signedPutRequest.headers.containsKey('Authorization'), isFalse);
        expect(signedPutRequest.headers['Content-Type'], 'application/pdf');
        expect(signedPutRequest.data, <int>[1, 2, 3]);
        signedPutRequest.onSendProgress?.call(2, 3);
        expect(progress.single, closeTo(2 / 3, 0.0001));

        final completeRequest = apiAdapter.requests.last;
        expect(completeRequest.method, 'POST');
        expect(
          completeRequest.uri.toString(),
          endsWith('/verification/documents/document-1/upload-complete'),
        );
        expect(completeRequest.headers['Authorization'], 'Bearer access-token');
        expect(completeRequest.data, <String, dynamic>{
          'fileSizeBytes': 3,
          'checksumSha256': sha256.convert(<int>[1, 2, 3]).toString(),
        });
      },
    );

    test('upload complete always includes computed checksum', () async {
      final checksum = sha256.convert(<int>[4, 5]).toString();
      final apiAdapter = _QueueAdapter(<_QueuedResponse>[
        _QueuedResponse.json(<String, dynamic>{
          'document': <String, dynamic>{
            'id': 'document-2',
            'documentType': 'identity',
            'storageProvider': 'gcs',
            'mimeType': 'image/png',
            'fileSizeBytes': 2,
            'status': 'PENDING',
            'uploadedAt': '2026-07-15T08:00:00.000Z',
          },
          'upload': <String, dynamic>{
            'signedUrl': 'https://storage.example/signed-upload-2',
            'expiresInSeconds': 900,
          },
        }),
        _QueuedResponse.json(<String, dynamic>{
          'document': <String, dynamic>{
            'id': 'document-2',
            'documentType': 'identity',
            'storageProvider': 'gcs',
            'mimeType': 'image/png',
            'fileSizeBytes': 2,
            'checksumSha256': checksum,
            'status': 'PENDING',
            'uploadedAt': '2026-07-15T08:00:00.000Z',
          },
        }),
      ]);
      final uploadAdapter = _QueueAdapter(<_QueuedResponse>[
        _QueuedResponse.json(<String, dynamic>{}),
      ]);
      final repository = _repository(
        apiAdapter: apiAdapter,
        uploadAdapter: uploadAdapter,
        withSession: true,
      );

      final document = await repository.uploadDocument(
        VerificationUploadRequest(
          documentType: 'identity',
          originalFileName: 'identity.png',
          mimeType: 'image/png',
          fileBytes: const <int>[4, 5],
        ),
      );

      expect(document.checksumProvided, isTrue);
      expect(apiAdapter.requests.last.data, <String, dynamic>{
        'fileSizeBytes': 2,
        'checksumSha256': checksum,
      });
    });

    test('protected verification calls require a stored session', () async {
      final repository = _repository(
        apiAdapter: _QueueAdapter(<_QueuedResponse>[
          _QueuedResponse.json(<String, dynamic>{}),
        ]),
        withSession: false,
      );

      await expectLater(
        repository.documents(),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.type,
            'type',
            AuthFailureType.unauthorized,
          ),
        ),
      );
    });

    test(
      'verification preserves distinct 401 and 403 authorization meaning',
      () async {
        final unauthorizedRepository = _repository(
          apiAdapter: _QueueAdapter(<_QueuedResponse>[
            _QueuedResponse.json(const <String, dynamic>{}, statusCode: 401),
          ]),
          withSession: true,
        );
        final forbiddenRepository = _repository(
          apiAdapter: _QueueAdapter(<_QueuedResponse>[
            _QueuedResponse.json(const <String, dynamic>{}, statusCode: 403),
          ]),
          withSession: true,
        );

        await expectLater(
          unauthorizedRepository.documents(),
          throwsA(
            isA<AuthFailure>()
                .having(
                  (failure) => failure.type,
                  'type',
                  AuthFailureType.unauthorized,
                )
                .having((failure) => failure.statusCode, 'statusCode', 401),
          ),
        );
        await expectLater(
          forbiddenRepository.documents(),
          throwsA(
            isA<AuthFailure>()
                .having(
                  (failure) => failure.type,
                  'type',
                  AuthFailureType.forbidden,
                )
                .having((failure) => failure.statusCode, 'statusCode', 403),
          ),
        );
      },
    );

    test('pre-cancelled upload makes no API or storage request', () async {
      final adapter = _QueueAdapter(<_QueuedResponse>[]);
      final repository = _repository(apiAdapter: adapter, withSession: true);
      final controller = VerificationUploadController()..cancel();

      await expectLater(
        repository.uploadDocument(
          VerificationUploadRequest(
            documentType: 'license',
            originalFileName: 'license.pdf',
            mimeType: 'application/pdf',
            fileBytes: const <int>[1, 2, 3],
            controller: controller,
          ),
        ),
        throwsA(isA<VerificationUploadCancelled>()),
      );
      expect(adapter.requests, isEmpty);
    });

    test('missing backend config fails closed', () async {
      final repository = VerificationRepository(
        apiClient: VerificationApiClient(
          config: const CareNetApiConfig(baseUrl: ''),
          dio: Dio(),
        ),
        sessionStore: InMemorySessionStore()..save(_session()),
      );

      await expectLater(
        repository.documents(),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.type,
            'type',
            AuthFailureType.missingConfiguration,
          ),
        ),
      );
    });

    test('server errors map to safe app failures', () async {
      final repository = _repository(
        apiAdapter: _QueueAdapter(<_QueuedResponse>[
          _QueuedResponse.json(<String, dynamic>{
            'message': 'storage exploded internally',
          }, statusCode: 503),
        ]),
        withSession: true,
      );

      await expectLater(
        repository.documents(),
        throwsA(
          isA<AuthFailure>()
              .having((failure) => failure.type, 'type', AuthFailureType.server)
              .having(
                (failure) => failure.message,
                'message',
                'Service is unavailable. Please try again.',
              ),
        ),
      );
    });
  });
}

VerificationRepository _repository({
  required _QueueAdapter apiAdapter,
  _QueueAdapter? uploadAdapter,
  required bool withSession,
}) {
  final store = InMemorySessionStore();
  if (withSession) {
    unawaited(store.save(_session()));
  }
  return VerificationRepository(
    apiClient: VerificationApiClient(
      config: const CareNetApiConfig(baseUrl: 'http://127.0.0.1:8080'),
      dio: Dio()..httpClientAdapter = apiAdapter,
      uploadDio: Dio()..httpClientAdapter = uploadAdapter ?? apiAdapter,
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
      'id': 'professional-user-1',
      'email': 'professional@example.com',
      'role': 'PROFESSIONAL',
      'status': 'ACTIVE',
      'emailVerified': true,
    },
  });
}

class _QueuedResponse {
  const _QueuedResponse(this.responseJson, {this.statusCode = 200});

  factory _QueuedResponse.json(
    Map<String, dynamic> responseJson, {
    int statusCode = 200,
  }) {
    return _QueuedResponse(responseJson, statusCode: statusCode);
  }

  final Map<String, dynamic> responseJson;
  final int statusCode;
}

class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(List<_QueuedResponse> responses) : _responses = responses;

  final List<_QueuedResponse> _responses;
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
    if (_responses.isEmpty) {
      return ResponseBody.fromString(
        jsonEncode(<String, dynamic>{'message': 'Unexpected request'}),
        500,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        },
      );
    }
    final response = _responses.removeAt(0);
    return ResponseBody.fromString(
      jsonEncode(response.responseJson),
      response.statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
