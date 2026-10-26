import 'package:flutter/foundation.dart';

import 'messaging_realtime_config.dart';

enum CareNetEnvironment { staging, production }

class AppEnvironmentConfig {
  const AppEnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.firebaseProjectId,
    required this.firebaseAppId,
    required this.googleServerClientId,
    this.messagingWsUrl = '',
  });

  static const String canonicalFirebaseProjectId =
      'project-a96784ee-811c-46ab-a7b';
  static const String canonicalStagingApiHost =
      'carenet-staging-mobile-gateway-7ncephib.uc.gateway.dev';
  static const String? canonicalProductionApiHost = null;
  static const String stagingAndroidApplicationId = 'com.carenet.app.staging';
  static const String productionAndroidApplicationId = 'com.carenet.app';
  static const String stagingAndroidFirebaseAppId =
      '1:599365440227:android:fb589a833cd2e8b251abd6';
  static const String productionAndroidFirebaseAppId =
      '1:599365440227:android:7fbb7d5e3784327751abd6';
  static const String stagingIosFirebaseAppId =
      '1:599365440227:ios:6680baeffacc0ce051abd6';
  static const String productionIosFirebaseAppId =
      '1:599365440227:ios:fac1f0bd4f73677051abd6';

  factory AppEnvironmentConfig.fromEnvironment() {
    const environment = String.fromEnvironment('CARENET_ENVIRONMENT');
    return AppEnvironmentConfig(
      environment: switch (environment.trim().toLowerCase()) {
        'staging' => CareNetEnvironment.staging,
        'production' => CareNetEnvironment.production,
        _ =>
          throw const FormatException(
            'CARENET_ENVIRONMENT must be staging or production.',
          ),
      },
      apiBaseUrl: const String.fromEnvironment('CARENET_API_BASE_URL'),
      firebaseProjectId: const String.fromEnvironment(
        'CARENET_FIREBASE_PROJECT_ID',
      ),
      firebaseAppId: const String.fromEnvironment('CARENET_FIREBASE_APP_ID'),
      googleServerClientId: const String.fromEnvironment(
        'GOOGLE_SIGN_IN_SERVER_CLIENT_ID',
      ),
      messagingWsUrl: const String.fromEnvironment('CARENET_MESSAGING_WS_URL'),
    );
  }

  final CareNetEnvironment environment;
  final String apiBaseUrl;
  final String firebaseProjectId;
  final String firebaseAppId;
  final String googleServerClientId;
  final String messagingWsUrl;

  List<String> validationErrors({required bool requireProviders}) {
    final errors = <String>[];
    final apiUri = Uri.tryParse(apiBaseUrl.trim());
    if (apiUri == null ||
        !apiUri.hasScheme ||
        !apiUri.hasAuthority ||
        apiUri.host.isEmpty ||
        (apiUri.scheme != 'http' && apiUri.scheme != 'https')) {
      errors.add('CARENET_API_BASE_URL must be an absolute URL.');
    } else {
      if (apiUri.scheme != 'https') {
        errors.add('CARENET_API_BASE_URL must use HTTPS.');
      }
      if (apiUri.userInfo.isNotEmpty || apiUri.hasQuery || apiUri.hasFragment) {
        errors.add(
          'CARENET_API_BASE_URL cannot contain credentials, a query, or a fragment.',
        );
      }
      if (environment == CareNetEnvironment.production) {
        final host = apiUri.host.toLowerCase();
        final productionHost = canonicalProductionApiHost;
        if (productionHost == null || host != productionHost) {
          errors.add('Production API host is not registered as canonical.');
        }
      } else if (apiUri.host.toLowerCase() != canonicalStagingApiHost) {
        errors.add('Staging API host is not the registered CareNet gateway.');
      }
    }
    if (firebaseProjectId.trim() != canonicalFirebaseProjectId) {
      errors.add('Firebase must use the canonical CareNet project.');
    }
    if (firebaseAppId.trim().isEmpty) {
      errors.add('CARENET_FIREBASE_APP_ID is required.');
    }
    if (requireProviders && googleServerClientId.trim().isEmpty) {
      errors.add('GOOGLE_SIGN_IN_SERVER_CLIENT_ID is required.');
    }
    if (messagingWsUrl.trim().isNotEmpty) {
      errors.addAll(
        MessagingRealtimeConfig(
          environment: environment.name,
          url: messagingWsUrl,
        ).validationErrors(),
      );
    }
    return errors;
  }

  List<String> startupValidationErrors({
    required String? selectedFlavor,
    required TargetPlatform platform,
    required bool requireProviders,
  }) {
    final errors = validationErrors(requireProviders: requireProviders);
    final flavor = selectedFlavor?.trim().toLowerCase();
    final flavorEnvironment = switch (flavor) {
      'staging' => CareNetEnvironment.staging,
      'production' => CareNetEnvironment.production,
      _ => null,
    };
    if (flavorEnvironment == null) {
      errors.add('A supported staging or production build flavor is required.');
    } else if (flavorEnvironment != environment) {
      errors.add('CARENET_ENVIRONMENT must match the selected build flavor.');
    }

    final expectedFirebaseAppId = switch ((environment, platform)) {
      (CareNetEnvironment.staging, TargetPlatform.android) =>
        stagingAndroidFirebaseAppId,
      (CareNetEnvironment.production, TargetPlatform.android) =>
        productionAndroidFirebaseAppId,
      (CareNetEnvironment.staging, TargetPlatform.iOS) =>
        stagingIosFirebaseAppId,
      (CareNetEnvironment.production, TargetPlatform.iOS) =>
        productionIosFirebaseAppId,
      _ => null,
    };
    if (expectedFirebaseAppId == null) {
      errors.add('This platform has no registered CareNet Firebase app.');
    } else if (firebaseAppId.trim().isNotEmpty &&
        firebaseAppId.trim() != expectedFirebaseAppId) {
      errors.add('Firebase app ID does not match the selected flavor.');
    }
    return errors;
  }

  void validateForStartup({
    required String? selectedFlavor,
    required TargetPlatform platform,
    required bool requireProviders,
  }) {
    final errors = startupValidationErrors(
      selectedFlavor: selectedFlavor,
      platform: platform,
      requireProviders: requireProviders,
    );
    if (errors.isNotEmpty) throw StateError(errors.join(' '));
  }

  void validate({required bool requireProviders}) {
    final errors = validationErrors(requireProviders: requireProviders);
    if (errors.isNotEmpty) throw StateError(errors.join(' '));
  }
}
