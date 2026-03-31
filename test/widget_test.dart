import 'package:app_t/features/Settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Settings screen renders expected sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, child) {
          return const MaterialApp(home: SettingsPage());
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Settings & Privacy'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Privacy & safety'), findsOneWidget);
    expect(find.text('Help & support'), findsOneWidget);
    expect(find.text('Deactivate account'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
  });
}
