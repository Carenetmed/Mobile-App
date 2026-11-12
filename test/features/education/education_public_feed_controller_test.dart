import 'dart:async';

import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/domain/entities/public_education_content.dart';
import 'package:app_t/features/Education/presentation/state/education_feed_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'public_education_test_fakes.dart';

void main() {
  group('EducationFeedController', () {
    test(
      'serializes initial load and preserves an honest empty listing',
      () async {
        final source = FakeEducationPublicContentSource();
        final controller = EducationFeedController(source);

        final first = controller.load();
        final repeated = controller.load();
        expect(identical(first, repeated), isTrue);
        expect(source.cursors, <String?>[null]);
        await first;

        expect(controller.items, isEmpty);
        expect(controller.error, isNull);
        controller.dispose();
      },
    );

    test(
      'initial failure is recoverable without local fallback content',
      () async {
        final source =
            FakeEducationPublicContentSource()
              ..nextListFailure = const AuthFailure(
                type: AuthFailureType.network,
                message: 'private transport error',
              );
        final controller = EducationFeedController(source);

        await controller.load();
        expect(controller.items, isEmpty);
        expect(controller.error, contains('unavailable'));
        expect(controller.error, isNot(contains('private transport error')));

        source.firstPage = PublicEducationFeedPage(
          items: <PublicEducationContent>[publicEducationPost()],
          nextCursor: null,
        );
        await controller.load();
        expect(controller.items.single.id, 'post-1');
        expect(controller.error, isNull);
        expect(source.cursors, <String?>[null, null]);
        controller.dispose();
      },
    );

    test(
      'refresh failure retains previously loaded posts and can recover',
      () async {
        final source =
            FakeEducationPublicContentSource()
              ..firstPage = PublicEducationFeedPage(
                items: <PublicEducationContent>[publicEducationPost()],
                nextCursor: null,
              );
        final controller = EducationFeedController(source);
        await controller.load();

        source.nextListFailure = const AuthFailure(
          type: AuthFailureType.server,
          message: 'backend internals',
          statusCode: 503,
        );
        await controller.refresh();
        expect(controller.items.single.id, 'post-1');
        expect(controller.refreshError, contains('retry'));
        expect(controller.error, isNull);

        source.firstPage = PublicEducationFeedPage(
          items: <PublicEducationContent>[publicEducationPost(id: 'post-2')],
          nextCursor: null,
        );
        await controller.refresh();
        expect(controller.items.map((item) => item.id), <String>['post-2']);
        expect(controller.refreshError, isNull);
        controller.dispose();
      },
    );

    test(
      'refresh during an in-flight load does not duplicate the request',
      () async {
        final gate = Completer<PublicEducationFeedPage>();
        final source = FakeEducationPublicContentSource()..listGates.add(gate);
        final controller = EducationFeedController(source);

        final initial = controller.load();
        final refresh = controller.refresh();
        expect(identical(initial, refresh), isTrue);
        expect(source.cursors, <String?>[null]);

        gate.complete(
          const PublicEducationFeedPage(
            items: <PublicEducationContent>[],
            nextCursor: null,
          ),
        );
        await initial;
        expect(controller.loading, isFalse);
        controller.dispose();
      },
    );

    test('pagination deduplicates overlapping pages', () async {
      final source =
          FakeEducationPublicContentSource()
            ..firstPage = PublicEducationFeedPage(
              items: <PublicEducationContent>[publicEducationPost()],
              nextCursor: 'cursor-2',
            )
            ..pages['cursor-2'] = PublicEducationFeedPage(
              items: <PublicEducationContent>[
                publicEducationPost(),
                publicEducationPost(id: 'post-2'),
              ],
              nextCursor: null,
            );
      final controller = EducationFeedController(source);
      await controller.load();
      await controller.loadMore();

      expect(controller.items.map((item) => item.id), <String>[
        'post-1',
        'post-2',
      ]);
      expect(source.cursors, <String?>[null, 'cursor-2']);
      controller.dispose();
    });

    test('stale page completion cannot replace refreshed data', () async {
      final oldPageGate = Completer<PublicEducationFeedPage>();
      final source =
          FakeEducationPublicContentSource()
            ..firstPage = PublicEducationFeedPage(
              items: <PublicEducationContent>[publicEducationPost()],
              nextCursor: 'cursor-2',
            )
            ..listGates.add(null)
            ..listGates.add(oldPageGate);
      final controller = EducationFeedController(source);
      await controller.load();

      final oldPage = controller.loadMore();
      source.firstPage = PublicEducationFeedPage(
        items: <PublicEducationContent>[publicEducationPost(id: 'fresh')],
        nextCursor: null,
      );
      await controller.refresh();
      oldPageGate.complete(
        PublicEducationFeedPage(
          items: <PublicEducationContent>[publicEducationPost(id: 'stale')],
          nextCursor: null,
        ),
      );
      await oldPage;

      expect(controller.items.map((item) => item.id), <String>['fresh']);
      controller.dispose();
    });

    test('dispose prevents late notification from a pending request', () async {
      final gate = Completer<PublicEducationFeedPage>();
      final source = FakeEducationPublicContentSource()..listGates.add(gate);
      final controller = EducationFeedController(source);
      var notifications = 0;
      controller.addListener(() => notifications++);
      final request = controller.load();
      controller.dispose();
      gate.complete(
        const PublicEducationFeedPage(
          items: <PublicEducationContent>[],
          nextCursor: null,
        ),
      );
      await request;
      expect(notifications, 1);
    });
  });

  group('EducationDetailController', () {
    test(
      'missing IDs fail closed and 404 never loads local fallback data',
      () async {
        final source = FakeEducationPublicContentSource();
        final missing = EducationDetailController(source, '');
        await missing.load();
        expect(missing.notFound, isTrue);
        expect(source.details, isEmpty);
        missing.dispose();

        final unknown = EducationDetailController(source, 'unknown');
        await unknown.load();
        expect(unknown.notFound, isTrue);
        expect(unknown.content, isNull);
        unknown.dispose();
      },
    );

    test(
      'refresh failure preserves a loaded post and report is serialized',
      () async {
        final post = publicEducationPost();
        final source =
            FakeEducationPublicContentSource()..details[post.id] = post;
        final controller = EducationDetailController(source, post.id);
        await controller.load();

        source.nextDetailFailure = const AuthFailure(
          type: AuthFailureType.network,
          message: 'internal network detail',
        );
        await controller.refresh();
        expect(controller.content?.id, post.id);
        expect(controller.error, contains('unavailable'));

        final first = controller.report('OTHER');
        final second = controller.report('SPAM_OR_PROMOTION');
        await Future.wait<void>(<Future<void>>[first, second]);
        expect(source.reports, <(String, String)>[(post.id, 'OTHER')]);
        expect(controller.reported, isTrue);
        controller.dispose();
      },
    );
  });
}
