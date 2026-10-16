import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/config/app_environment.dart';

enum NotificationPermissionValue {
  notDetermined,
  authorized,
  provisional,
  denied,
}

class FirebaseClientConfig {
  const FirebaseClientConfig({
    required this.projectId,
    required this.appId,
    required this.messagingSenderId,
    required this.apiKey,
  });

  factory FirebaseClientConfig.fromEnvironment() {
    return const FirebaseClientConfig(
      projectId: String.fromEnvironment('CARENET_FIREBASE_PROJECT_ID'),
      appId: String.fromEnvironment('CARENET_FIREBASE_APP_ID'),
      messagingSenderId: String.fromEnvironment(
        'CARENET_FIREBASE_MESSAGING_SENDER_ID',
      ),
      apiKey: String.fromEnvironment('CARENET_FIREBASE_API_KEY'),
    );
  }

  final String projectId;
  final String appId;
  final String messagingSenderId;
  final String apiKey;

  bool get isConfigured =>
      projectId.trim() == AppEnvironmentConfig.canonicalFirebaseProjectId &&
      appId.trim().isNotEmpty &&
      messagingSenderId.trim().isNotEmpty &&
      apiKey.trim().isNotEmpty;

  FirebaseOptions get options => FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
  );
}

typedef NotificationTapCallback = Future<void> Function(String notificationId);
typedef ForegroundNotificationAuthorization =
    Future<bool> Function(String notificationId);

abstract interface class NotificationProviderGateway {
  Future<void> initializeFirebase(FirebaseOptions options);
  Future<void> initializeLocalNotifications(NotificationTapCallback onTap);
  Future<void> createChannel();
  Stream<RemoteMessage> get foregroundMessages;
  Stream<RemoteMessage> get openedMessages;
  Stream<String> get tokenRefreshes;
  Future<RemoteMessage?> initialMessage();
  Future<void> showGenericForeground({
    required int id,
    required String payload,
  });
  Future<void> cancelLocal(int id);
  Future<void> cancelAllLocal();
  Future<String?> token();
  Future<NotificationSettings> settings();
  Future<NotificationSettings> requestPermission();
}

const String foregroundNotificationTitle = 'CareNet update';
const String foregroundNotificationBody =
    'Open CareNet to view your latest update.';

abstract class NotificationTransport {
  bool get isConfigured;
  Future<void> initialize({
    required ForegroundNotificationAuthorization onForegroundMessage,
    required NotificationTapCallback onTap,
    required Future<void> Function() onTokenRefresh,
  });
  Future<NotificationPermissionValue> permission();
  Future<NotificationPermissionValue> requestPermission();
  Future<String?> endpoint();
  Future<bool> openSettings();
  Future<void> clearDisplayedNotifications();
  Future<void> dispose();
}

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'carenet_transactional',
  'CareNet updates',
  description: 'Appointment and account updates from CareNet.',
  importance: Importance.high,
);

