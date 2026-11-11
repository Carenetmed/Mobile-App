import 'dart:typed_data';

import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/presentation/pages/education_studio_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'education_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('doctor can create and submit a text draft for review', (
    tester,
  ) async {
    final source = FakeEducationContentDataSource();
    await _pumpStudio(tester, source);

    await tester.enterText(find.byType(TextField).at(0), 'Heart health');
    await tester.enterText(
      find.byType(TextField).at(1),
      'General information about healthy habits.',
    );
    await tester.enterText(find.byType(TextField).at(2), 'A short caption.');
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();

    expect(source.createCalls, 1);
    expect(source.items.single.caption, 'A short caption.');
    expect(find.text('Heart health'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Draft saved.'), findsOneWidget);
    expect(find.text('Submit for review'), findsOneWidget);

    await tester.ensureVisible(find.text('Submit for review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit for review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(source.submitCalls, 1);
    expect(find.text('In review'), findsOneWidget);
    expect(find.text('Submitted for professional review.'), findsOneWidget);
  });

  testWidgets(
    'short-video draft uploads using injected picker and backend receipt',
    (tester) async {
      final source = FakeEducationContentDataSource();
      final picker = _FakeVideoPicker();
      await _pumpStudio(tester, source, videoPicker: picker);

      await tester.tap(find.text('Short video'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Sleep basics');
      await tester.enterText(find.byType(TextField).at(1), 'General tips');
      await tester.tap(find.text('Save draft'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Add video'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add video'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose a video'));
      await tester.pumpAndSettle();

      expect(picker.lastSource, ImageSource.gallery);
      expect(source.uploadCalls, 1);
      expect(find.textContaining('Video uploaded · 30 sec'), findsOneWidget);
      expect(find.text('Submit for review'), findsOneWidget);
    },
  );

  testWidgets('initial load failure offers retry instead of empty success', (
    tester,
  ) async {
    final source = FakeEducationContentDataSource()..failNextList = true;
    await _pumpStudio(tester, source);

    expect(
      find.text('Could not load your education posts. Please retry.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('No education posts yet'), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(source.listCalls, 2);
    expect(find.text('No education posts yet'), findsOneWidget);
  });

  testWidgets(
    'ambiguous draft save requires an explicit duplicate-risk retry',
    (tester) async {
      final source =
          FakeEducationContentDataSource()
            ..nextCreateFailure = const AuthFailure(
              type: AuthFailureType.network,
              message: 'Connection interrupted.',
            )
            ..failNextList = true;
      await _pumpStudio(tester, source);

      await tester.enterText(find.byType(TextField).at(0), 'Heart health');
      await tester.enterText(
        find.byType(TextField).at(1),
        'General education.',
      );
      await tester.tap(find.text('Save draft'));
      await tester.pumpAndSettle();

      expect(source.createCalls, 1);
      expect(find.text('Retry save anyway'), findsOneWidget);
      expect(
        find.textContaining('Retrying may create a duplicate.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Retry save anyway'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('can create a duplicate draft'),
        findsOneWidget,
      );
      await tester.tap(find.text('Retry anyway'));
      await tester.pumpAndSettle();

      expect(source.createCalls, 2);
      expect(find.text('Draft saved.'), findsOneWidget);
    },
  );

  testWidgets('backend eligibility denial hides authoring controls', (
    tester,
  ) async {
    final source =
        FakeEducationContentDataSource()
          ..nextListFailure = const AuthFailure(
            type: AuthFailureType.forbidden,
            message:
                'Education posts are available to active, verified medical doctors.',
            statusCode: 403,
          );
    await _pumpStudio(tester, source);

    expect(
      find.text('This account cannot manage doctor education posts.'),
      findsNothing,
    );
    expect(
      find.text(
        'Education posts are available to active, verified medical doctors.',
      ),
      findsOneWidget,
    );
    expect(find.text('Create a draft'), findsNothing);
    expect(find.text('No education posts yet'), findsNothing);
  });
}

Future<void> _pumpStudio(
  WidgetTester tester,
  FakeEducationContentDataSource source, {
  EducationVideoPicker? videoPicker,
}) async {
  tester.view.physicalSize = const Size(430, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(430, 1000),
      builder:
          (_, __) => MaterialApp(
            theme: ThemeData(splashFactory: NoSplash.splashFactory),
            home: EducationStudioShellPage(
              repository: source,
              videoPicker: videoPicker,
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeVideoPicker implements EducationVideoPicker {
  ImageSource? lastSource;

  @override
  Future<EducationPickedVideo?> pick(ImageSource source) async {
    lastSource = source;
    return EducationPickedVideo(
      name: 'lesson.mp4',
      bytes: Uint8List.fromList(<int>[1, 2, 3]),
    );
  }
}
