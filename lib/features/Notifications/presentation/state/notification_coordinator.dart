import 'dart:async';
import 'dart:io';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Messaging/presentation/state/messaging_controllers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/repositories/notification_repository.dart';
import '../../data/services/firebase_notification_transport.dart';
import '../../data/storage/notification_installation_store.dart';
import '../../domain/entities/notification_models.dart';
import '../../domain/services/notification_session_lifecycle.dart';

class NotificationDeviceMetadata {
  const NotificationDeviceMetadata({
    required this.platform,
    required this.appId,
    required this.appVersion,
    required this.locale,
  });

  final String platform;
  final String appId;
  final String appVersion;
  final String locale;
}

typedef NotificationDeviceMetadataLoader =
    Future<NotificationDeviceMetadata> Function();

class NotificationCoordinator extends ChangeNotifier
    with WidgetsBindingObserver
    implements NotificationSessionLifecycle {
  NotificationCoordinator({
    required NotificationRepository repository,
    required NotificationInstallationStore installationStore,
    required NotificationTransport transport,
    required GlobalKey<NavigatorState> navigatorKey,
    NotificationDeviceMetadataLoader? metadataLoader,
    Duration providerTimeout = const Duration(seconds: 8),
  }) : _repository = repository,
       _installationStore = installationStore,
       _transport = transport,
       _navigatorKey = navigatorKey,
       _providerTimeout = providerTimeout,
       _metadataLoader = metadataLoader ?? _loadDeviceMetadata;

  final NotificationRepository _repository;
  final NotificationInstallationStore _installationStore;
  final NotificationTransport _transport;
  final GlobalKey<NavigatorState> _navigatorKey;
  final NotificationDeviceMetadataLoader _metadataLoader;
  final Duration _providerTimeout;

  int unreadCount = 0;
  NotificationPermissionValue permission =
      NotificationPermissionValue.notDetermined;
  bool initialized = false;
  bool _disposed = false;
  bool _observingLifecycle = false;
  AuthSessionModel? _session;
  Future<void>? _activeRegistration;
  Future<void>? _activeTap;
  bool _navigationReady = false;

  bool get pushConfigured => _transport.isConfigured;

  Future<void> initialize() async {
    if (initialized) return;
    initialized = true;
    try {
      await _transport
          .initialize(
            onForegroundMessage: refreshUnreadCount,
            onTap: handleTap,
            onTokenRefresh: _registerCurrentInstallation,
          )
          .timeout(_providerTimeout);
      WidgetsBinding.instance.addObserver(this);
      _observingLifecycle = true;
      permission = await _transport.permission().timeout(_providerTimeout);
    } catch (error) {
      _debug('transport initialization failed (${error.runtimeType}).');
      permission = NotificationPermissionValue.notDetermined;
    }
    _notify();
  }

  Future<void> restoreSession() async {
    try {
      await onAuthenticatedSession(await _repository.requireSession());
    } catch (_) {
      return;
    }
  }

  @override
  Future<void> onAuthenticatedSession(AuthSessionModel session) async {
    final previousUser = await _installationStore.boundUserId();
    _debug(
      'authenticated session; previous owner matches=${previousUser == null || previousUser == session.user.id}.',
    );
    if (previousUser != null && previousUser != session.user.id) {
      await _installationStore.clearPendingNotificationId();
      unreadCount = 0;
    }
    _session = session;
    await _registerCurrentInstallation();
    await refreshUnreadCount();
    if (_navigationReady) await _resolvePendingTap();
  }

  Future<void> markNavigationReady() async {
    _navigationReady = true;
    _debug('navigation is ready.');
    await _resolvePendingTap();
  }

  Future<void> _registerCurrentInstallation() {
    final active = _activeRegistration;
    if (active != null) return active;
    final future = _register();
    _activeRegistration = future;
    return future.whenComplete(() {
      if (identical(_activeRegistration, future)) _activeRegistration = null;
    });
  }

  Future<void> _register() async {
    final session = _session;
    if (session == null || !_transport.isConfigured) return;
    final endpoint = await _transport.endpoint();
    if (endpoint == null || endpoint.trim().isEmpty) return;
    final metadata = await _metadataLoader();
    final installationId = await _installationStore.installationId();
    await _repository.registerInstallation(
      session: session,
      payload: <String, dynamic>{
        'installationId': installationId,
        'platform': metadata.platform,
        'endpoint': endpoint,
        'endpointKind': 'FCM_REGISTRATION_TOKEN',
        'appId': metadata.appId,
        'appVersion': metadata.appVersion,
        'locale': metadata.locale,
        'permissionState': _permissionWire(permission),
      },
    );
    await _installationStore.bindUser(session.user.id);
  }

  static Future<NotificationDeviceMetadata> _loadDeviceMetadata() async {
    final info = await PackageInfo.fromPlatform();
    return NotificationDeviceMetadata(
      platform: Platform.isIOS ? 'IOS' : 'ANDROID',
      appId: info.packageName,
      appVersion: '${info.version}+${info.buildNumber}',
      locale: Platform.localeName,
    );
  }

  Future<NotificationPermissionValue> requestPermission() async {
    permission = await _transport.requestPermission();
    _notify();
    await _registerCurrentInstallation();
    return permission;
  }

  Future<void> openPermissionSettings() async {
    await _transport.openSettings();
  }

  Future<void> synchronizePermission() async {
    if (!_transport.isConfigured) return;
    try {
      permission = await _transport.permission();
      _notify();
      await _registerCurrentInstallation();
    } catch (_) {
      return;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(synchronizePermission());
    }
  }

  @override
  Future<void> beforeLogout(AuthSessionModel session) async {
    try {
      final installationId = await _installationStore.installationId();
      await _repository.removeInstallation(
        session: session,
        installationId: installationId,
      );
    } catch (_) {
      // Backend logout also invalidates all active installations for the user.
    } finally {
      _session = null;
      unreadCount = 0;
      await _installationStore.clearBinding();
      await _installationStore.clearPendingNotificationId();
      _notify();
    }
  }

  Future<void> refreshUnreadCount() async {
    if (_session == null) return;
    try {
      unreadCount = await _repository.unreadCount();
      _notify();
    } catch (_) {
      return;
    }
  }

  Future<void> handleTap(String notificationId) {
    final id = notificationId.trim();
    if (id.isEmpty) return Future<void>.value();
    final active = _activeTap;
    if (active != null) return active;
    final future = _handleTap(id);
    _activeTap = future;
    return future.whenComplete(() {
      if (identical(_activeTap, future)) _activeTap = null;
    });
  }

  Future<void> _handleTap(String notificationId) async {
    await _installationStore.savePendingNotificationId(notificationId);
    _debug('tap saved for owner validation.');
    if (!_navigationReady ||
        _session == null ||
        _navigatorKey.currentState == null) {
      return;
    }
    await _resolvePendingTap();
  }

  Future<void> _resolvePendingTap() async {
    final navigator = _navigatorKey.currentState;
    final session = _session;
    final id = await _installationStore.pendingNotificationId();
    _debug('pending tap available=${id != null}.');
    if (navigator == null || session == null || id == null) return;
    try {
      final notification = await _repository.notification(id);
      if (!notification.isRead) await _repository.markRead(id);
      await _installationStore.clearPendingNotificationId();
      await refreshUnreadCount();
      _debug('owned tap resolved to ${notification.routeCode ?? 'INBOX'}.');
      _openOwnedDestination(navigator, notification);
    } on AuthFailure catch (failure) {
      if (_isRecoverableTapFailure(failure)) {
        _debug('owned tap deferred after recoverable ${failure.type.name}.');
        return;
      }
      await _installationStore.clearPendingNotificationId();
      navigator.pushNamed(RouteName.notification);
    } catch (_) {
      await _installationStore.clearPendingNotificationId();
      navigator.pushNamed(RouteName.notification);
    }
  }

  bool _isRecoverableTapFailure(AuthFailure failure) {
    return failure.type == AuthFailureType.unauthorized ||
        failure.type == AuthFailureType.network ||
        failure.type == AuthFailureType.server;
  }

  void _debug(String message) {
    if (kDebugMode) debugPrint('CareNet notifications: $message');
  }

  void _openOwnedDestination(
    NavigatorState navigator,
    CareNotification notification,
  ) {
    final entityId = notification.entityId?.trim();
    switch (notification.routeCode) {
      case 'APPOINTMENT_DETAIL':
      case 'CONSULTATION':
        if (entityId != null && entityId.isNotEmpty) {
          navigator.pushNamed(RouteName.appointmentDetail, arguments: entityId);
          return;
        }
        break;
      case 'CONVERSATION':
        if (entityId != null && entityId.isNotEmpty) {
          navigator.pushNamed(
            RouteName.chat,
            arguments: AppointmentConversationRouteArgs(
              conversationId: entityId,
            ),
          );
          return;
        }
        break;
      case 'PROFESSIONAL_VERIFICATION':
        navigator.pushNamed(RouteName.professionalVerificationDocuments);
        return;
      case 'PROFESSIONAL_FINANCE':
        navigator.pushNamed(RouteName.professionalFinance);
        return;
      case 'ACCOUNT_SECURITY':
        navigator.pushNamed(RouteName.account);
        return;
    }
    navigator.pushNamed(RouteName.notification);
  }

  String _permissionWire(NotificationPermissionValue value) {
    return switch (value) {
      NotificationPermissionValue.authorized => 'AUTHORIZED',
      NotificationPermissionValue.provisional => 'PROVISIONAL',
      NotificationPermissionValue.denied => 'DENIED',
      NotificationPermissionValue.notDetermined => 'NOT_DETERMINED',
    };
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_observingLifecycle) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