class FirebasePluginNotificationGateway implements NotificationProviderGateway {
  FirebasePluginNotificationGateway({
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _localNotifications;
  FirebaseMessaging? _messaging;

  FirebaseMessaging get _currentMessaging =>
      _messaging ??= FirebaseMessaging.instance;

  @override
  Future<void> initializeFirebase(FirebaseOptions options) async {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp(options: options);
  }

  @override
  Future<void> initializeLocalNotifications(
    NotificationTapCallback onTap,
  ) async {
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('carenet_notification'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) async {
        final id = _notificationIdFromPayload(response.payload);
        if (id == null) return;
        try {
          await onTap(id);
        } catch (_) {
          // Provider callbacks must not leak errors into the native plugin.
        }
      },
    );
  }

  @override
  Future<void> createChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  @override
  Stream<RemoteMessage> get foregroundMessages => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get openedMessages =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Stream<String> get tokenRefreshes => _currentMessaging.onTokenRefresh;

  @override
  Future<RemoteMessage?> initialMessage() =>
      _currentMessaging.getInitialMessage();

  @override
  Future<void> showGenericForeground({
    required int id,
    required String payload,
  }) => _localNotifications.show(
    id: id,
    title: foregroundNotificationTitle,
    body: foregroundNotificationBody,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'carenet_transactional',
        'CareNet updates',
        channelDescription: 'Appointment and account updates from CareNet.',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'carenet_notification',
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: payload,
  );

  @override
  Future<void> cancelLocal(int id) => _localNotifications.cancel(id: id);

  @override
  Future<void> cancelAllLocal() => _localNotifications.cancelAll();

  @override
  Future<String?> token() => _currentMessaging.getToken();

  @override
  Future<NotificationSettings> settings() =>
      _currentMessaging.getNotificationSettings();

  @override
  Future<NotificationSettings> requestPermission() => _currentMessaging
      .requestPermission(alert: true, badge: true, sound: true);
}

String? _notificationIdFromPayload(String? payload) {
  if (payload == null || payload.isEmpty) return null;
  try {
    final decoded = jsonDecode(payload);
    final value =
        decoded is Map<String, dynamic> ? decoded['notificationId'] : null;
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  } catch (_) {
    return null;
  }
}

class FirebaseNotificationTransport implements NotificationTransport {
  FirebaseNotificationTransport({
    FirebaseClientConfig? config,
    FlutterLocalNotificationsPlugin? localNotifications,
    NotificationProviderGateway? gateway,
  }) : _config = config ?? FirebaseClientConfig.fromEnvironment(),
       _gateway =
           gateway ??
           FirebasePluginNotificationGateway(
             localNotifications: localNotifications,
           );

  final FirebaseClientConfig _config;
  final NotificationProviderGateway _gateway;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _tapSubscription;
  StreamSubscription<String>? _tokenSubscription;
  Future<void>? _initializing;
  int _lifecycleGeneration = 0;
  int _presentationGeneration = 0;
  bool _disposed = false;

  @override
  bool get isConfigured => _config.isConfigured;

  @override
  Future<void> initialize({
    required ForegroundNotificationAuthorization onForegroundMessage,
    required NotificationTapCallback onTap,
    required Future<void> Function() onTokenRefresh,
  }) {
    if (!isConfigured || _disposed) return Future<void>.value();
    return _initializing ??= _initialize(
      onForegroundMessage: onForegroundMessage,
      onTap: onTap,
      onTokenRefresh: onTokenRefresh,
      generation: _lifecycleGeneration,
    );
  }

  Future<void> _initialize({
    required ForegroundNotificationAuthorization onForegroundMessage,
    required NotificationTapCallback onTap,
    required Future<void> Function() onTokenRefresh,
    required int generation,
  }) async {
    bool current() => !_disposed && generation == _lifecycleGeneration;
    _debug('transport initialization started.');
    await _gateway.initializeFirebase(_config.options);
    if (!current()) return;
    _debug('Firebase initialized.');
    await _gateway.initializeLocalNotifications((id) async {
      if (current()) {
        try {
          await onTap(id);
        } catch (error) {
          _debug('local tap callback failed (${error.runtimeType}).');
        }
      }
    });
    if (!current()) return;
    _debug('local notification tap handler initialized.');
    await _gateway.createChannel();
    if (!current()) return;

    _foregroundSubscription = _gateway.foregroundMessages.listen(
      (message) {
        _runDetached(
          () => _showForeground(message, onForegroundMessage, generation),
        );
      },
      onError: (Object error, StackTrace _) {
        _debug('foreground stream failed (${error.runtimeType}).');
      },
    );
    _tapSubscription = _gateway.openedMessages.listen(
      (message) {
        final id = _notificationId(message.data);
        if (id != null && current()) _runDetached(() => onTap(id));
      },
      onError: (Object error, StackTrace _) {
        _debug('tap stream failed (${error.runtimeType}).');
      },
    );
    _tokenSubscription = _gateway.tokenRefreshes.listen(
      (_) {
        if (current()) _runDetached(onTokenRefresh);
      },
      onError: (Object error, StackTrace _) {
        _debug('token stream failed (${error.runtimeType}).');
      },
    );
    final initial = await _gateway.initialMessage();
    if (!current()) return;
    final initialId = initial == null ? null : _notificationId(initial.data);
    if (kDebugMode) {
      debugPrint(
        'CareNet notifications: initial message present=${initial != null}, '
        'owned id present=${initialId != null}.',
      );
    }
    if (initialId != null) await onTap(initialId);
  }

