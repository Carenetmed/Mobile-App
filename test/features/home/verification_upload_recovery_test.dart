import 'dart:async';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/models/verification_document_model.dart';
import 'package:app_t/features/Home/data/repositories/verification_repository.dart';
import 'package:app_t/features/Home/data/services/verification_api_client.dart';
import 'package:app_t/features/Home/domain/entities/verification_upload_request.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known expired capability renews the same ID once before PUT', () async {
    final h = await _Harness.create();
    h.api.initial = h.capability(expired: true);
    expect((await h.upload()).id, 'document-1');
    expect(h.api.events, ['init', 'renew', 'put', 'complete']);
    expect(h.api.renewIds, ['document-1']);
    expect(h.api.putUrls, ['https://storage.example/renewed']);
    expect(h.api.putHeaders.single, h.api.renewed.requiredHeaders);
    h.expectCompletion(count: 1);
  });

  test('an already expired renewal fails before PUT', () async {
    final h = await _Harness.create();
    h.api.initial = h.capability(expired: true);
    h.api.renewed = h.capability(expired: true, renewed: true);
    await expectLater(h.upload(), throwsA(isA<AuthFailure>()));
    expect(h.api.events, ['init', 'renew']);
    expect(h.api.renewIds, ['document-1']);
  });

  for (final repeated in [false, true]) {
    test('PUT 403 after expiry renews once; repeated=$repeated', () async {
      final h = await _Harness.create();
      h.api.onPut = (attempt) async {
        h.now = h.now.add(const Duration(minutes: 10));
        if (attempt == 1 || repeated) throw _failure(403);
      };
      h.api.onRenew = () async {
        h.api.renewed = h.capability(renewed: true);
      };
      if (repeated) {
        await expectLater(h.upload(), throwsA(same(_forbidden)));
        expect(h.api.events, ['init', 'put', 'renew', 'put']);
      } else {
        await h.upload();
        expect(h.api.events, ['init', 'put', 'renew', 'put', 'complete']);
        h.expectCompletion(count: 1);
      }
      expect(h.api.renewIds, ['document-1']);
      expect(h.api.putUrls, [
        'https://storage.example/initial',
        'https://storage.example/renewed',
      ]);
      expect(h.api.putBytes, everyElement(orderedEquals(_bytes)));
    });
  }

  test('nonexpired PUT 403 does not renew or complete', () async {
    final h = await _Harness.create();
    h.api.onPut = (_) async => throw _forbidden;
    await expectLater(h.upload(), throwsA(same(_forbidden)));
    expect(h.api.events, ['init', 'put']);
  });

  test('legacy success uses no renewal endpoint', () async {
    final h = await _Harness.create(legacy: true);
    await h.upload();
    expect(h.api.events, ['init', 'put', 'complete']);
    expect(h.api.putHeaders.single, isEmpty);
    h.expectCompletion(count: 1);
  });

  test('legacy 503 completion is not retried', () async {
    final h = await _Harness.create(legacy: true);
    h.api.onComplete = (_) async => throw _failure(503);
    await expectLater(h.upload(), throwsA(isA<AuthFailure>()));
    expect(h.api.events, ['init', 'put', 'complete']);
    h.expectCompletion(count: 1);
  });

  test('legacy PUT 403 never calls renewal even after time advances', () async {
    final h = await _Harness.create(legacy: true);
    h.api.onPut = (_) async {
      h.now = h.now.add(const Duration(days: 1));
      throw _forbidden;
    };
    await expectLater(h.upload(), throwsA(same(_forbidden)));
    expect(h.api.events, ['init', 'put']);
  });

  for (final repeated in [false, true]) {
    test(
      'new-contract 503 completion replay is bounded; repeated=$repeated',
      () async {
        final h = await _Harness.create();
        h.api.onComplete = (attempt) async {
          if (attempt == 1 || repeated) throw _failure(503);
        };
        if (repeated) {
          await expectLater(h.upload(), throwsA(isA<AuthFailure>()));
        } else {
          expect((await h.upload()).checksumProvided, isTrue);
        }
        expect(h.api.events, ['init', 'put', 'complete', 'complete']);
        h.expectCompletion(count: 2);
      },
    );
  }

  for (final status in [409, 404]) {
    test('completion $status is never retried', () async {
      final h = await _Harness.create();
      final failure = _failure(status);
      h.api.onComplete = (_) async => throw failure;
      await expectLater(h.upload(), throwsA(same(failure)));
      expect(h.api.events, ['init', 'put', 'complete']);
      h.expectCompletion(count: 1);
    });
  }

  test('missing session prevents every API phase', () async {
    final h = await _Harness.create();
    await h.store.clear();
    await expectLater(h.upload(), throwsA(_unauthorized));
    expect(h.api.events, isEmpty);
  });

  for (final accountChange in [false, true]) {
    for (final phase in ['renew', 'put', 'afterRenew', 'complete', 'replay']) {
      test(
        '${accountChange ? 'account change' : 'logout'} before $phase stops upload',
        () async {
          final h = await _Harness.create();
          Future<void> changeSession() async {
            if (accountChange) {
              await h.store.save(_session('other-user'));
            } else {
              await h.store.clear();
            }
          }

          switch (phase) {
            case 'renew':
              h.api.initial = h.capability(expired: true);
              h.api.onInit = changeSession;
            case 'put':
              h.api.onInit = changeSession;
            case 'afterRenew':
              h.api.initial = h.capability(expired: true);
              h.api.onRenew = changeSession;
            case 'complete':
              h.api.onPut = (_) => changeSession();
            case 'replay':
              h.api.onComplete = (_) async {
                await changeSession();
                throw _failure(503);
              };
          }
          await expectLater(h.upload(), throwsA(_unauthorized));
          expect(h.api.events, switch (phase) {
            'renew' || 'put' => ['init'],
            'afterRenew' => ['init', 'renew'],
            'complete' => ['init', 'put'],
            _ => ['init', 'put', 'complete'],
          });
        },
      );
    }
  }

  for (final replay in [false, true]) {
    for (final change in ['logout', 'account switch', 'cancel']) {
      test(
        '$change while successful completion ${replay ? 'replay' : 'POST'} is pending rejects success',
        () async {
          final h = await _Harness.create();
          final started = Completer<void>();
          final response = Completer<VerificationDocumentModel>();
          final controller = VerificationUploadController();
          h.api.pendingCompletion = response.future;
          h.api.onComplete = (attempt) async {
            if (replay && attempt == 1) throw _failure(503);
            started.complete();
          };
          final rejection = expectLater(
            h.upload(controller: controller),
            throwsA(
              change == 'cancel'
                  ? isA<VerificationUploadCancelled>()
                  : _unauthorized,
            ),
          );
          try {
            await started.future.timeout(const Duration(seconds: 5));
            switch (change) {
              case 'logout':
                await h.store.clear();
              case 'account switch':
                await h.store.save(_session('other-user'));
              case 'cancel':
                controller.cancel();
            }
            expect(response.isCompleted, isFalse);
            expect(h.api.events, [
              'init',
              'put',
              'complete',
              if (replay) 'complete',
            ]);
            h.expectCompletion(count: replay ? 2 : 1);
          } finally {
            response.complete(_completedDocument);
            await rejection.timeout(const Duration(seconds: 5));
          }
          expect(h.api.events, [
            'init',
            'put',
            'complete',
            if (replay) 'complete',
          ]);
        },
      );
    }
  }

  test(
    'cancellation while renewal is pending prevents PUT and completion',
    () async {
      final h = await _Harness.create();
      h.api.initial = h.capability(expired: true);
      final started = Completer<void>();
      final release = Completer<void>();
      h.api.onRenew = () async {
        started.complete();
        await release.future;
      };
      final controller = VerificationUploadController();
      final result = expectLater(
        h.upload(controller: controller),
        throwsA(isA<VerificationUploadCancelled>()),
      );
      try {
        await started.future.timeout(const Duration(seconds: 5));
        controller.cancel();
      } finally {
        release.complete();
        await result;
      }
      expect(h.api.events, ['init', 'renew']);
    },
  );
}

