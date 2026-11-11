import 'dart:async';
import 'dart:typed_data';

import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/domain/entities/education_content.dart';
import 'package:app_t/features/Education/presentation/state/education_studio_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'education_test_fakes.dart';

void main() {
  group('Education studio controller', () {
    test('coalesces repeated initial loads', () async {
      final source =
          FakeEducationContentDataSource()..listGate = Completer<void>();
      final controller = EducationStudioController(source);

      final first = controller.load();
      final second = controller.load();
      expect(source.listCalls, 1);
      source.listGate!.complete();
      await Future.wait(<Future<void>>[first, second]);

      expect(source.listCalls, 1);
      expect(controller.hasLoaded, isTrue);
      controller.dispose();
    });

    test('refresh failure retains successful posts and allows retry', () async {
      final original = educationContent();
      final source = FakeEducationContentDataSource(<EducationContent>[
        original,
      ]);
      final controller = EducationStudioController(source);
      await controller.load();

      source.failNextList = true;
      await controller.refresh();

      expect(controller.items.single.id, original.id);
      expect(controller.loadError, isNotNull);
      expect(controller.isRefreshing, isFalse);

      await controller.refresh();
      expect(controller.items.single.id, original.id);
      expect(controller.loadError, isNull);
      expect(source.listCalls, 3);
      controller.dispose();
    });

    test(
      'backend eligibility denial clears prior content and disables authoring',
      () async {
        final source = FakeEducationContentDataSource(<EducationContent>[
          educationContent(),
        ]);
        final controller = EducationStudioController(source);
        await controller.load();

        source.nextListFailure = const AuthFailure(
          type: AuthFailureType.forbidden,
          message:
              'Education posts are available to active, verified medical doctors.',
          statusCode: 403,
        );
        await controller.refresh();

        expect(controller.items, isEmpty);
        expect(controller.authoringUnavailable, isTrue);
        expect(controller.hasLoaded, isFalse);
        controller.dispose();
      },
    );

    test(
      'duplicate draft mutations serialize and reload server state',
      () async {
        final source =
            FakeEducationContentDataSource()
              ..createGate = Completer<EducationContent>();
        final controller = EducationStudioController(source);
        final first = controller.createDraft(
          type: EducationContentType.textPost,
          title: 'First',
          body: 'A general education post.',
        );
        final duplicate = await controller.createDraft(
          type: EducationContentType.textPost,
          title: 'Second',
          body: 'Another general education post.',
        );

        expect(duplicate, isNull);
        expect(source.createCalls, 1);
        source.createGate!.complete(
          educationContent(title: 'First', body: 'A general education post.'),
        );
        final created = await first;

        expect(created?.title, 'First');
        expect(controller.items.single.title, 'First');
        expect(source.listCalls, 1);
        controller.dispose();
      },
    );

    test(
      'reconciles a draft saved before a network response was lost',
      () async {
        final source =
            FakeEducationContentDataSource()
              ..commitThenFailCreate = true
              ..nextCreateFailure = const AuthFailure(
                type: AuthFailureType.network,
                message: 'Connection interrupted.',
              );
        final controller = EducationStudioController(source);

        final created = await controller.createDraft(
          type: EducationContentType.textPost,
          title: 'Heart health',
          body: 'General education.',
        );

        expect(source.createCalls, 1);
        expect(created?.id, 'created-1');
        expect(controller.items.single.id, 'created-1');
        expect(controller.hasUncertainCreate, isFalse);
        expect(controller.actionError, isNull);
        controller.dispose();
      },
    );

    test('blocks ambiguous duplicate until explicit retry', () async {
      final source =
          FakeEducationContentDataSource()
            ..nextCreateFailure = const AuthFailure(
              type: AuthFailureType.network,
              message: 'Connection interrupted.',
            )
            ..failNextList = true;
      final controller = EducationStudioController(source);
      const type = EducationContentType.textPost;

      final first = await controller.createDraft(
        type: type,
        title: 'Heart health',
        body: 'General education.',
      );
      final blocked = await controller.createDraft(
        type: type,
        title: 'Heart health',
        body: 'General education.',
      );

      expect(first, isNull);
      expect(blocked, isNull);
      expect(source.createCalls, 1);
      expect(controller.hasUncertainCreate, isTrue);

      final retried = await controller.retryUncertainCreate();
      expect(retried, isNotNull);
      expect(source.createCalls, 2);
      expect(controller.hasUncertainCreate, isFalse);
      controller.dispose();
    });

    test('later refresh reconciles an ambiguous draft before retry', () async {
      final source =
          FakeEducationContentDataSource()
            ..commitThenFailCreate = true
            ..nextCreateFailure = const AuthFailure(
              type: AuthFailureType.network,
              message: 'Connection interrupted.',
            )
            ..failNextList = true;
      final controller = EducationStudioController(source);

      final first = await controller.createDraft(
        type: EducationContentType.textPost,
        title: 'Heart health',
        body: 'General education.',
      );
      expect(first, isNull);
      expect(controller.hasUncertainCreate, isTrue);

      await controller.refresh();
      expect(controller.hasUncertainCreate, isFalse);
      expect(controller.items.single.id, 'created-1');

      final resumed = await controller.createDraft(
        type: EducationContentType.textPost,
        title: 'Heart health',
        body: 'General education.',
      );
      expect(resumed?.id, 'created-1');
      expect(source.createCalls, 1);
      controller.dispose();
    });

    test(
      'late initial response cannot replace a post-mutation refresh',
      () async {
        final originalLoad = Completer<void>();
        final source =
            FakeEducationContentDataSource()..listGates.add(originalLoad);
        final controller = EducationStudioController(source);
        final staleLoad = controller.load();

        final created = await controller.createDraft(
          type: EducationContentType.textPost,
          title: 'Current post',
          body: 'Current backend-owned content.',
        );
        expect(created, isNotNull);
        expect(controller.items.single.title, 'Current post');
        expect(source.listCalls, 2);

        originalLoad.complete();
        await staleLoad;
        expect(controller.items.single.title, 'Current post');
        controller.dispose();
      },
    );

    test('dispose cancels pending list and ignores late completion', () async {
      final source =
          FakeEducationContentDataSource()..listGate = Completer<void>();
      final controller = EducationStudioController(source);
      var notifications = 0;
      controller.addListener(() => notifications++);
      final pending = controller.load();
      final beforeDispose = notifications;

      controller.dispose();
      source.listGate!.complete();
      await pending;

      expect(notifications, beforeDispose);
      expect(controller.items, isEmpty);
    });

    test(
      'uploaded video retains rejected lifecycle until resubmission',
      () async {
        final rejected = educationContent(
          type: EducationContentType.shortVideo,
          status: 'REJECTED',
          body: null,
          caption: 'A short caption',
        );
        final source = FakeEducationContentDataSource(<EducationContent>[
          rejected,
        ]);
        final controller = EducationStudioController(source);
        await controller.load();

        final uploaded = await controller.uploadVideo(
          contentId: rejected.id,
          fileName: 'clip.mp4',
          bytes: Uint8List.fromList(<int>[1, 2]),
        );

        expect(uploaded, isTrue);
        expect(source.uploadCalls, 1);
        expect(controller.items.single.status, 'REJECTED');
        expect(controller.items.single.canSubmit, isTrue);
        controller.dispose();
      },
    );

    test(
      'submission changes state only after repository confirmation',
      () async {
        final draft = educationContent();
        final source = FakeEducationContentDataSource(<EducationContent>[
          draft,
        ]);
        final controller = EducationStudioController(source);
        await controller.load();

        final submitted = await controller.submit(draft);

        expect(submitted, isTrue);
        expect(source.submitCalls, 1);
        expect(controller.items.single.status, 'PENDING_REVIEW');
        expect(controller.notice, 'Submitted for professional review.');
        controller.dispose();
      },
    );

    test(
      'confirmed resubmission clears rejection note if refresh fails',
      () async {
        final rejected = educationContent(
          status: 'REJECTED',
          rejectionCode: 'NEEDS_REVISION',
        );
        final source = FakeEducationContentDataSource(<EducationContent>[
            rejected,
          ])
          ..listFailureAfterSubmit = const AuthFailure(
            type: AuthFailureType.server,
            message: 'Refresh failed.',
          );
        final controller = EducationStudioController(source);
        await controller.load();

        expect(await controller.submit(rejected), isTrue);
        expect(controller.items.single.status, 'PENDING_REVIEW');
        expect(controller.items.single.rejectionCode, isNull);
        expect(controller.loadError, isNotNull);
        controller.dispose();
      },
    );
  });
}
