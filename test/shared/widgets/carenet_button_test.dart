import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpButton(
  WidgetTester tester, {
  required CarenetButton button,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder: (_, __) => MaterialApp(
        home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: button)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('CarenetButton', () {
    testWidgets('primary enabled invokes onPressed', (tester) async {
      var tapped = false;
      await _pumpButton(
        tester,
        button: CarenetButton(
          label: 'Continue',
          onPressed: () => tapped = true,
          type: CarenetButtonType.primary,
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('primary disabled does not invoke onPressed', (tester) async {
      var tapped = false;
      await _pumpButton(
        tester,
        button: CarenetButton(
          label: 'Continue',
          onPressed: null,
          type: CarenetButtonType.primary,
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('outline enabled shows brand border color', (tester) async {
      await _pumpButton(
        tester,
        button: CarenetButton(
          label: 'Skip',
          onPressed: () {},
          type: CarenetButtonType.outline,
        ),
      );

      final ink = tester.widget<Ink>(find.byType(Ink));
      final decoration = ink.decoration! as BoxDecoration;
      final border = decoration.border! as Border;
      expect(border.top.color, CarenetColors.brand);
    });

    testWidgets('outline disabled does not invoke onPressed', (tester) async {
      var tapped = false;
      await _pumpButton(
        tester,
        button: CarenetButton(
          label: 'Skip',
          onPressed: null,
          type: CarenetButtonType.outline,
        ),
      );

      await tester.tap(find.text('Skip'));
      await tester.pump();
      expect(tapped, isFalse);
    });
  });
}
