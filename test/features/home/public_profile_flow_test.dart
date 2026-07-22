import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/pages/appointments_shell.dart';
import 'package:app_t/features/Home/presentation/pages/public_profile_shell.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpPublicProfile(WidgetTester tester) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: const PublicProfileShellPage(),
            routes: <String, WidgetBuilder>{
              RouteName.messages: (_) => const MessagesPage(),
              RouteName.bookAppointment:
                  (_) => const BookAppointmentShellPage(),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'public profile screen shows local professional profile content',
    (tester) async {
      await _pumpPublicProfile(tester);

      expect(find.text('Lagbaja Omo Tamedu'), findsOneWidget);
      expect(find.text('Resident Doctor, Luth'), findsOneWidget);
      expect(find.text('Epe, Lagos'), findsOneWidget);
      expect(find.text('Articles'), findsOneWidget);
      expect(find.text('Specialization'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('About me'), findsOneWidget);
    },
  );

  testWidgets('message action opens honest consultation inbox', (tester) async {
    await _pumpPublicProfile(tester);

    await tester.tap(find.text('Message'));
    await tester.pumpAndSettle();

    expect(find.text('Messages'), findsWidgets);
    expect(find.text('No appointment conversations yet'), findsOneWidget);
    expect(find.text('Dr. Lagbaja has replied your message.'), findsNothing);
  });

  testWidgets('schedule action opens booking route', (tester) async {
    await _pumpPublicProfile(tester);

    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();

    expect(find.text('Book Appointment'), findsOneWidget);
    expect(find.text('Review request details'), findsOneWidget);
  });

  testWidgets('deferred public profile actions are disabled', (tester) async {
    await _pumpPublicProfile(tester);

    final portfolioButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Portfolio'),
    );
    final podcastButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Podcast'),
    );
    final shareButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Share'),
    );

    expect(portfolioButton.onPressed, isNull);
    expect(podcastButton.onPressed, isNull);
    expect(shareButton.onPressed, isNull);
  });
}
