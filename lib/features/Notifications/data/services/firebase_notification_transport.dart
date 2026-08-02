import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

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
      projectId.trim().isNotEmpty &&
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

abstract class NotificationTransport {
  bool get isConfigured;
  Future<void> initialize({
    required Future<void> Function() onForegroundMessage,
    required NotificationTapCallback onTap,
    required Future<void> Function() onTokenRefresh,
  });
  Future<NotificationPermissionValue> permission();
  Future<NotificationPermissionValue> requestPermission();
  Future<String?> endpoint();
  Future<bool> openSettings();
}

class FirebaseNotificationTransport implements NotificationTransport {
  FirebaseNotificationTransport({
    FirebaseClientConfig? config,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _config = config ?? FirebaseClientConfig.fromEnvironment(),
       _messaging = messaging,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'carenet_transactional',
    'CareNet updates',
    description: 'Appointment and account updates from CareNet.',
    importance: Importance.high,
  );

  final FirebaseClientConfig _config;
  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _tapSubscription;
  StreamSubscription<String>? _tokenSubscription;

  @override
  bool get isConfigured => _config.isConfigured;

  @override
  Future<void> initialize({
    required Future<void> Function() onForegroundMessage,
    required NotificationTapCallback onTap,
    required Future<void> Function() onTokenRefresh,
  }) async {
    if (!isConfigured) return;
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: _config.options);
    }
    final messaging = _messaging ?? FirebaseMessaging.instance;
    _messaging = messaging;
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('launcher_icon'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) async {
        final id = _notificationIdFromPayload(response.payload);
        if (id != null) await onTap(id);
      },
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      unawaited(_showForeground(message, onForegroundMessage));
    });
    await _tapSubscription?.cancel();
    _tapSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final id = _notificationId(message.data);
      if (id != null) unawaited(onTap(id));
    });
    await _tokenSubscription?.cancel();
    _tokenSubscription = messaging.onTokenRefresh.listen((_) {
      unawaited(onTokenRefresh());
    });
    final initial = await messaging.getInitialMessage();
    final initialId = initial == null ? null : _notificationId(initial.data);
    if (initialId != null) await onTap(initialId);
  }

  Future<void> _showForeground(
    RemoteMessage message,
    Future<void> Function() onForegroundMessage,
  ) async {
    await onForegroundMessage();
    final id = _notificationId(message.data);
    if (id == null) return;
    final notification = message.notification;
    await _localNotifications.show(
      id: id.hashCode & 0x7fffffff,
      title: notification?.title ?? 'CareNet update',
      body:
          notification?.body ?? 'Open CareNet to view the latest update.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'carenet_transactional',
          'CareNet updates',
          channelDescription: 'Appointment and account updates from CareNet.',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'launcher_icon',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(<String, String>{'notificationId': id}),
    );
  }

  @override
  Future<String?> endpoint() async {
    if (!isConfigured) return null;
    return (_messaging ?? FirebaseMessaging.instance).getToken();
  }

  @override
  Future<NotificationPermissionValue> permission() async {
    if (!isConfigured) return NotificationPermissionValue.denied;
    return _permissionValue(
      await (_messaging ?? FirebaseMessaging.instance)
          .getNotificationSettings(),
    );
  }

  @override
  Future<NotificationPermissionValue> requestPermission() async {
    if (!isConfigured) return NotificationPermissionValue.denied;
    final settings = await (_messaging ?? FirebaseMessaging.instance)
        .requestPermission(alert: true, badge: true, sound: true);
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

  String? _notificationIdFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? _notificationId(decoded) : null;
    } catch (_) {
      return null;
    }
  }
}

@pragma('vm:entry-point')
Future<void> careNetFirebaseBackgroundHandler(RemoteMessage message) async {
  final config = FirebaseClientConfig.fromEnvironment();
  if (config.isConfigured && Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: config.options);
  }
}
