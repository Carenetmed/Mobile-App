import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:media_compress_kit_example/main.dart';

/// Takes the README screenshots with sample media made on the device.
///
/// flutter drive --driver=test_driver/integration_test.dart \
///   --target=integration_test/screenshots_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 900 && finder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finder, findsWidgets);
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
  }

  Future<void> scrollToTop(WidgetTester tester) async {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 5000));
    await settle(tester);
  }

  testWidgets('screenshots', (tester) async {
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await tester.pumpWidget(const CompressApp());
    await settle(tester);

    // Video: a sample, compressed at the default 720p.
    await tester.tap(find.text('Sample'));
    await waitFor(tester, find.textContaining('rotated 90'));
    await waitFor(tester, find.textContaining('Estimated'));
    await scrollTo(tester, find.text('Compress'));
    await tester.tap(find.text('Compress'));
    await waitFor(
      tester,
      find.textContaining(RegExp(r'Compressing… [2-7]\d%')),
    );
    await binding.takeScreenshot('video_progress');
    await waitFor(tester, find.text('Compressed'));
    await scrollTo(tester, find.textContaining('Took'));
    await binding.takeScreenshot('video_result');

    // Image: a 12 megapixel sample photo, with its size estimate.
    await scrollToTop(tester);
    await tester.tap(find.text('Image'));
    await settle(tester);
    await tester.tap(find.text('Sample'));
    await waitFor(tester, find.textContaining('image/jpeg'));
    await waitFor(tester, find.textContaining('Estimated'));
    await scrollTo(tester, find.text('Compress'));
    await tester.tap(find.text('Compress'));
    await waitFor(tester, find.text('Compressed'));
    await scrollTo(tester, find.textContaining('Took'));
    await binding.takeScreenshot('image_result');

    // Batch: photos, a graphic and a video together.
    await scrollToTop(tester);
    await tester.tap(find.text('Batch'));
    await settle(tester);
    await tester.tap(find.text('Sample'));
    await waitFor(tester, find.text('4 files'));
    await settle(tester);
    await scrollTo(tester, find.text('Compress all'));
    await tester.tap(find.text('Compress all'));
    await waitFor(tester, find.text('Batch done'));
    await scrollToTop(tester);
    await binding.takeScreenshot('batch');
  });
}
