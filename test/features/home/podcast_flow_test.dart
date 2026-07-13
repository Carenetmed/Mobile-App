import 'package:app_t/features/Home/presentation/pages/podcast_shell.dart';
import 'package:app_t/features/Home/presentation/state/podcast_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpPodcast(WidgetTester tester) async {
  PodcastLocalStore.reset();
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder: (_, __) => const MaterialApp(home: PodcastShellPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('podcast screen shows local episode content', (tester) async {
    await _pumpPodcast(tester);

    expect(find.text('Podcast'), findsWidgets);
    expect(
      find.text('The Future of Healthcare: AI & Robotics in Medicine'),
      findsOneWidget,
    );
    expect(find.text('Building calmer daily health routines'), findsOneWidget);
    expect(find.text('Search keywords'), findsOneWidget);
  });

  testWidgets('watch action marks an episode locally', (tester) async {
    await _pumpPodcast(tester);

    await tester.tap(find.text('Watch').first);
    await tester.pumpAndSettle();

    expect(find.text('Watched locally'), findsOneWidget);
  });
}
