import 'dart:async';

import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notification_test_fakes.dart';

void main() {
  test('late logout cleanup preserves the new account binding', () async {
    final repository = _HeldRemovalRepository();
    final store = FakeNotificationInstallationStore();
    final coordinator = _coordinator(repository, store);
    addTearDown(coordinator.dispose);
    final firstSession = repository.session;
    await coordinator.onAuthenticatedSession(firstSession);
    await store.bindUser(firstSession.user.id);
    final logout = coordinator.beforeLogout(firstSession);
    await repository.started.future;
    repository.session = notificationTestSession(userId: 'user-2');
    await coordinator.onAuthenticatedSession(repository.session);
    await store.bindUser(repository.session.user.id);
    store.pendingNotification = 'user-2-notification';
    repository.release.complete();
    await logout;
    expect(store.boundUser, 'user-2');
    expect(store.pendingNotification, 'user-2-notification');
  });

  test('late account deletion preserves the new account binding', () async {
    final repository = FakeNotificationRepository();
    final store = FakeNotificationInstallationStore();
    final coordinator = _coordinator(repository, store);
    addTearDown(coordinator.dispose);
    final firstSession = repository.session;
    await coordinator.onAuthenticatedSession(firstSession);
    repository.session = notificationTestSession(userId: 'user-2');
    await coordinator.onAuthenticatedSession(repository.session);
    await store.bindUser(repository.session.user.id);
    store.pendingNotification = 'user-2-notification';
    await coordinator.afterAccountDeletion(firstSession);
    expect(store.boundUser, 'user-2');
    expect(store.pendingNotification, 'user-2-notification');
  });

  test('new account registers after an older registration completes', () async {
    final repository = _HeldRegistrationRepository();
    final store = FakeNotificationInstallationStore();
    final coordinator = NotificationCoordinator(
      repository: repository,
      installationStore: store,
      transport: FakeNotificationTransport(),
      navigatorKey: GlobalKey<NavigatorState>(),
      metadataLoader:
          () async => const NotificationDeviceMetadata(
            platform: 'ANDROID',
            appId: 'com.carenet.app.staging',
            appVersion: '1.0.0+1',
            locale: 'en_NG',
          ),
    );
    addTearDown(coordinator.dispose);
    final first = coordinator.onAuthenticatedSession(repository.session);
    await repository.started.future;
    repository.session = notificationTestSession(userId: 'user-2');
    final second = coordinator.onAuthenticatedSession(repository.session);
    await Future<void>.delayed(Duration.zero);
    repository.release.complete();
    await Future.wait([first, second]);
    expect(repository.owners, ['user-1', 'user-2']);
    expect(store.boundUser, 'user-2');
  });

  test('late unread response is ignored after disposal', () async {
    final repository = _HeldUnreadRepository();
    final coordinator = NotificationCoordinator(
      repository: repository,
      installationStore: FakeNotificationInstallationStore(),
      transport: FakeNotificationTransport(configured: false),
      navigatorKey: GlobalKey<NavigatorState>(),
    );
    await coordinator.onAuthenticatedSession(repository.session);
    repository.pending = Completer<int>();
    final refresh = coordinator.refreshUnreadCount();
    await repository.started.future;
    coordinator.dispose();
    repository.pending!.complete(99);
    await refresh;
    expect(coordinator.unreadCount, 0);
  });

  test('late unread response cannot replace the new account count', () async {
    final repository = _HeldUnreadRepository();
    final coordinator = NotificationCoordinator(
      repository: repository,
      installationStore: FakeNotificationInstallationStore(),
      transport: FakeNotificationTransport(configured: false),
      navigatorKey: GlobalKey<NavigatorState>(),
    );
    addTearDown(coordinator.dispose);
    await coordinator.onAuthenticatedSession(repository.session);

    repository.pending = Completer<int>();
    final oldRefresh = coordinator.refreshUnreadCount();
    await repository.started.future;
    repository.session = notificationTestSession(userId: 'user-2');
    repository.unread = 2;
    final held = repository.pending!;
    repository.pending = null;
    await coordinator.onAuthenticatedSession(repository.session);
    expect(coordinator.unreadCount, 2);

    held.complete(99);
    await oldRefresh;
    expect(coordinator.unreadCount, 2);
  });
}

class _HeldUnreadRepository extends FakeNotificationRepository {
  Completer<int>? pending;
  final started = Completer<void>();

  @override
  Future<int> unreadCount() {
    final held = pending;
    if (held == null) return super.unreadCount();
    if (!started.isCompleted) started.complete();
    return held.future;
  }
}

NotificationCoordinator _coordinator(
  FakeNotificationRepository repository,
  FakeNotificationInstallationStore store,
) => NotificationCoordinator(
  repository: repository,
  installationStore: store,
  transport: FakeNotificationTransport(configured: false),
  navigatorKey: GlobalKey<NavigatorState>(),
);

class _HeldRemovalRepository extends FakeNotificationRepository {
  final started = Completer<void>();
  final release = Completer<void>();

  @override
  Future<void> removeInstallation({
    required AuthSessionModel session,
    required String installationId,
  }) async {
    started.complete();
    await release.future;
  }
}

class _HeldRegistrationRepository extends FakeNotificationRepository {
  final started = Completer<void>();
  final release = Completer<void>();
  final owners = <String>[];

  @override
  Future<void> registerInstallation({
    required AuthSessionModel session,
    required Map<String, dynamic> payload,
  }) async {
    owners.add(session.user.id);
    if (owners.length == 1) {
      started.complete();
      await release.future;
    }
  }
}
