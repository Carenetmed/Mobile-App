import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/data/services/education_content_api_client.dart';
import 'package:app_t/features/Education/domain/entities/education_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('published content is editable but not directly resubmittable', () {
    final published = EducationContent.fromJson(<String, dynamic>{
      ..._postJson(),
      'status': 'PUBLISHED',
      'body': 'A reviewed general education post.',
    });

    expect(published.canEdit, isTrue);
    expect(published.canSubmit, isFalse);
    expect(published.canArchive, isTrue);
  });

  group('Education content API contract', () {
    test('lists only the authenticated author endpoint', () async {
      final adapter = _EducationAdapter(<Map<String, dynamic>>[_postJson()]);
      final client = _client(adapter);

      final posts = await client.listMine(accessToken: 'secret-test-token');

      expect(posts.single.id, 'content-1');
      expect(adapter.options?.method, 'GET');
      expect(adapter.options?.uri.path, '/education/content/mine');
      expect(
        adapter.options?.headers['Authorization'],
        'Bearer secret-test-token',
      );
      expect(adapter.options?.uri.path, isNot('/education/content'));
    });

    test('creates a backend-owned draft with only contract fields', () async {
      final adapter = _EducationAdapter(<String, dynamic>{
        ..._postJson(),
        'body': 'General information.',
      });
      final client = _client(adapter);

      final result = await client.createDraft(
        accessToken: 'token',
        type: EducationContentType.textPost,
        title: 'Health basics',
        body: 'General information.',
      );

      expect(result.status, 'DRAFT');
      expect(adapter.options?.method, 'POST');
      expect(adapter.options?.uri.path, '/education/content');
      expect(adapter.options?.data, <String, dynamic>{
        'type': 'TEXT_POST',
        'title': 'Health basics',
        'body': 'General information.',
      });
      expect((adapter.options?.data as Map).containsKey('authorId'), isFalse);
      expect((adapter.options?.data as Map).containsKey('status'), isFalse);
    });

    test(
      'updates, submits and archives through exact backend routes',
      () async {
        final adapter = _EducationAdapter(<String, dynamic>{
          ..._postJson(),
          'body': 'Updated general information.',
        });
        final client = _client(adapter);
        final original = EducationContent.fromJson(<String, dynamic>{
          ..._postJson(),
          'body': 'Original general information.',
        });

        await client.updateDraft(
          accessToken: 'token',
          content: original,
          title: 'Updated title',
          body: 'Updated general information.',
        );
        expect(adapter.options?.method, 'PATCH');
        expect(adapter.options?.uri.path, '/education/content/content-1');
        expect(adapter.options?.data, <String, dynamic>{
          'title': 'Updated title',
          'body': 'Updated general information.',
        });

        await client.updateDraft(
          accessToken: 'token',
          content: original,
          title: 'Updated title',
          body: 'Updated general information.',
          caption: '',
        );
        expect((adapter.options?.data as Map).containsKey('caption'), isTrue);
        expect((adapter.options?.data as Map)['caption'], '');

        adapter.responseJson = <String, dynamic>{
          'id': 'content-1',
          'status': 'PENDING_REVIEW',
        };
        await client.submit(accessToken: 'token', contentId: 'content-1');
        expect(adapter.options?.method, 'POST');
        expect(
          adapter.options?.uri.path,
          '/education/content/content-1/submit',
        );

        adapter.responseJson = <String, dynamic>{
          'id': 'content-1',
          'status': 'ARCHIVED',
        };
        await client.archive(accessToken: 'token', contentId: 'content-1');
        expect(adapter.options?.method, 'POST');
        expect(
          adapter.options?.uri.path,
          '/education/content/content-1/archive',
        );
      },
    );

    test(
      'uploads MP4 with required MIME type and accepts rejected status',
      () async {
        final adapter = _EducationAdapter(<String, dynamic>{
          'id': 'content-1',
          'status': 'REJECTED',
          'mediaDurationMs': 30000,
        });
        final client = _client(adapter);

        final receipt = await client.uploadVideo(
          accessToken: 'token',
          contentId: 'content-1',
          fileName: r'C:\private\original.mp4',
          bytes: Uint8List.fromList(<int>[1, 2, 3]),
          cancelToken: CancelToken(),
        );

        final form = adapter.options?.data as FormData;
        expect(adapter.options?.uri.path, '/education/content/content-1/video');
        expect(form.files, hasLength(1));
        expect(form.files.single.key, 'video');
        expect(form.files.single.value.filename, 'original.mp4');
        expect(form.files.single.value.contentType.toString(), 'video/mp4');
        expect(receipt.status, 'REJECTED');
        expect(receipt.durationMs, 30000);
      },
    );

    test('does not submit when private media storage is unavailable', () async {
      final adapter = _EducationAdapter(<String, dynamic>{
        'message': 'private bucket unavailable',
      }, statusCode: 503);
      final client = _client(adapter);

      await expectLater(
        client.uploadVideo(
          accessToken: 'token',
          contentId: 'content-1',
          fileName: 'education.mp4',
          bytes: Uint8List.fromList(<int>[1]),
          cancelToken: CancelToken(),
        ),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'user-safe message',
            'Video upload is temporarily unavailable. Your draft is saved.',
          ),
        ),
      );
      expect(adapter.options?.uri.path, '/education/content/content-1/video');
    });

    test('rejects an invalid over-limit upload receipt', () async {
      final adapter = _EducationAdapter(<String, dynamic>{
        'id': 'content-1',
        'status': 'DRAFT',
        'mediaDurationMs': 60001,
      });
      final client = _client(adapter);

      await expectLater(
        client.uploadVideo(
          accessToken: 'token',
          contentId: 'content-1',
          fileName: 'lesson.mp4',
          bytes: Uint8List.fromList(<int>[1]),
          cancelToken: CancelToken(),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('maps authorization failure without exposing backend details', () async {
      final adapter = _EducationAdapter(<String, dynamic>{
        'message': 'private role and profile details',
      }, statusCode: 403);
      final client = _client(adapter);

      await expectLater(
        client.listMine(accessToken: 'token'),
        throwsA(
          isA<AuthFailure>()
              .having(
                (failure) => failure.type,
                'failure type',
                AuthFailureType.forbidden,
              )
              .having(
                (failure) => failure.message,
                'safe message',
                'Education posts are available to active, verified medical doctors.',
              ),
        ),
      );
    });
  });
}

EducationContentApiClient _client(_EducationAdapter adapter) =>
    EducationContentApiClient(
      config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
      dio: Dio()..httpClientAdapter = adapter,
    );

Map<String, dynamic> _postJson() => <String, dynamic>{
  'id': 'content-1',
  'type': 'TEXT_POST',
  'status': 'DRAFT',
  'title': 'Health basics',
  'createdAt': '2026-11-11T10:00:00.000Z',
};

class _EducationAdapter implements HttpClientAdapter {
  _EducationAdapter(this.responseJson, {this.statusCode = 200});

  Object responseJson;
  final int statusCode;
  RequestOptions? options;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    this.options = options;
    return ResponseBody.fromString(
      jsonEncode(responseJson),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
