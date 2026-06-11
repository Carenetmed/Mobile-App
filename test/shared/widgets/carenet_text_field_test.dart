import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpField(
  WidgetTester tester, {
  required CarenetTextField field,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: Scaffold(
              body: Padding(padding: const EdgeInsets.all(16), child: field),
            ),
          ),
    ),
  );
  await tester.pump();
}

OutlineInputBorder _enabledBorder(WidgetTester tester) {
  final decorator = tester.widget<InputDecorator>(find.byType(InputDecorator));
  return decorator.decoration.enabledBorder! as OutlineInputBorder;
}

InputDecoration _decoration(WidgetTester tester) {
  final decorator = tester.widget<InputDecorator>(find.byType(InputDecorator));
  return decorator.decoration;
}

void main() {
  group('CarenetTextField', () {
    testWidgets('renders label and hint text', (tester) async {
      await _pumpField(
        tester,
        field: const CarenetTextField(label: 'First Name', hintText: 'Belrah'),
      );

      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Belrah'), findsOneWidget);
    });

    testWidgets('disabled state uses neutral border and fill', (tester) async {
      await _pumpField(
        tester,
        field: const CarenetTextField(
          label: 'Phone',
          hintText: '000',
          enabled: false,
        ),
      );

      final border = _enabledBorder(tester);
      final decoration = _decoration(tester);
      expect(border.borderSide.color, CarenetColors.neutral200);
      expect(decoration.fillColor, CarenetColors.neutral100);
    });

    testWidgets('valid state uses success border', (tester) async {
      await _pumpField(
        tester,
        field: const CarenetTextField(
          label: 'First Name',
          hintText: 'Belrah',
          validationState: CarenetTextFieldValidationState.valid,
        ),
      );

      final border = _enabledBorder(tester);
      expect(border.borderSide.color, CarenetColors.success100);
    });

    testWidgets('invalid state shows error text and error border', (
      tester,
    ) async {
      await _pumpField(
        tester,
        field: const CarenetTextField(
          label: 'First Name',
          hintText: 'Belrah',
          validationState: CarenetTextFieldValidationState.invalid,
          errorText: 'ERROR MESSAGE',
        ),
      );

      final border = _enabledBorder(tester);
      final decoration = _decoration(tester);
      expect(border.borderSide.color, CarenetColors.error100);
      expect(decoration.errorText, 'ERROR MESSAGE');
    });

    testWidgets('entered state uses body text color', (tester) async {
      final controller = TextEditingController(text: 'Belrah');
      addTearDown(controller.dispose);
      await _pumpField(
        tester,
        field: CarenetTextField(
          label: 'First Name',
          hintText: 'Belrah',
          controller: controller,
        ),
      );

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.style.color, CarenetColors.neutral700);
    });
  });
}