const _bytes = [1, 2, 3];
const _completedDocument = VerificationDocumentModel(
  id: 'document-1',
  documentType: 'license',
  status: 'PENDING',
  storageProvider: 'gcs',
  mimeType: 'application/pdf',
  fileSizeBytes: 3,
  checksumProvided: true,
);
const _forbidden = AuthFailure(
  type: AuthFailureType.forbidden,
  message: 'Storage denied upload',
  statusCode: 403,
);
final _unauthorized = isA<AuthFailure>().having(
  (failure) => failure.type,
  'type',
  AuthFailureType.unauthorized,
);

AuthFailure _failure(int status) =>
    status == 403
        ? _forbidden
        : AuthFailure(
          type:
              status == 503
                  ? AuthFailureType.server
                  : AuthFailureType.validation,
          message: 'Test failure',
          statusCode: status,
        );

AuthSessionModel _session(String id) => AuthSessionModel.fromJson({
  'accessToken': 'token-$id',
  'refreshToken': 'refresh-$id',
  'tokenType': 'Bearer',
  'expiresIn': 900,
  'user': {
    'id': id,
    'email': '$id@example.com',
    'role': 'PROFESSIONAL',
    'status': 'ACTIVE',
    'emailVerified': true,
  },
});

class _Harness {
  final store = InMemorySessionStore();
  final api = _RecoveryApi();
  DateTime now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  static Future<_Harness> create({bool legacy = false}) async {
    final h = _Harness();
    await h.store.save(_session('owner'));
    h.api.initial = h.capability(legacy: legacy);
    h.api.renewed = h.capability(renewed: true);
    return h;
  }

