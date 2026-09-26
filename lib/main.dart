import 'dart:async';

import 'package:app_t/app.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/features/Notifications/data/services/firebase_notification_transport.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_coordinator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(careNetFirebaseBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await configureDependencies();
  runApp(const CarenetApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeOptionalNotifications());
  });
}

Future<void> _initializeOptionalNotifications() async {
  final coordinator = sl<NotificationCoordinator>();
  await coordinator.initialize();
  await coordinator.restoreSession();
}
