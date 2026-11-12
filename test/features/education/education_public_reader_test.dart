import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/domain/entities/public_education_content.dart';
import 'package:app_t/features/Education/presentation/pages/education_feed_shell.dart';
import 'package:app_t/features/Education/presentation/widgets/education_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'public_education_test_fakes.dart';

void main() {
  testWidgets(
    'feed shows an honest empty state when the backend has no posts',
    (tester) async {
      final source = FakeEducationPublicContentSource();
      await tester.pumpWidget(
        MaterialApp(home: EducationFeedShellPage(source: source)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Health education posts are not available yet.'),
        findsOneWidget,
      );
      expect(source.cursors, <String?>[null]);
      expect(find.text('CareNet Doctor'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'feed failure offers retry and never shows local sample content',
    (tester) async {
      final source =
          FakeEducationPublicContentSource()
            ..nextListFailure = const AuthFailure(
              type: AuthFailureType.network,
              message: 'private failure details',
            );
      await tester.pumpWidget(
        MaterialApp(home: EducationFeedShellPage(source: source)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Health education posts could not be loaded.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Everyday health information'), findsNothing);

      source.firstPage = PublicEducationFeedPage(
        items: <PublicEducationContent>[publicEducationPost()],
        nextCursor: null,
      );
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Everyday health information'), findsOneWidget);
      expect(source.cursors, <String?>[null, null]);
    },
  );

  testWidgets('feed renders backend author and opens detail by content ID', (
    tester,
  ) async {
    final post = publicEducationPost();
    final source =
        FakeEducationPublicContentSource()
          ..firstPage = PublicEducationFeedPage(
            items: <PublicEducationContent>[post],
            nextCursor: null,
          );
    await tester.pumpWidget(
      MaterialApp(
        home: EducationFeedShellPage(source: source),
        onGenerateRoute:
            (settings) => MaterialPageRoute<void>(
              settings: settings,
              builder:
                  (_) =>
                      Scaffold(body: Text('detail-id:${settings.arguments}')),
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CareNet Doctor'), findsOneWidget);
    expect(find.textContaining('General practice'), findsOneWidget);
    expect(
      find.text('Clear general health information from a verified doctor.'),
      findsOneWidget,
    );
    await tester.tap(find.text(post.title));
    await tester.pumpAndSettle();
    expect(find.text('detail-id:post-1'), findsOneWidget);
  });

  testWidgets('refresh failure retains posts and offers a retry', (
    tester,
  ) async {
    final source =
        FakeEducationPublicContentSource()
          ..firstPage = PublicEducationFeedPage(
            items: <PublicEducationContent>[publicEducationPost()],
            nextCursor: null,
          );
    await tester.pumpWidget(
      MaterialApp(home: EducationFeedShellPage(source: source)),
    );
    await tester.pumpAndSettle();

    source.nextListFailure = const AuthFailure(
      type: AuthFailureType.network,
      message: 'private failure details',
    );
    await tester.tap(find.byTooltip('Refresh posts'));
    await tester.pumpAndSettle();

    expect(find.text('Everyday health information'), findsOneWidget);
    expect(
      find.text('Education posts are unavailable right now. Please retry.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('private failure details'), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Everyday health information'), findsOneWidget);
    expect(
      find.text('Education posts are unavailable right now. Please retry.'),
      findsNothing,
    );
  });

  testWidgets('detail displays only public post fields and report reason', (
    tester,
  ) async {
    final post = publicEducationPost();
    final source = FakeEducationPublicContentSource()..details[post.id] = post;
    await tester.pumpWidget(
      MaterialApp(
        home: EducationDetailShellPage(contentId: post.id, source: source),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(post.title), findsOneWidget);
    expect(find.text('CareNet Doctor'), findsOneWidget);
    expect(find.text(post.body!), findsOneWidget);
    expect(find.textContaining('not a diagnosis'), findsOneWidget);
    expect(find.textContaining('payment'), findsNothing);
    expect(find.textContaining('likes'), findsNothing);

    await tester.tap(find.byTooltip('Report post'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Misleading health information'));
    await tester.pumpAndSettle();
    expect(source.reports, <(String, String)>[
      ('post-1', 'MISLEADING_HEALTH_INFORMATION'),
    ]);
    expect(find.text('Your report was received.'), findsWidgets);
  });

  testWidgets('video playback is user initiated and never autoplays', (
    tester,
  ) async {
    final playback = FakeEducationVideoPlayback();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EducationVideoPlayer(
            video: publicEducationVideo(),
            onRefresh: () async {},
            playbackFactory: (_) => playback,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(playback.initializeCalls, 1);
    expect(playback.playing, isFalse);
    expect(find.byTooltip('Play video'), findsOneWidget);
    await tester.tap(find.byTooltip('Play video'));
    await tester.pumpAndSettle();
    expect(playback.playCalls, 1);
    expect(playback.playing, isTrue);
    expect(find.byTooltip('Pause video'), findsOneWidget);
  });

  testWidgets('expired signed video URL does not initialize the player', (
    tester,
  ) async {
    final playback = FakeEducationVideoPlayback();
    var refreshCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EducationVideoPlayer(
            video: publicEducationVideo(
              receivedAt: DateTime.utc(2026),
              expiresInSeconds: 1,
            ),
            now: () => DateTime.utc(2026, 1, 1, 0, 0, 2),
            onRefresh: () async {
              refreshCalls++;
            },
            playbackFactory: (_) => playback,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(playback.initializeCalls, 0);
    expect(find.textContaining('expired'), findsOneWidget);
    await tester.tap(find.text('Load video again'));
    await tester.pumpAndSettle();
    expect(refreshCalls, 1);
  });

  testWidgets('failed detail never renders a locally fabricated post', (
    tester,
  ) async {
    final source = FakeEducationPublicContentSource();
    await tester.pumpWidget(
      MaterialApp(
        home: EducationDetailShellPage(contentId: 'missing', source: source),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('This post is no longer available.'), findsOneWidget);
    expect(find.text('Everyday health information'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
