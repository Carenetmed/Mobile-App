import 'dart:ui' show SemanticsAction;

import 'package:app_t/features/Home/presentation/pages/reminder_shell.dart';
import 'package:app_t/features/Home/presentation/pages/schedules_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Reminder calendar stays usable at compact width and large text',
    (tester) async {
      await _useCompactViewport(tester);

      await tester.pumpWidget(_accessibleApp(const ReminderShellPage()));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarDatePicker), findsOneWidget);
      expect(find.byKey(const Key('reminder-selected-date')), findsOneWidget);
      final nextDate = DateTime.now().add(const Duration(days: 1));
      await tester.tap(find.text(nextDate.day.toString()));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('${nextDate.day}, ${nextDate.year}'),
        findsOneWidget,
      );
      final emptyState = find.text('You have no reminders for this date.');
      await tester.scrollUntilVisible(
        emptyState,
        120,
        scrollable: find.byType(Scrollable).last,
      );
      expect(emptyState, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Schedules disclosure announces expanded state accessibly', (
    tester,
  ) async {
    await _useCompactViewport(tester);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(_accessibleApp(const SchedulesShellPage()));
    await tester.pumpAndSettle();

    final disclosure = find.byKey(const Key('schedule-event-disclosure'));
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Doctors Without Border Event'), findsOneWidget);

    var data = tester.getSemantics(disclosure).getSemanticsData();
    expect(data.label, 'Doctors Without Border Event details');
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    expect(data.flagsCollection.isExpanded.name, 'isTrue');

    await tester.tap(find.text('Doctors Without Border Event'));
    await tester.pumpAndSettle();

    data = tester.getSemantics(disclosure).getSemanticsData();
    expect(data.flagsCollection.isExpanded.name, 'isFalse');
    expect(find.text('Frequency'), findsNothing);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}

Future<void> _useCompactViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _accessibleApp(Widget page) {
  return ScreenUtilInit(
    designSize: const Size(430, 932),
    builder:
        (_, __) => MaterialApp(
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
          home: page,
        ),
  );
}
