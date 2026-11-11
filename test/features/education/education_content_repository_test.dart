import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/data/repositories/education_content_repository.dart';
import 'package:app_t/features/Education/data/services/education_content_api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Education content repository authority boundary', () {
    test('patient role is rejected before any authoring request', () async {
      final adapter = _RepositoryAdapter();
      final repository = _repository(adapter, role: 'PATIENT');

      await expectLater(
        repository.listMine(),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.type,
            'failure type',
            AuthFailureType.forbidden,
          ),
        ),
      );
      expect(adapter.calls, 0);
    });

    test('professional reads use persisted session bearer identity', () async {
      final adapter = _RepositoryAdapter();
      final repository = _repository(adapter, role: 'PROFESSIONAL');

      final posts = await repository.listMine();

      expect(posts, isEmpty);
      expect(adapter.calls, 1);
      expect(adapter.lastOptions?.uri.path, '/education/content/mine');
      expect(
        adapter.lastOptions?.headers['Authorization'],
        'Bearer token-professional-1',
      );
    });

    test('account switch during a request invalidates its result', () async {
      final store = InMemorySessionStore();
      await store.save(_session(id: 'professional-1'));
      final adapter = _RepositoryAdapter(
        beforeRespond: () => store.save(_session(id: 'professional-2')),
      );
      final repository = EducationContentRepository(
        apiClient: EducationContentApiClient(
          config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
          dio: Dio()..httpClientAdapter = adapter,
        ),
        sessionStore: store,
      );

      await expectLater(
        repository.listMine(),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.type,
            'failure type',
            AuthFailureType.unauthorized,
          ),
        ),
      );
      expect((await store.read())?.user.id, 'professional-2');
    });
  });
}

EducationContentRepository _repository(
  _RepositoryAdapter adapter, {
  required String role,
}) {
  final store =
      InMemorySessionStore()..save(_session(id: 'professional-1', role: role));
  return EducationContentRepository(
    apiClient: EducationContentApiClient(
      config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
      dio: Dio()..httpClientAdapter = adapter,
    ),
    sessionStore: store,
  );
}

AuthSessionModel _session({required String id, String role = 'PROFESSIONAL'}) =>
    AuthSessionModel.fromJson(<String, dynamic>{
      'accessToken': 'token-$id',
      'refreshToken': 'refresh-$id',
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'user': <String, dynamic>{
        'id': id,
        'email': '$id@example.test',
        'role': role,
        'status': 'ACTIVE',
        'emailVerified': true,
      },
    });

class _RepositoryAdapter implements HttpClientAdapter {
  _RepositoryAdapter({this.beforeRespond});

  final Future<void> Function()? beforeRespond;
  int calls = 0;
  RequestOptions? lastOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    lastOptions = options;
    await beforeRespond?.call();
    return ResponseBody.fromString(
      jsonEncode(<dynamic>[]),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
