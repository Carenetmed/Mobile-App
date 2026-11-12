import 'dart:async';

import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/data/repositories/education_public_content_repository.dart';
import 'package:app_t/features/Education/domain/entities/public_education_content.dart';
import 'package:app_t/features/Education/presentation/widgets/education_video_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class FakeEducationPublicContentSource implements EducationPublicContentSource {
  PublicEducationFeedPage firstPage = const PublicEducationFeedPage(
    items: <PublicEducationContent>[],
    nextCursor: null,
  );
  final Map<String, PublicEducationFeedPage> pages =
      <String, PublicEducationFeedPage>{};
  final Map<String, PublicEducationContent> details =
      <String, PublicEducationContent>{};
  final List<String?> cursors = <String?>[];
  final List<(String, String)> reports = <(String, String)>[];
  final List<Completer<PublicEducationFeedPage>?> listGates =
      <Completer<PublicEducationFeedPage>?>[];
  AuthFailure? nextListFailure;
  AuthFailure? nextDetailFailure;
  AuthFailure? nextReportFailure;

  @override
  Future<PublicEducationFeedPage> listPublic({
    String? cursor,
    CancelToken? cancelToken,
  }) {
    cursors.add(cursor);
    if (listGates.length >= cursors.length &&
        listGates[cursors.length - 1] != null) {
      return listGates[cursors.length - 1]!.future;
    }
    final failure = nextListFailure;
    if (failure != null) {
      nextListFailure = null;
      return Future<PublicEducationFeedPage>.error(failure);
    }
    return Future<PublicEducationFeedPage>.value(
      cursor == null ? firstPage : pages[cursor] ?? firstPage,
    );
  }

  @override
  Future<PublicEducationContent> getPublic({
    required String contentId,
    CancelToken? cancelToken,
  }) {
    final failure = nextDetailFailure;
    if (failure != null) {
      nextDetailFailure = null;
      return Future<PublicEducationContent>.error(failure);
    }
    final content = details[contentId];
    return content == null
        ? Future<PublicEducationContent>.error(
          const AuthFailure(
            type: AuthFailureType.unknown,
            message: 'not found',
            statusCode: 404,
          ),
        )
        : Future<PublicEducationContent>.value(content);
  }

  @override
  Future<void> report({required String contentId, required String reason}) {
    final failure = nextReportFailure;
    if (failure != null) {
      nextReportFailure = null;
      return Future<void>.error(failure);
    }
    reports.add((contentId, reason));
    return Future<void>.value();
  }
}

PublicEducationContent publicEducationPost({
  String id = 'post-1',
  PublicEducationContentType type = PublicEducationContentType.textPost,
  String title = 'Everyday health information',
  String? body = 'Clear general health information from a verified doctor.',
  String? caption,
  PublicEducationVideo? video,
  DateTime? publishedAt,
}) => PublicEducationContent(
  id: id,
  type: type,
  title: title,
  body: body,
  caption: caption,
  publishedAt: publishedAt ?? DateTime.utc(2026, 11, 10, 12),
  author: const PublicEducationAuthor(
    displayName: 'CareNet Doctor',
    category: 'Medical doctor',
    specialty: 'General practice',
  ),
  video: video,
);

class FakeEducationVideoPlayback extends EducationVideoPlayback {
  bool _initialized = false;
  bool _playing = false;
  int initializeCalls = 0;
  int playCalls = 0;
  int pauseCalls = 0;
  bool disposed = false;

  @override
  bool get initialized => _initialized;

  @override
  bool get playing => _playing;

  @override
  bool get failed => false;

  @override
  double get aspectRatio => 9 / 16;

  @override
  Future<void> initialize() async {
    initializeCalls++;
    _initialized = true;
    notifyListeners();
  }

  @override
  Future<void> togglePlayback() async {
    if (_playing) {
      await pause();
    } else {
      playCalls++;
      _playing = true;
      notifyListeners();
    }
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    _playing = false;
    notifyListeners();
  }

  @override
  Widget buildSurface() => const ColoredBox(color: Colors.black);

  @override
  Widget buildProgress() => const SizedBox.shrink();

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

EducationVideoPlayback fakeVideoPlaybackFactory(PublicEducationVideo _) =>
    FakeEducationVideoPlayback();

PublicEducationVideo publicEducationVideo({
  DateTime? receivedAt,
  int expiresInSeconds = 300,
}) => PublicEducationVideo(
  url: Uri.parse('https://storage.googleapis.com/carenet-private/video.mp4'),
  expiresInSeconds: expiresInSeconds,
  receivedAt: receivedAt ?? DateTime.now().toUtc(),
);
