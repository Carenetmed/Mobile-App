import 'dart:async';
import 'dart:io';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
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
  int? _activeRegistrationGeneration;
  Future<void>? _activeTap;
  Future<void>? _activeTapResolution;
  int? _activeTapResolutionGeneration;
  bool _navigationReady = false;
  int _sessionGeneration = 0;
  Future<void> _bindingTransition = Future<void>.value();

  Future<T> _serializeBinding<T>(Future<T> Function() operation) {
    final result = _bindingTransition.then((_) => operation());
    _bindingTransition = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return result;
  }

  bool get pushConfigured => _transport.isConfigured;

  Future<void> initialize() async {
    if (initialized || _disposed) return;
    initialized = true;
    try {
      await _transport
          .initialize(
            onForegroundMessage: _authorizeForegroundNotification,
            onTap: handleTap,
            onTokenRefresh: _registerCurrentInstallation,
          )
          .timeout(_providerTimeout);
      if (_disposed) return;
      WidgetsBinding.instance.addObserver(this);
      _observingLifecycle = true;
      final currentPermission = await _transport.permission().timeout(
        _providerTimeout,
      );
      if (_disposed) return;
      permission = currentPermission;
    } catch (error) {
      if (_disposed) return;
      _debug('transport initialization failed (${error.runtimeType}).');
      permission = NotificationPermissionValue.notDetermined;
      try {
        await _transport.dispose().timeout(_providerTimeout);
      } catch (_) {
        // A timed-out native initializer cannot be cancelled by this caller.
      }
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
    int? generation;
    try {
      generation = await _serializeBinding<int?>(() async {
        if (_disposed) return null;
        final current = await _repository.requireSession().timeout(
          _providerTimeout,
        );
        if (_disposed || current.user.id != session.user.id) return null;
        final previousUser = await _installationStore.boundUserId().timeout(
          _providerTimeout,
        );
        if (_disposed) return null;
        if ((previousUser != null && previousUser != session.user.id) ||
            (_session != null && _session!.user.id != session.user.id)) {
          _clearDisplayedNotificationsBestEffort();
          await _installationStore.clearPendingNotificationId().timeout(
            _providerTimeout,
          );
          unreadCount = 0;
        }
        if (_disposed) return null;
        _session = session;
        _sessionGeneration++;
        return _sessionGeneration;
      });
    } catch (error) {
      _debug('session notification binding failed (${error.runtimeType}).');
      return;
    }
    final acceptedGeneration = generation;
    if (acceptedGeneration == null ||
        !_isCurrentSession(session, acceptedGeneration)) {
      return;
    }

    _scheduleNonFatal(
      'installation registration',
      () => _registerInstallationFor(session, acceptedGeneration),
    );
    _scheduleNonFatal(
      'unread-count refresh',
      () => _refreshUnreadCountFor(session, acceptedGeneration),
    );
    if (_navigationReady) {
      _scheduleNonFatal(
        'pending notification routing',
        () => _resolvePendingTap(generation: acceptedGeneration),
      );
    }
  }

  Future<void> markNavigationReady() async {
    _navigationReady = true;
    _debug('navigation is ready.');
    final generation = _sessionGeneration;
    _scheduleNonFatal(
      'pending notification routing',
      () => _resolvePendingTap(generation: generation),
    );
  }

  Future<void> _registerCurrentInstallation() async {
    final session = _session;
    final generation = _sessionGeneration;
    if (session == null || _disposed) return;
    await _registerInstallationFor(session, generation);
  }

  Future<void> _registerInstallationFor(
    AuthSessionModel session,
    int generation,
  ) async {
    if (!_isCurrentSession(session, generation)) return;
    final active = _activeRegistration;
    if (active != null) {
      if (_activeRegistrationGeneration == generation) {
        try {
          await active;
        } catch (error) {
          _debug('installation registration failed (${error.runtimeType}).');
        }
        return;
      }
      try {
        // Serialize client calls; a backend generation fence is still needed
        // because a timed-out request may commit after this future settles.
        await active;
      } catch (_) {
        // The old operation settled; the current generation can now proceed.
      }
      if (!_isCurrentSession(session, generation)) return;
      return _registerInstallationFor(session, generation);
    }
    late final Future<void> future;
    future = _register(session, generation).whenComplete(() {
      if (identical(_activeRegistration, future)) {
        _activeRegistration = null;
        _activeRegistrationGeneration = null;
      }
    });
    _activeRegistrationGeneration = generation;
    _activeRegistration = future;
    try {
      await future;
    } catch (error) {
      _debug('installation registration failed (${error.runtimeType}).');
    }
  }

  Future<void> _register(AuthSessionModel session, int generation) async {
    if (!_transport.isConfigured || !_isCurrentSession(session, generation)) {
      return;
    }
    final endpoint = await _transport.endpoint().timeout(_providerTimeout);
    if (!_isCurrentSession(session, generation)) return;
    if (endpoint == null || endpoint.trim().isEmpty) return;
    final metadata = await _metadataLoader().timeout(_providerTimeout);
    if (!_isCurrentSession(session, generation)) return;
    final installationId = await _installationStore.installationId().timeout(
      _providerTimeout,
    );
    if (!_isCurrentSession(session, generation)) return;
    final bindingGeneration = await _installationStore
        .nextBindingGeneration()
        .timeout(_providerTimeout);
    if (!_isCurrentSession(session, generation)) return;
    await _repository.registerInstallation(
      session: session,
      payload: <String, dynamic>{
        'installationId': installationId,
        'bindingGeneration': bindingGeneration,
        'platform': metadata.platform,
        'endpoint': endpoint,
        'endpointKind': 'FCM_REGISTRATION_TOKEN',
        'appId': metadata.appId,
        'appVersion': metadata.appVersion,
        'locale': metadata.locale,
        'permissionState': _permissionWire(permission),
      },
    );
    if (!_isCurrentSession(session, generation)) return;
    await _serializeBinding(() async {
      if (!_isCurrentSession(session, generation)) return;
      await _installationStore
          .bindUser(session.user.id)
          .timeout(_providerTimeout);
    });
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
    permission = await _transport.requestPermission().timeout(_providerTimeout);
    _notify();
    _scheduleNonFatal(
      'installation registration',
      _registerCurrentInstallation,
    );
    return permission;
  }

  Future<void> openPermissionSettings() async {
    await _transport.openSettings();
  }

  Future<void> synchronizePermission() async {
    if (!_transport.isConfigured) return;
    try {
      permission = await _transport.permission().timeout(_providerTimeout);
      _notify();
      _scheduleNonFatal(
        'installation registration',
        _registerCurrentInstallation,
      );
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
    final ownsBinding = _session?.user.id == session.user.id;
    final bindingGeneration =
        ownsBinding ? ++_sessionGeneration : _sessionGeneration;
    if (ownsBinding) {
      _session = null;
      unreadCount = 0;
      _notify();
      _clearDisplayedNotificationsBestEffort();
    }
    SessionSnapshot? snapshot;
    try {
      snapshot = await _repository.currentSessionSnapshot().timeout(
        _providerTimeout,
      );
      final installationId = await _installationStore.installationId().timeout(
        _providerTimeout,
      );
      await _repository
          .removeInstallation(session: session, installationId: installationId)
          .timeout(_providerTimeout);
    } catch (_) {
      // Backend logout also invalidates all active installations for the user.
    } finally {
      try {
        await _clearAccountBinding(
          session,
          expectedBindingGeneration: bindingGeneration,
          expectedStoreGeneration: snapshot?.generation,
        ).timeout(_providerTimeout);
      } catch (_) {
        // Local sign-out remains bounded if notification storage is stalled.
      }
    }
  }

  @override
  Future<void> afterAccountDeletion(AuthSessionModel session) async {
    final bindingGeneration = _sessionGeneration;
    await _clearAccountBinding(
      session,
      expectedBindingGeneration: bindingGeneration,
      expectStoreEmpty: true,
    );
  }

  Future<void> _clearAccountBinding(
    AuthSessionModel session, {
    required int expectedBindingGeneration,
    String? expectedStoreGeneration,
    bool expectStoreEmpty = false,
  }) => _serializeBinding(() async {
    if (_disposed ||
        _sessionGeneration != expectedBindingGeneration ||
        (_session != null && _session!.user.id != session.user.id)) {
      return;
    }
    final currentSnapshot = await _repository.currentSessionSnapshot().timeout(
      _providerTimeout,
    );
    if (expectStoreEmpty) {
      if (currentSnapshot != null) return;
    } else if (currentSnapshot?.generation != expectedStoreGeneration) {
      return;
    }
    final boundUser = await _installationStore.boundUserId();
    if (boundUser != null && boundUser != session.user.id) return;
    _session = null;
    unreadCount = 0;
    _clearDisplayedNotificationsBestEffort();
    await _installationStore.clearBinding();
    await _installationStore.clearPendingNotificationId();
    _notify();
  });

  void _clearDisplayedNotificationsBestEffort() {
    try {
      // Invalidate pending presentations synchronously, without waiting for OS cleanup.
      unawaited(
        _transport
            .clearDisplayedNotifications()
            .timeout(_providerTimeout)
            .catchError((Object _) {}),
      );
    } catch (_) {
      // Account transitions must not depend on local notification cleanup.
    }
  }

  Future<bool> _authorizeForegroundNotification(String notificationId) async {
    final session = _session;
    final generation = _sessionGeneration;
    if (session == null || !_isCurrentSession(session, generation)) {
      return false;
    }
    try {
      final notification = await _repository
          .notification(notificationId)
          .timeout(_providerTimeout);
      return notification.id == notificationId &&
          _isCurrentSession(session, generation) &&
          await _hasCurrentSession(session, generation);
    } catch (_) {
      return false;
    }
  }

  Future<void> refreshUnreadCount() async {
    final session = _session;
    final generation = _sessionGeneration;
    if (session == null || _disposed) return;
    await _refreshUnreadCountFor(session, generation);
  }

  Future<void> _refreshUnreadCountFor(
    AuthSessionModel session,
    int generation,
  ) async {
    if (!_isCurrentSession(session, generation)) return;
    try {
      final count = await _repository.unreadCount().timeout(_providerTimeout);
      if (!_isCurrentSession(session, generation) ||
          !await _hasCurrentSession(session, generation)) {
        return;
      }
      unreadCount = count;
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
    final future = _handleTap(id).catchError((Object error) {
      _debug('notification tap deferred (${error.runtimeType}).');
    });
    _activeTap = future;
    return future.whenComplete(() {
      if (identical(_activeTap, future)) _activeTap = null;
    });
  }

  Future<void> _handleTap(String notificationId) async {
    await _installationStore
        .savePendingNotificationId(notificationId)
        .timeout(_providerTimeout);
    _debug('tap saved for owner validation.');
    if (!_navigationReady ||
        _session == null ||
        _navigatorKey.currentState == null) {
      return;
    }
    await _resolvePendingTap(generation: _sessionGeneration);
  }

  Future<void> _resolvePendingTap({required int generation}) async {
    final active = _activeTapResolution;
    if (active != null) {
      if (_activeTapResolutionGeneration == generation) return active;
      try {
        await active.timeout(_providerTimeout);
      } catch (_) {
        // A stale resolver is bounded and cannot mutate a newer account.
      }
      if (_disposed || generation != _sessionGeneration) return;
    }
    final session = _session;
    if (session == null || !_isCurrentSession(session, generation)) return;
    late final Future<void> future;
    future = _resolvePendingTapForSession(session, generation).whenComplete(() {
      if (identical(_activeTapResolution, future)) {
        _activeTapResolution = null;
        _activeTapResolutionGeneration = null;
      }
    });
    _activeTapResolution = future;
    _activeTapResolutionGeneration = generation;
    try {
      await future;
    } catch (error) {
      _debug('pending notification routing deferred (${error.runtimeType}).');
    }
  }

  Future<void> _resolvePendingTapForSession(
    AuthSessionModel session,
    int generation,
  ) async {
    final navigator = _navigatorKey.currentState;
    final id = await _installationStore.pendingNotificationId().timeout(
      _providerTimeout,
    );
    _debug('pending tap available=${id != null}.');
    if (navigator == null ||
        id == null ||
        !_isCurrentSession(session, generation)) {
      return;
    }
    try {
      if (!await _hasCurrentSession(session, generation)) return;
      final notification = await _repository
          .notification(id)
          .timeout(_providerTimeout);
      if (!await _hasCurrentSession(session, generation)) return;
      if (!notification.isRead) {
        await _repository.markRead(id).timeout(_providerTimeout);
      }
      if (!await _clearResolvedTap(session, generation, id)) return;
      _scheduleNonFatal(
        'unread-count refresh',
        () => _refreshUnreadCountFor(session, generation),
      );
      if (!await _hasCurrentSession(session, generation) ||
          !navigator.mounted ||
          _navigatorKey.currentState != navigator) {
        return;
      }
      _debug('owned tap resolved to ${notification.routeCode ?? 'INBOX'}.');
      _openOwnedDestination(navigator, notification);
    } on AuthFailure catch (failure) {
      if (!await _hasCurrentSession(session, generation)) return;
      if (_isRecoverableTapFailure(failure)) {
        _debug('owned tap deferred after recoverable ${failure.type.name}.');
        return;
      }
      if (await _clearResolvedTap(session, generation, id) &&
          await _hasCurrentSession(session, generation) &&
          navigator.mounted &&
          _navigatorKey.currentState == navigator) {
        navigator.pushNamed(RouteName.notification);
      }
    } on TimeoutException {
      _debug('owned tap deferred after a bounded request timeout.');
    } catch (_) {
      if (await _clearResolvedTap(session, generation, id) &&
          await _hasCurrentSession(session, generation) &&
          navigator.mounted &&
          _navigatorKey.currentState == navigator) {
        navigator.pushNamed(RouteName.notification);
      }
    }
  }

  bool _isCurrentSession(AuthSessionModel expected, int generation) {
    return !_disposed &&
        _sessionGeneration == generation &&
        _session?.user.id == expected.user.id;
  }

  Future<bool> _hasCurrentSession(
    AuthSessionModel expected,
    int generation,
  ) async {
    if (!_isCurrentSession(expected, generation)) return false;
    try {
      final current = await _repository.requireSession().timeout(
        _providerTimeout,
      );
      return _isCurrentSession(expected, generation) &&
          current.user.id == expected.user.id;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _clearResolvedTap(
    AuthSessionModel session,
    int generation,
    String id,
  ) => _serializeBinding(() async {
    if (!await _hasCurrentSession(session, generation)) return false;
    final pending = await _installationStore.pendingNotificationId().timeout(
      _providerTimeout,
    );
    if (pending != id || !await _hasCurrentSession(session, generation)) {
      return false;
    }
    await _installationStore.clearPendingNotificationId().timeout(
      _providerTimeout,
    );
    return true;
  });

  void _scheduleNonFatal(String label, Future<void> Function() operation) {
    unawaited(() async {
      try {
        await operation();
      } catch (error) {
        _debug('$label failed (${error.runtimeType}).');
      }
    }());
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
    _sessionGeneration++;
    _session = null;
    if (_observingLifecycle) WidgetsBinding.instance.removeObserver(this);
    unawaited(_transport.dispose().catchError((Object _) {}));
    super.dispose();
  }
}
