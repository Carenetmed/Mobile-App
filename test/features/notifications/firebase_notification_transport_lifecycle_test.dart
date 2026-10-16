import 'dart:async';
import 'package:app_t/core/config/app_environment.dart';
import 'package:app_t/features/Notifications/data/services/firebase_notification_transport.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_coordinator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notification_test_fakes.dart';

void main() {
  test(
    'coordinator timeout disposes transport before late initialization resumes',
    () async {
      final gateway = _Gateway()..holdFirebase = true;
      final transport = _transport(gateway);
      final coordinator = NotificationCoordinator(
        repository: FakeNotificationRepository(),
        installationStore: FakeNotificationInstallationStore(),
        transport: transport,
        navigatorKey: GlobalKey<NavigatorState>(),
        providerTimeout: const Duration(milliseconds: 10),
      );
      final initialization = coordinator.initialize();
      await gateway.firebaseStarted.future;
      await initialization;

      gateway.firebaseGate.complete();
      await _flush();
      expect(gateway.localInitializationCalls, 0);
      expect(gateway.foreground.hasListener, isFalse);
      expect(gateway.opened.hasListener, isFalse);
      expect(gateway.tokenChanges.hasListener, isFalse);
      coordinator.dispose();
    },
  );

  test(
    'late Firebase initialization after disposal attaches no listeners',
    () async {
      final gateway = _Gateway()..holdFirebase = true;
      final transport = _transport(gateway);
      final initialization = transport.initialize(
        onForegroundMessage: (_) async => true,
        onTap: (_) async {},
        onTokenRefresh: () async {},
      );
      await gateway.firebaseStarted.future;

      await transport.dispose();
      gateway.firebaseGate.complete();
      await initialization;

      expect(gateway.localInitializationCalls, 0);
      expect(gateway.foreground.hasListener, isFalse);
      expect(gateway.opened.hasListener, isFalse);
      expect(gateway.tokenChanges.hasListener, isFalse);
    },
  );

  test('dispose cancels all attached provider subscriptions', () async {
    final gateway = _Gateway();
    final transport = _transport(gateway);
    await transport.initialize(
      onForegroundMessage: (_) async => true,
      onTap: (_) async {},
      onTokenRefresh: () async {},
    );

    expect(gateway.foreground.hasListener, isTrue);
    expect(gateway.opened.hasListener, isTrue);
    expect(gateway.tokenChanges.hasListener, isTrue);
    await transport.dispose();
    expect(gateway.foreground.hasListener, isFalse);
    expect(gateway.opened.hasListener, isFalse);
    expect(gateway.tokenChanges.hasListener, isFalse);
  });

  test('foreground presentation excludes untrusted payload text', () async {
    final gateway = _Gateway();
    final transport = _transport(gateway);
    await transport.initialize(
      onForegroundMessage: (_) async => true,
      onTap: (_) async {},
      onTokenRefresh: () async {},
    );
    gateway.foreground.add(
      RemoteMessage(
        data: const <String, dynamic>{'notificationId': 'owned-id'},
        notification: const RemoteNotification(
          title: 'PRIVATE PUSH TITLE',
          body: 'PRIVATE PUSH BODY',
        ),
      ),
    );
    await _flush();

    expect(gateway.presented, hasLength(1));
    expect(gateway.presented.single.$2, contains('notificationId'));
    expect(gateway.presented.toString(), isNot(contains('PRIVATE PUSH')));
    expect(foregroundNotificationTitle, 'CareNet update');
    expect(
      foregroundNotificationBody,
      'Open CareNet to view your latest update.',
    );
    await transport.dispose();
  });

  test(
    'account invalidation during backend check prevents local presentation',
    () async {
      final gateway = _Gateway();
      final transport = _transport(gateway);
      final started = Completer<void>();
      final release = Completer<bool>();
      await transport.initialize(
        onForegroundMessage: (_) {
          started.complete();
          return release.future;
        },
        onTap: (_) async {},
        onTokenRefresh: () async {},
      );
      gateway.foreground.add(
        RemoteMessage(
          data: const <String, dynamic>{'notificationId': 'old-id'},
        ),
      );
      await started.future;
      await transport.clearDisplayedNotifications();
      release.complete(true);
      await _flush();

      expect(gateway.presented, isEmpty);
      await transport.dispose();
    },
  );

  test('detached callback errors are contained', () async {
    final gateway = _Gateway();
    final transport = _transport(gateway);
    await transport.initialize(
      onForegroundMessage: (_) async => throw StateError('private detail'),
      onTap: (_) async => throw StateError('private tap'),
      onTokenRefresh: () async => throw StateError('private token'),
    );
    gateway.foreground.add(
      RemoteMessage(data: const <String, dynamic>{'notificationId': 'n1'}),
    );
    gateway.opened.add(
      RemoteMessage(data: const <String, dynamic>{'notificationId': 'n1'}),
    );
    gateway.tokenChanges.add('opaque-token');
    await _flush();
    expect(gateway.presented, isEmpty);
    await transport.dispose();
  });

  test('provider stream errors are contained', () async {
    final gateway = _Gateway();
    final transport = _transport(gateway);
    await transport.initialize(
      onForegroundMessage: (_) async => false,
      onTap: (_) async {},
      onTokenRefresh: () async {},
    );
    gateway.foreground.addError(StateError('provider detail'));
    gateway.opened.addError(StateError('provider detail'));
    gateway.tokenChanges.addError(StateError('provider detail'));
    await _flush();
    expect(gateway.presented, isEmpty);
    await transport.dispose();
  });

  test('local notification tap callback errors are contained', () async {
    final gateway = _Gateway();
    final transport = _transport(gateway);
    await transport.initialize(
      onForegroundMessage: (_) async => false,
      onTap: (_) async => throw StateError('private tap detail'),
      onTokenRefresh: () async {},
    );
    await gateway.localTap!('tap-id');
    await transport.dispose();
  });

  test(
    'pending native display is cancelled after account invalidation',
    () async {
      final gateway = _Gateway()..holdDisplay = true;
      final transport = _transport(gateway);
      final authorized = Completer<void>();
      await transport.initialize(
        onForegroundMessage: (_) async {
          authorized.complete();
          return true;
        },
        onTap: (_) async {},
        onTokenRefresh: () async {},
      );
      const id = 'display-after-switch';
      gateway.foreground.add(
        RemoteMessage(data: const <String, dynamic>{'notificationId': id}),
      );
      await authorized.future;
      await gateway.displayStarted.future;
      await transport.clearDisplayedNotifications();
      gateway.displayGate.complete();
      await _flush();

      expect(gateway.cancelledIds, contains(id.hashCode & 0x7fffffff));
      await transport.dispose();
    },
  );
}