  VerificationUploadInitModel capability({
    bool expired = false,
    bool renewed = false,
    bool legacy = false,
  }) => VerificationUploadInitModel.fromJson({
    'document': {
      'id': 'document-1',
      'documentType': 'license',
      'status': 'PENDING',
      'storageProvider': 'gcs',
      'mimeType': 'application/pdf',
      'fileSizeBytes': 3,
    },
    'upload': {
      'signedUrl': 'https://storage.example/${renewed ? 'renewed' : 'initial'}',
      'expiresInSeconds': 300,
      if (!legacy) ...{
        'expiresAt':
            now.add(Duration(minutes: expired ? -1 : 5)).toIso8601String(),
        'requiredHeaders': {
          'content-type': 'application/pdf',
          'content-length': '3',
          'x-goog-if-generation-match': '0',
        },
      },
    },
  });

  Future<VerificationDocumentModel> upload({
    VerificationUploadController? controller,
  }) async {
    final result = await VerificationRepository(
      apiClient: api,
      sessionStore: store,
      clock: () => now,
    ).uploadDocument(
      VerificationUploadRequest(
        documentType: 'license',
        originalFileName: 'license.pdf',
        mimeType: 'application/pdf',
        fileBytes: _bytes,
        fileSizeBytes: 999,
        controller: controller,
      ),
    );
    return result as VerificationDocumentModel;
  }

  void expectCompletion({required int count}) {
    expect(api.completions, hasLength(count));
    expect(
      api.completions,
      everyElement((
        id: 'document-1',
        size: 3,
        hash: sha256.convert(_bytes).toString(),
      )),
    );
    expect(api.tokens, everyElement('token-owner'));
  }
}

class _RecoveryApi extends VerificationApiClient {
  _RecoveryApi()
    : super(config: const CareNetApiConfig(baseUrl: 'https://unused.invalid'));

  late VerificationUploadInitModel initial;
  late VerificationUploadInitModel renewed;
  Future<void> Function()? onInit;
  Future<void> Function()? onRenew;
  Future<void> Function(int)? onPut;
  Future<void> Function(int)? onComplete;
  Future<VerificationDocumentModel>? pendingCompletion;
  final events = <String>[];
  final tokens = <String>[];
  final renewIds = <String>[];
  final putUrls = <String>[];
  final putHeaders = <Map<String, String>>[];
  final putBytes = <List<int>>[];
  final completions = <({String id, int size, String hash})>[];

  @override
  Future<VerificationUploadInitModel> uploadInit({
    required String accessToken,
    required String documentType,
    required String originalFileName,
    required String mimeType,
    int? fileSizeBytes,
  }) async {
    events.add('init');
    tokens.add(accessToken);
    expect(documentType, 'license');
    expect(originalFileName, 'license.pdf');
    expect(mimeType, 'application/pdf');
    expect(fileSizeBytes, 3);
    await onInit?.call();
    return initial;
  }

  @override
  Future<VerificationUploadInitModel> uploadRenew({
    required String accessToken,
    required String documentId,
  }) async {
    events.add('renew');
    tokens.add(accessToken);
    renewIds.add(documentId);
    await onRenew?.call();
    return renewed;
  }

  @override
  Future<void> uploadBytes({
    required String signedUploadUrl,
    required List<int> fileBytes,
    required String mimeType,
    Map<String, String> requiredHeaders = const {},
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    events.add('put');
    putUrls.add(signedUploadUrl);
    putHeaders.add(Map.of(requiredHeaders));
    putBytes.add(List.of(fileBytes));
    expect(mimeType, 'application/pdf');
    expect(cancelToken?.isCancelled, isFalse);
    await onPut?.call(putUrls.length);
  }

  @override
  Future<VerificationDocumentModel> uploadComplete({
    required String accessToken,
    required String documentId,
    required int fileSizeBytes,
    required String checksumSha256,
  }) async {
    events.add('complete');
    tokens.add(accessToken);
    completions.add((
      id: documentId,
      size: fileSizeBytes,
      hash: checksumSha256,
    ));
    await onComplete?.call(completions.length);
    return pendingCompletion ?? Future.value(_completedDocument);
  }
}
