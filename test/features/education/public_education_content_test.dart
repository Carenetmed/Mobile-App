import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Education/data/services/education_content_api_client.dart';
import 'package:app_t/features/Education/domain/entities/public_education_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Public education DTOs', () {
    test('parses only the approved public identity and content fields', () {
      final post = PublicEducationContent.fromJson(<String, dynamic>{
        ..._textPost(),
        'privateReviewNotes': 'must not be retained',
        'author': <String, dynamic>{
          'displayName': 'Dr Amina Yusuf',
          'category': 'Medical doctor',
          'specialty': 'Family medicine',
          'email': 'private@example.test',
        },
      });

      expect(post.id, 'education-1');
      expect(post.author.displayName, 'Dr Amina Yusuf');
      expect(post.author.category, 'Medical doctor');
      expect(post.author.specialty, 'Family medicine');
      expect(post.body, 'General information only.');
      expect(post.publishedAt.isUtc, isTrue);
      expect(post.toString(), isNot(contains('privateReviewNotes')));
    });

    test('rejects unknown types, malformed identities and invalid dates', () {
      expect(
        () => PublicEducationContent.fromJson(<String, dynamic>{
          ..._textPost(),
          'type': 'ARTICLE',
        }),
        throwsFormatException,
      );
      expect(
        () => PublicEducationContent.fromJson(<String, dynamic>{
          ..._textPost(),
          'id': ' ',
        }),
        throwsFormatException,
      );
      expect(
        () => PublicEducationContent.fromJson(<String, dynamic>{
          ..._textPost(),
          'publishedAt': 'not-a-date',
        }),
        throwsFormatException,
      );
    });

    test('requires actual video data for short-video posts', () {
      expect(
        () => PublicEducationContent.fromJson(<String, dynamic>{
          ..._textPost(),
          'type': 'SHORT_VIDEO',
          'body': null,
        }),
        throwsFormatException,
      );
    });

    test('accepts only HTTPS Google Storage URLs and bounded expiry', () {
      final video = PublicEducationVideo.fromJson(<String, dynamic>{
        'url': 'https://storage.googleapis.com/carenet/video.mp4?sig=secret',
        'expiresInSeconds': 300,
      });
      expect(video.url.scheme, 'https');
      expect(video.expiresInSeconds, 300);
      expect(
        video.isExpiredAt(video.receivedAt.add(const Duration(seconds: 300))),
        isTrue,
      );

      for (final url in <String>[
        'http://storage.googleapis.com/carenet/video.mp4',
        'https://evil.example/video.mp4',
        'https://user@storage.googleapis.com/carenet/video.mp4',
      ]) {
        expect(
          () => PublicEducationVideo.fromJson(<String, dynamic>{
            'url': url,
            'expiresInSeconds': 300,
          }),
          throwsFormatException,
        );
      }
      expect(
        () => PublicEducationVideo.fromJson(<String, dynamic>{
          'url': 'https://storage.googleapis.com/carenet/video.mp4',
          'expiresInSeconds': 601,
        }),
        throwsFormatException,
      );
    });

    test('rejects an invalid public cursor', () {
      expect(
        () => PublicEducationFeedPage.fromJson(<String, dynamic>{
          'items': <Object>[],
          'nextCursor': 'unsafe cursor',
        }),
        throwsFormatException,
      );
    });
  });

  group('Public education API', () {
    test('feed and detail use unauthenticated public endpoints', () async {
      final adapter = _EducationAdapter(<String, dynamic>{
        'items': <Object>[_textPost()],
        'nextCursor': 'next-2',
      });
      final client = _client(adapter);

      final page = await client.listPublic();
      expect(page.items.single.id, 'education-1');
      expect(adapter.request?.method, 'GET');
      expect(adapter.request?.uri.path, '/education/content');
      expect(adapter.request?.headers['Authorization'], isNull);

      await client.listPublic(cursor: 'next-2');
      expect(adapter.request?.uri.queryParameters, <String, String>{
        'cursor': 'next-2',
      });

      adapter.responseJson = _textPost();
      final detail = await client.getPublic(contentId: 'education-1');
      expect(detail.id, 'education-1');
      expect(adapter.request?.uri.path, '/education/content/education-1');
      expect(adapter.request?.headers['Authorization'], isNull);
    });

    test('report uses the authenticated reason-code contract', () async {
      final adapter = _EducationAdapter(<String, dynamic>{'received': true});
      final client = _client(adapter);

      await client.reportPublic(
        contentId: 'education-1',
        accessToken: 'test-only-token',
        reason: 'MISLEADING_HEALTH_INFORMATION',
      );

      expect(adapter.request?.method, 'POST');
      expect(
        adapter.request?.uri.path,
        '/education/content/education-1/reports',
      );
      expect(
        adapter.request?.headers['Authorization'],
        'Bearer test-only-token',
      );
      expect(adapter.request?.data, <String, String>{
        'reason': 'MISLEADING_HEALTH_INFORMATION',
      });
    });
  });
}

EducationContentApiClient _client(_EducationAdapter adapter) =>
    EducationContentApiClient(
      config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
      dio: Dio()..httpClientAdapter = adapter,
    );

Map<String, dynamic> _textPost() => <String, dynamic>{
  'id': 'education-1',
  'type': 'TEXT_POST',
  'title': 'Everyday health information',
  'body': 'General information only.',
  'caption': null,
  'publishedAt': '2026-11-10T12:00:00.000Z',
  'author': <String, dynamic>{
    'displayName': 'Dr Amina Yusuf',
    'category': 'Medical doctor',
    'specialty': 'Family medicine',
  },
};

class _EducationAdapter implements HttpClientAdapter {
  _EducationAdapter(this.responseJson);

  Object responseJson;
  RequestOptions? request;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode(responseJson),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
