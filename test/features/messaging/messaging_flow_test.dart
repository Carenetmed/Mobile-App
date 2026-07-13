import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/pages/reminder_shell.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
import 'package:app_t/features/Messaging/presentation/pages/Notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpMessages(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: const MessagesPage(),
      routes: {
        RouteName.chat: (_) => const Scaffold(body: Text('chat-screen')),
      },
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpNotifications(WidgetTester tester) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(430, 932),
      builder:
          (_, __) => MaterialApp(
            home: const NotificationsPage(),
            routes: {
              RouteName.medicalEdit:
                  (_) => const Scaffold(body: Text('medical-edit-screen')),
              RouteName.messages:
                  (_) => const Scaffold(body: Text('messages-screen')),
              RouteName.dashboard:
                  (_) => const Scaffold(body: Text('dashboard-screen')),
              RouteName.appointments:
                  (_) => const Scaffold(body: Text('appointments-screen')),
              RouteName.readings:
                  (_) => const Scaffold(body: Text('readings-screen')),
              RouteName.articles:
                  (_) => const Scaffold(body: Text('articles-screen')),
              RouteName.podcast:
                  (_) => const Scaffold(body: Text('podcast-screen')),
              RouteName.emergency:
                  (_) => const Scaffold(body: Text('emergency-screen')),
              RouteName.reminder: (_) => const ReminderShellPage(),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('messages list routes into chat', (tester) async {
    await _pumpMessages(tester);

    await tester.tap(find.text('Dr. Lagbaja has replied your message.'));
    await tester.pumpAndSettle();

    expect(find.text('chat-screen'), findsOneWidget);
  });

  testWidgets('notifications page no longer renders a fake bottom nav', (
    tester,
  ) async {
    await _pumpNotifications(tester);

    expect(find.text('Your appointment is booked'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Search'), findsNothing);
    expect(find.text('Articles'), findsNothing);
    expect(find.text('Appointments'), findsNothing);
    expect(find.text('Alert'), findsNothing);
  });

  testWidgets('notifications opens the local reminder calendar', (
    tester,
  ) async {
    await _pumpNotifications(tester);

    await tester.tap(find.byTooltip('Reminders'));
    await tester.pumpAndSettle();

    expect(find.text('Reminder'), findsOneWidget);
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    expect(find.text('You have no reminders for this date.'), findsOneWidget);

    final calendar = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    final nextDate = calendar.initialDate!.add(const Duration(days: 1));
    calendar.onDateChanged(nextDate);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reminder-selected-date')), findsOneWidget);
    expect(
      find.textContaining('${nextDate.day}, ${nextDate.year}'),
      findsOneWidget,
    );
  });

  testWidgets('notification category tabs filter visible items honestly', (
    tester,
  ) async {
    await _pumpNotifications(tester);

    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(find.text('Dr. Lagbaja has replied your message.'), findsOneWidget);
    expect(find.text('Your appointment is booked'), findsNothing);

    await tester.tap(find.text('Appointment'));
    await tester.pumpAndSettle();
    expect(find.text('Your appointment is booked'), findsOneWidget);
    expect(
      find.text('Update your reading, its been 5 days already'),
      findsOneWidget,
    );
    expect(find.text('Dr. Lagbaja has replied your message.'), findsNothing);

    await tester.tap(find.text('Events'));
    await tester.pumpAndSettle();
    expect(
      find.text('360 Club event is coming up today by 6pm'),
      findsOneWidget,
    );
    expect(find.text('Dr. Tamedu has published a new article'), findsOneWidget);
    expect(find.text('Complete your profile'), findsNothing);
  });

  testWidgets('payment tab stays disabled until payment notifications exist', (
    tester,
  ) async {
    await _pumpNotifications(tester);

    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();

    expect(find.text('Your appointment is booked'), findsOneWidget);
    expect(
      find.text('This category will open up when its feature area is built.'),
      findsNothing,
    );
  });

  testWidgets('profile notification routes to medical edit', (tester) async {
    await _pumpNotifications(tester);

    await tester.tap(find.text('Complete your profile'));
    await tester.pumpAndSettle();
    expect(find.text('medical-edit-screen'), findsOneWidget);
  });

  testWidgets('message notification routes to messages', (tester) async {
    await _pumpNotifications(tester);

    await tester.tap(find.text('Dr. Lagbaja has replied your message.'));
    await tester.pumpAndSettle();
    expect(find.text('messages-screen'), findsOneWidget);
  });

  testWidgets('feed notification routes to dashboard', (tester) async {
    await _pumpNotifications(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('You are missing updates'));
    await tester.pumpAndSettle();
    expect(find.text('dashboard-screen'), findsOneWidget);
  });

  testWidgets('appointment notification routes to appointments shell', (
    tester,
  ) async {
    await _pumpNotifications(tester);

    await tester.tap(find.text('Your appointment is booked'));
    await tester.pumpAndSettle();

    expect(find.text('appointments-screen'), findsOneWidget);
  });

  testWidgets('reading notification routes to readings screen', (tester) async {
    await _pumpNotifications(tester);

    await tester.tap(find.text('Appointment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update your reading, its been 5 days already'));
    await tester.pumpAndSettle();

    expect(find.text('readings-screen'), findsOneWidget);
  });

  testWidgets('article notification routes to articles screen', (tester) async {
    await _pumpNotifications(tester);

    await tester.tap(find.text('Events'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dr. Tamedu has published a new article'));
    await tester.pumpAndSettle();

    expect(find.text('articles-screen'), findsOneWidget);
  });

  testWidgets('emergency notification routes to emergency screen', (
    tester,
  ) async {
    await _pumpNotifications(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Your emergency request is approved.'));
    await tester.pumpAndSettle();

    expect(find.text('emergency-screen'), findsOneWidget);
  });

  testWidgets('podcast notification routes to podcast screen', (tester) async {
    await _pumpNotifications(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dr. Lakasegbe has published a new podcast'));
    await tester.pumpAndSettle();

    expect(find.text('podcast-screen'), findsOneWidget);
  });
}