  void _debug(String message) {
    if (kDebugMode) debugPrint('CareNet notifications: $message');
  }

  Future<void> _showForeground(
    RemoteMessage message,
    ForegroundNotificationAuthorization authorize,
    int lifecycleGeneration,
  ) async {
    final id = _notificationId(message.data);
    if (id == null) return;
    final presentationGeneration = _presentationGeneration;
    if (!await authorize(id) ||
        _disposed ||
        lifecycleGeneration != _lifecycleGeneration ||
        presentationGeneration != _presentationGeneration) {
      return;
    }
    final localId = id.hashCode & 0x7fffffff;
    await _gateway.showGenericForeground(
      id: localId,
      payload: jsonEncode(<String, String>{'notificationId': id}),
    );
    if (_disposed ||
        lifecycleGeneration != _lifecycleGeneration ||
        presentationGeneration != _presentationGeneration) {
      try {
        await _gateway.cancelLocal(localId);
      } catch (_) {
        // The foreground notification contains no private payload text.
      }
    }
  }

  void _runDetached(Future<void> Function() operation) {
    unawaited(
      Future<void>.sync(operation).catchError((Object error) {
        _debug('provider callback failed (${error.runtimeType}).');
      }),
    );
  }

  @override
  Future<void> clearDisplayedNotifications() {
    _presentationGeneration++;
    if (_disposed) return Future<void>.value();
    return _gateway.cancelAllLocal();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _lifecycleGeneration++;
    _presentationGeneration++;
    final cancellations = <Future<void>>[];
    if (_foregroundSubscription case final subscription?) {
      cancellations.add(subscription.cancel());
    }
    if (_tapSubscription case final subscription?) {
      cancellations.add(subscription.cancel());
    }
    if (_tokenSubscription case final subscription?) {
      cancellations.add(subscription.cancel());
    }
    _foregroundSubscription = null;
    _tapSubscription = null;
    _tokenSubscription = null;
    for (final cancellation in cancellations) {
      try {
        await cancellation;
      } catch (_) {
        // Continue retiring the remaining provider listeners.
      }
    }
    try {
      await _gateway.cancelAllLocal();
    } catch (_) {
      // Disposal still invalidates every callback even if OS cleanup fails.
    }
  }

  @override
  Future<String?> endpoint() async {
    if (!isConfigured) return null;
    return _gateway.token();
  }

  @override
  Future<NotificationPermissionValue> permission() async {
    if (!isConfigured) return NotificationPermissionValue.denied;
    return _permissionValue(await _gateway.settings());
  }

  @override
  Future<NotificationPermissionValue> requestPermission() async {
    if (!isConfigured) return NotificationPermissionValue.denied;
    final settings = await _gateway.requestPermission();
    return _permissionValue(settings);
  }

  @override
  Future<bool> openSettings() => openAppSettings();

  NotificationPermissionValue _permissionValue(NotificationSettings settings) {
    return switch (settings.authorizationStatus) {
      AuthorizationStatus.authorized => NotificationPermissionValue.authorized,
      AuthorizationStatus.provisional =>
        NotificationPermissionValue.provisional,
      AuthorizationStatus.notDetermined =>
        NotificationPermissionValue.notDetermined,
      AuthorizationStatus.denied => NotificationPermissionValue.denied,
    };
  }

  String? _notificationId(Map<String, dynamic> data) {
    final value = data['notificationId'];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }
}

@pragma('vm:entry-point')
Future<void> careNetFirebaseBackgroundHandler(RemoteMessage message) async {
  final config = FirebaseClientConfig.fromEnvironment();
  if (config.isConfigured && Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: config.options);
  }
}