FirebaseNotificationTransport _transport(_Gateway gateway) =>
    FirebaseNotificationTransport(
      config: FirebaseClientConfig(
        projectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
        appId: 'test-app',
        messagingSenderId: 'test-sender',
        apiKey: 'test-api-key',
      ),
      gateway: gateway,
    );

Future<void> _flush() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _Gateway implements NotificationProviderGateway {
  final foreground = StreamController<RemoteMessage>.broadcast();
  final opened = StreamController<RemoteMessage>.broadcast();
  final tokenChanges = StreamController<String>.broadcast();
  final firebaseStarted = Completer<void>();
  final firebaseGate = Completer<void>();
  final presented = <(int, String)>[];
  final cancelledIds = <int>[];
  final displayStarted = Completer<void>();
  final displayGate = Completer<void>();
  NotificationTapCallback? localTap;
  bool holdFirebase = false;
  bool holdDisplay = false;
  int localInitializationCalls = 0;
  int cancelledCalls = 0;

  @override
  Future<void> initializeFirebase(FirebaseOptions options) async {
    if (!firebaseStarted.isCompleted) firebaseStarted.complete();
    if (holdFirebase) await firebaseGate.future;
  }

  @override
  Future<void> initializeLocalNotifications(
    NotificationTapCallback onTap,
  ) async {
    localInitializationCalls++;
    localTap = onTap;
  }

  @override
  Future<void> createChannel() async {}

  @override
  Stream<RemoteMessage> get foregroundMessages => foreground.stream;

  @override
  Stream<RemoteMessage> get openedMessages => opened.stream;

  @override
  Stream<String> get tokenRefreshes => tokenChanges.stream;

  @override
  Future<RemoteMessage?> initialMessage() async => null;

  @override
  Future<void> showGenericForeground({
    required int id,
    required String payload,
  }) async {
    if (!displayStarted.isCompleted) displayStarted.complete();
    if (holdDisplay) await displayGate.future;
    presented.add((id, payload));
  }

  @override
  Future<void> cancelLocal(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAllLocal() async {
    cancelledCalls++;
  }

  @override
  Future<String?> token() async => 'test-token';

  @override
  Future<NotificationSettings> settings() async => throw UnimplementedError();

  @override
  Future<NotificationSettings> requestPermission() async =>
      throw UnimplementedError();
}
