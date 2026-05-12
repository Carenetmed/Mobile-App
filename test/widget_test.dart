import 'package:app_t/features/Home/presentation/pages/articles_tab.dart';
import 'package:app_t/features/Home/presentation/pages/comment_on_feed_page.dart';
import 'package:app_t/features/Home/presentation/pages/feed_tab.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
import 'package:app_t/features/Messaging/presentation/pages/notification_center_page.dart';
import 'package:app_t/features/Reminders/presentation/pages/reminder_page.dart';
import 'package:app_t/features/Settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpPhoneShell(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(430, 932),
      builder: (context, _) {
        return MaterialApp(home: Scaffold(body: child));
      },
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Settings screen renders expected sections', (tester) async {
    await _pumpPhoneShell(tester, const SettingsPage());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Deactivate account'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
  });

  testWidgets('Notification center renders key content', (tester) async {
    await _pumpPhoneShell(tester, const NotificationCenterPage());

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Your appointment is booked'), findsOneWidget);
  });

  testWidgets('Reminder landing page renders exported overview', (
    tester,
  ) async {
    await _pumpPhoneShell(tester, const ReminderPage());

    expect(find.text('Reminder'), findsOneWidget);
    expect(find.text('Friday, February, 07, 2025'), findsOneWidget);
  });

  testWidgets('Feed tab renders social posts and counts', (tester) async {
    await _pumpPhoneShell(tester, const FeedTab());

    expect(find.text('Lagbaja Tamedu'), findsWidgets);
    expect(find.text('Follow'), findsWidgets);
    expect(find.text('22k'), findsWidgets);
    expect(find.text('252k'), findsWidgets);
  });

  testWidgets('Comment on feed renders composer and post actions', (
    tester,
  ) async {
    await _pumpPhoneShell(tester, const CommentOnFeedPage());

    expect(find.text('Feed'), findsWidgets);
    expect(find.text('Messages'), findsWidgets);
    expect(find.text('Articles'), findsWidgets);
    expect(find.text('What do you think?'), findsOneWidget);
    expect(find.text('React'), findsOneWidget);
    expect(find.text('Comment'), findsWidgets);
  });

  testWidgets('Messages page renders reply card', (tester) async {
    await _pumpPhoneShell(tester, const MessagesPage());

    expect(find.text('Messages'), findsWidgets);
    expect(find.text('Reply him now'), findsOneWidget);
    expect(find.text('Appointment'), findsOneWidget);
  });

  testWidgets('Articles tab renders article and podcast switcher', (
    tester,
  ) async {
    await _pumpPhoneShell(
      tester,
      ArticlesTab(embedded: false, onOpenArticle: (_) {}),
    );

    expect(find.text('Articles'), findsWidgets);
    expect(find.text('Podcast'), findsOneWidget);
    expect(
      find.text('The Future of Healthcare: AI & Robiotics in Medicine'),
      findsWidgets,
    );
  });
}
