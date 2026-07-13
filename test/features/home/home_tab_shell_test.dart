import 'package:app_t/features/Home/presentation/pages/home.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpHome(WidgetTester tester) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: const Scaffold(drawer: Drawer(), body: Home()),
            routes: {
              RouteName.messages:
                  (_) => const Scaffold(body: Text('messages-screen')),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home tab shows messages content', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.byType(Tab).at(1));
    await tester.pumpAndSettle();
    expect(find.text('Messages at a glance'), findsOneWidget);
    expect(find.text('Reply to your care plan question'), findsOneWidget);
  });

  testWidgets('home messages tab routes into full inbox', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.byType(Tab).at(1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open full inbox'));
    await tester.pumpAndSettle();
    expect(find.text('messages-screen'), findsOneWidget);
  });

  testWidgets('home tab shows articles content', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.byType(Tab).at(2));
    await tester.pumpAndSettle();
    expect(
      find.text('What to monitor after an intense workout'),
      findsOneWidget,
    );
    expect(
      find.text('Five easy breakfast upgrades for steadier energy'),
      findsOneWidget,
    );
  });
}
