import 'dart:async';

import 'package:app_t/app.dart';
import 'package:app_t/core/config/app_environment.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/presentation/carenet_presentation.dart';
import 'package:app_t/core/diagnostics/release_health_coordinator.dart';
import 'package:app_t/core/diagnostics/release_health_error_bridge.dart';
import 'package:app_t/core/diagnostics/release_health_metadata.dart';
import 'package:app_t/features/Notifications/data/services/firebase_notification_transport.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_coordinator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, appFlavor;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    AppEnvironmentConfig.fromEnvironment().validateForStartup(
      selectedFlavor: appFlavor,
      platform: defaultTargetPlatform,
      requireProviders: false,
    );
  } on FormatException {
    runApp(const AppEnvironmentStartupFailure());
    return;
  } on StateError {
    runApp(const AppEnvironmentStartupFailure());
    return;
  }

  FirebaseMessaging.onBackgroundMessage(careNetFirebaseBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await configureDependencies();
  await CareNetPresentation.initialize();
  sl<ReleaseHealthErrorBridge>().install();
  runApp(const CarenetApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeOptionalNotifications());
  });
}

class AppEnvironmentStartupFailure extends StatelessWidget {
  const AppEnvironmentStartupFailure({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'CareNet could not start because this app has an invalid '
                'environment configuration. Reinstall the correct app '
                'version or contact support.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _initializeOptionalNotifications() async {
  try {
    final coordinator = sl<NotificationCoordinator>();
    await (() async {
      await coordinator.initialize();
      await coordinator.restoreSession();
    })().timeout(const Duration(seconds: 15));
  } catch (_) {
    await sl<ReleaseHealthCoordinator>().report(
      DiagnosticCode.optionalStartupFailure,
    );
  }
}
