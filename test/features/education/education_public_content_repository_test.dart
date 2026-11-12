import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/Education/data/repositories/education_public_content_repository.dart';
import 'package:app_t/features/Education/data/services/education_content_api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'public reads do not require or infer an authenticated account',
    () async {
      final adapter = _RepositoryAdapter(<String, dynamic>{
        'items': <Object>[],
        'nextCursor': null,
      });
      final repository = _repository(adapter, InMemorySessionStore());

      final page = await repository.listPublic();

      expect(page.items, isEmpty);
      expect(adapter.fetchCount, 1);
      expect(adapter.lastRequest?.headers['Authorization'], isNull);
    },
  );

  test(
    'report refuses unauthenticated callers before making a request',
    () async {
      final adapter = _RepositoryAdapter(<String, dynamic>{'received': true});
      final repository = _repository(adapter, InMemorySessionStore());

      await expectLater(
        repository.report(contentId: 'post-1', reason: 'OTHER'),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.type,
            'failure type',
            AuthFailureType.unauthorized,
          ),
        ),
      );
      expect(adapter.fetchCount, 0);
    },
  );

  test(
    'report is bound to the saved session and detects account changes',
    () async {
      final sessionStore = InMemorySessionStore();
      await sessionStore.save(_session('patient-a'));
      final adapter = _RepositoryAdapter(<String, dynamic>{
        'received': true,
      }, onFetch: () => sessionStore.save(_session('patient-b')));
      final repository = _repository(adapter, sessionStore);

      await expectLater(
        repository.report(contentId: 'post-1', reason: 'OTHER'),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.type,
            'failure type',
            AuthFailureType.unauthorized,
          ),
        ),
      );
      expect(
        adapter.lastRequest?.headers['Authorization'],
        'Bearer token-patient-a',
      );
    },
  );
}

EducationPublicContentRepository _repository(
  _RepositoryAdapter adapter,
  SessionStore sessionStore,
) => EducationPublicContentRepository(
  apiClient: EducationContentApiClient(
    config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
    dio: Dio()..httpClientAdapter = adapter,
  ),
  sessionStore: sessionStore,
);

AuthSessionModel _session(String id) => AuthSessionModel(
  accessToken: 'token-$id',
  refreshToken: 'refresh-$id',
  tokenType: 'Bearer',
  expiresIn: 900,
  user: AuthUser(
    id: id,
    email: '$id@example.test',
    role: 'PATIENT',
    status: 'ACTIVE',
    emailVerified: true,
  ),
);

class _RepositoryAdapter implements HttpClientAdapter {
  _RepositoryAdapter(this.responseJson, {this.onFetch});

  final Object responseJson;
  final Future<void> Function()? onFetch;
  int fetchCount = 0;
  RequestOptions? lastRequest;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCount++;
    lastRequest = options;
    await onFetch?.call();
    return ResponseBody.fromString(
      jsonEncode(responseJson),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
