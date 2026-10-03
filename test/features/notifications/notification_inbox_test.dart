import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:app_t/features/Messaging/presentation/pages/Notification.dart';
import 'package:app_t/features/Notifications/domain/entities/notification_models.dart';
import 'package:app_t/features/Notifications/data/services/firebase_notification_transport.dart';
import 'package:app_t/features/Notifications/presentation/pages/notification_preferences_page.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_coordinator.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_inbox_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notification_test_fakes.dart';

void main() {
  test('inbox serializes repeated initial loads', () async {
    final repository = FakeNotificationRepository();
    final pending = Completer<NotificationPage>();
    repository.listCompleter = pending;
    final controller = NotificationInboxController(
      repository: repository,
      coordinator: _coordinator(repository),
    );

    final first = controller.load();
    final second = controller.load();
    await Future<void>.delayed(Duration.zero);
    expect(repository.listCalls, 1);

    pending.complete(const NotificationPage(items: [], hasMore: false));
    await Future.wait([first, second]);
    controller.dispose();
  });

  test('refresh failure preserves previously loaded inbox data', () async {
    final item = notificationTestItem();
    final repository = FakeNotificationRepository(items: [item]);
    final controller = NotificationInboxController(
      repository: repository,
      coordinator: _coordinator(repository),
    );
    await controller.load();

    repository.listFailure = StateError('backend unavailable');
    await controller.load(refresh: true);

    expect(controller.items, [item]);
    expect(
      controller.errorMessage,
      'Notifications are unavailable. Please try again.',
    );
    controller.dispose();
  });

  test(
    'mark one and mark all update only after repository confirmation',
    () async {
      final repository = FakeNotificationRepository(
        items: [
          notificationTestItem(id: 'one'),
          notificationTestItem(id: 'two'),
        ],
      )..unread = 2;
      final controller = NotificationInboxController(
        repository: repository,
        coordinator: _coordinator(repository),
      );
      await controller.load();

      await controller.open(controller.items.first);
      expect(repository.markedRead, ['one']);
      expect(controller.items.first.isRead, isTrue);

      await controller.markAllRead();
      expect(repository.markAllCalls, 1);
      expect(controller.items.every((item) => item.isRead), isTrue);
      controller.dispose();
    },
  );

  test('preference failure rolls back the optimistic toggle', () async {
    final repository = FakeNotificationRepository();
    final controller = NotificationPreferencesController(
      repository: repository,
    );
    await controller.load();
    repository.preferencesFailure = StateError('save failed');

    await controller.update(
      NotificationCategory.appointments,
      pushEnabled: false,
    );

    expect(
      controller.preferences
          .firstWhere(
            (item) => item.category == NotificationCategory.appointments,
          )
          .pushEnabled,
      isTrue,
    );
    expect(controller.errorMessage, isNotNull);
    controller.dispose();
  });

  testWidgets(
    'empty backend inbox is honest and offers contextual permission',
    (tester) async {
      final repository = FakeNotificationRepository();
      final coordinator = _coordinator(repository);

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsPage(
            repository: repository,
            coordinator: coordinator,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No notifications yet'), findsOneWidget);
      expect(find.text('Stay updated'), findsOneWidget);
      expect(find.textContaining('Dr.'), findsNothing);
      expect(find.textContaining('dummy'), findsNothing);

      await tester.tap(find.text('Allow notifications'));
      await tester.pumpAndSettle();
      expect(coordinator.permission.name, 'authorized');
    },
  );

  testWidgets('inbox renders backend fields and marks a row read', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = FakeNotificationRepository(
      items: [notificationTestItem(title: 'Appointment accepted')],
    )..unread = 1;
    final coordinator = _coordinator(repository);

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsPage(
          repository: repository,
          coordinator: coordinator,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Appointment accepted'), findsOneWidget);
    expect(find.textContaining('Open CareNet'), findsOneWidget);
    final unreadLabel = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == 'Unread',
    );
    expect(unreadLabel, findsOneWidget);
    expect(tester.getSemantics(unreadLabel).label, contains('Unread'));
    await tester.tap(find.text('Appointment accepted'));
    await tester.pumpAndSettle();
    expect(repository.markedRead, ['notification-1']);
    expect(unreadLabel, findsNothing);
    semantics.dispose();
  });

  testWidgets('denied push permission links to system settings', (
    tester,
  ) async {
    final repository = FakeNotificationRepository();
    final transport = FakeNotificationTransport(
      permissionValue: NotificationPermissionValue.denied,
    );
    final coordinator = _coordinator(repository, transport: transport);
    addTearDown(coordinator.dispose);
    await coordinator.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsPage(
          repository: repository,
          coordinator: coordinator,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Push notifications are off'), findsOneWidget);
    expect(find.text('No notifications yet'), findsOneWidget);
    await tester.tap(find.text('Open system settings'));
    await tester.pump();
    expect(transport.settingsRequests, 1);
  });

  testWidgets('preferences explain that the durable inbox remains enabled', (
    tester,
  ) async {
    final repository = FakeNotificationRepository();
    await tester.pumpWidget(
      MaterialApp(home: NotificationPreferencesPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('inbox always keeps transactional updates'),
      findsOneWidget,
    );
    expect(find.text('Appointments'), findsOneWidget);
    expect(find.text('Push'), findsWidgets);
    expect(find.text('Email'), findsWidgets);
  });

  testWidgets('preferences remain reachable at compact width with 2x text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2),
          ),
          child: child!,
        ),
        home: NotificationPreferencesPage(
          repository: FakeNotificationRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    for (final category in NotificationCategory.values) {
      await tester.scrollUntilVisible(
        find.text(category.label),
        140,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text(category.label), findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    final lastSwitch = find.byType(SwitchListTile).last;
    expect(find.text('Push'), findsWidgets);
    expect(find.text('Email'), findsWidgets);
    expect(tester.getSize(lastSwitch).height, greaterThanOrEqualTo(48));
    expect(
      tester.getSemantics(lastSwitch).getSemanticsData().hasAction(
        SemanticsAction.tap,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}

NotificationCoordinator _coordinator(
  FakeNotificationRepository repository, {
  FakeNotificationTransport? transport,
}) {
  return NotificationCoordinator(
    repository: repository,
    installationStore: FakeNotificationInstallationStore(),
    transport: transport ?? FakeNotificationTransport(),
    navigatorKey: GlobalKey<NavigatorState>(),
    metadataLoader:
        () async => const NotificationDeviceMetadata(
          platform: 'ANDROID',
          appId: 'com.carenet.app',
          appVersion: '1.0.0+1',
          locale: 'en_NG',
        ),
  );
}
