import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notification_test_fakes.dart';

void main() {
  testWidgets('registers one installation with bounded non-secret metadata', (
    tester,
  ) async {
    final repository = FakeNotificationRepository()..unread = 4;
    final store = FakeNotificationInstallationStore();
    final transport = FakeNotificationTransport();
    final coordinator = _coordinator(repository, store, transport);
    addTearDown(coordinator.dispose);

    await coordinator.initialize();
    await coordinator.onAuthenticatedSession(notificationTestSession());

    expect(transport.initializeCalls, 1);
    expect(repository.registrationPayloads, hasLength(1));
    expect(repository.registrationPayloads.single, <String, dynamic>{
      'installationId': store.id,
      'platform': 'ANDROID',
      'endpoint': 'fcm-token',
      'endpointKind': 'FCM_REGISTRATION_TOKEN',
      'appId': 'com.carenet.app',
      'appVersion': '1.0.0+1',
      'locale': 'en_NG',
      'permissionState': 'NOT_DETERMINED',
    });
    expect(repository.registrationPayloads.single, isNot(contains('timezone')));
    expect(store.boundUser, 'user-1');
    expect(coordinator.unreadCount, 4);
  });

  testWidgets(
    'account change clears old pending tap and isolates unread state',
    (tester) async {
      final repository = FakeNotificationRepository()..unread = 7;
      final store =
          FakeNotificationInstallationStore()
            ..boundUser = 'user-1'
            ..pendingNotification = 'old-user-notification';
      final coordinator = _coordinator(
        repository,
        store,
        FakeNotificationTransport(),
      );

      repository.session = notificationTestSession(userId: 'user-2');
      await coordinator.onAuthenticatedSession(repository.session);

      expect(store.pendingNotification, isNull);
      expect(store.boundUser, 'user-2');
      expect(coordinator.unreadCount, 7);
    },
  );

  testWidgets('logout unbinds the exact installation and clears local state', (
    tester,
  ) async {
    final repository = FakeNotificationRepository()..unread = 2;
    final store = FakeNotificationInstallationStore();
    final session = notificationTestSession();
    final coordinator = _coordinator(
      repository,
      store,
      FakeNotificationTransport(),
    );
    await coordinator.onAuthenticatedSession(session);
    store.pendingNotification = 'notification-1';

    await coordinator.beforeLogout(session);

    expect(repository.removedInstallations, <String>[store.id]);
    expect(store.boundUser, isNull);
    expect(store.pendingNotification, isNull);
    expect(coordinator.unreadCount, 0);
  });

  testWidgets('owned appointment tap opens only the authoritative route', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final repository = FakeNotificationRepository(
      items: [
        notificationTestItem(
          id: 'notification-appointment',
          entityId: 'appointment-42',
        ),
      ],
    );
    final coordinator = _coordinator(
      repository,
      FakeNotificationInstallationStore(),
      FakeNotificationTransport(),
      navigatorKey: navigatorKey,
    );
    await tester.pumpWidget(_routingApp(navigatorKey));
    await coordinator.onAuthenticatedSession(repository.session);
    await coordinator.markNavigationReady();

    await coordinator.handleTap('notification-appointment');
    await tester.pumpAndSettle();

    expect(find.text('appointment:appointment-42'), findsOneWidget);
    expect(repository.markedRead, <String>['notification-appointment']);
  });

  testWidgets('unknown route code fails closed to the authenticated inbox', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final repository = FakeNotificationRepository(
      items: [
        notificationTestItem(
          id: 'notification-unknown',
          routeCode: 'UNTRUSTED_ROUTE',
          entityId: 'opaque-1',
        ),
      ],
    );
    final coordinator = _coordinator(
      repository,
      FakeNotificationInstallationStore(),
      FakeNotificationTransport(),
      navigatorKey: navigatorKey,
    );
    await tester.pumpWidget(_routingApp(navigatorKey));
    await coordinator.onAuthenticatedSession(repository.session);
    await coordinator.markNavigationReady();

    await coordinator.handleTap('notification-unknown');
    await tester.pumpAndSettle();

    expect(find.text('notification-inbox'), findsOneWidget);
    expect(find.textContaining('opaque-1'), findsNothing);
  });

  testWidgets('tap is retained until session and navigator are available', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final store = FakeNotificationInstallationStore();
    final repository = FakeNotificationRepository(
      items: [
        notificationTestItem(id: 'cold-tap', entityId: 'appointment-cold'),
      ],
    );
    final coordinator = _coordinator(
      repository,
      store,
      FakeNotificationTransport(),
      navigatorKey: navigatorKey,
    );

    await coordinator.handleTap('cold-tap');
    expect(store.pendingNotification, 'cold-tap');

    await tester.pumpWidget(_routingApp(navigatorKey));
    await coordinator.onAuthenticatedSession(repository.session);
    await tester.pumpAndSettle();

    expect(store.pendingNotification, 'cold-tap');
    expect(find.text('home'), findsOneWidget);

    await coordinator.markNavigationReady();
    await tester.pumpAndSettle();

    expect(store.pendingNotification, isNull);
    expect(find.text('appointment:appointment-cold'), findsOneWidget);
  });

  testWidgets('recoverable tap failure preserves intent for session retry', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final store = FakeNotificationInstallationStore();
    final repository = FakeNotificationRepository(
        items: [
          notificationTestItem(id: 'retry-tap', entityId: 'appointment-retry'),
        ],
      )
      ..notificationFailure = const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Session refresh is still in progress.',
        statusCode: 401,
      );
    final coordinator = _coordinator(
      repository,
      store,
      FakeNotificationTransport(),
      navigatorKey: navigatorKey,
    );

    await tester.pumpWidget(_routingApp(navigatorKey));
    await coordinator.onAuthenticatedSession(repository.session);
    await coordinator.markNavigationReady();
    await coordinator.handleTap('retry-tap');
    await tester.pumpAndSettle();

    expect(store.pendingNotification, 'retry-tap');
    expect(find.text('home'), findsOneWidget);

    repository.notificationFailure = null;
    await coordinator.onAuthenticatedSession(repository.session);
    await tester.pumpAndSettle();

    expect(store.pendingNotification, isNull);
    expect(find.text('appointment:appointment-retry'), findsOneWidget);
  });
}

NotificationCoordinator _coordinator(
  FakeNotificationRepository repository,
  FakeNotificationInstallationStore store,
  FakeNotificationTransport transport, {
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return NotificationCoordinator(
    repository: repository,
    installationStore: store,
    transport: transport,
    navigatorKey: navigatorKey ?? GlobalKey<NavigatorState>(),
    metadataLoader:
        () async => const NotificationDeviceMetadata(
          platform: 'ANDROID',
          appId: 'com.carenet.app',
          appVersion: '1.0.0+1',
          locale: 'en_NG',
        ),
  );
}

Widget _routingApp(GlobalKey<NavigatorState> navigatorKey) {
  return MaterialApp(
    navigatorKey: navigatorKey,
    home: const Scaffold(body: Text('home')),
    onGenerateRoute:
        (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder:
              (_) => Scaffold(
                body: Text(switch (settings.name) {
                  RouteName.appointmentDetail =>
                    'appointment:${settings.arguments}',
                  RouteName.notification => 'notification-inbox',
                  _ => 'other-route',
                }),
              ),
        ),
  );
}
