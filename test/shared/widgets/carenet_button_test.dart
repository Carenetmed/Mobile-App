import 'dart:ui' show SemanticsAction;

import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpButton(
  WidgetTester tester, {
  required CarenetButton button,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (context, _) => MaterialApp(
            home: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: Scaffold(
                body: Padding(padding: const EdgeInsets.all(16), child: button),
              ),
            ),
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

    testWidgets('button has a labelled semantic action and 48dp target', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpButton(
        tester,
        button: CarenetButton(label: 'Continue', onPressed: () {}),
      );

      final node = tester.getSemantics(find.byType(CarenetButton));
      final targetSize = tester.getSize(find.byType(InkWell));

      expect(node.label, 'Continue');
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      expect(targetSize.width, greaterThanOrEqualTo(48));
      expect(targetSize.height, greaterThanOrEqualTo(48));
      semantics.dispose();
    });

    testWidgets('button grows for enlarged text without layout exceptions', (
      tester,
    ) async {
      await _pumpButton(
        tester,
        button: CarenetButton(
          label: 'Request this appointment',
          onPressed: () {},
        ),
        textScaler: TextScaler.linear(2),
      );

      expect(tester.getSize(find.byType(InkWell)).height, greaterThan(48));
      expect(tester.takeException(), isNull);
    });
  });
}
