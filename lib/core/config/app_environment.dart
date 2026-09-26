enum CareNetEnvironment { staging, production }

class AppEnvironmentConfig {
  const AppEnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.firebaseProjectId,
    required this.firebaseAppId,
    required this.googleServerClientId,
  });

  static const String canonicalFirebaseProjectId =
      'project-a96784ee-811c-46ab-a7b';
  static const String stagingAndroidApplicationId = 'com.carenet.app.staging';
  static const String productionAndroidApplicationId = 'com.carenet.app';

  factory AppEnvironmentConfig.fromEnvironment() {
    const environment = String.fromEnvironment('CARENET_ENVIRONMENT');
    return AppEnvironmentConfig(
      environment: switch (environment.trim().toLowerCase()) {
        'staging' => CareNetEnvironment.staging,
        'production' => CareNetEnvironment.production,
        _ => throw const FormatException(
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
    );
  }

  final CareNetEnvironment environment;
  final String apiBaseUrl;
  final String firebaseProjectId;
  final String firebaseAppId;
  final String googleServerClientId;

  List<String> validationErrors({required bool requireProviders}) {
    final errors = <String>[];
    final apiUri = Uri.tryParse(apiBaseUrl.trim());
    if (apiUri == null || !apiUri.hasScheme || !apiUri.hasAuthority) {
      errors.add('CARENET_API_BASE_URL must be an absolute URL.');
    } else if (environment == CareNetEnvironment.production &&
        apiUri.scheme != 'https') {
      errors.add('Production API traffic must use HTTPS.');
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
    return errors;
  }

  void validate({required bool requireProviders}) {
    final errors = validationErrors(requireProviders: requireProviders);
    if (errors.isNotEmpty) throw StateError(errors.join(' '));
  }
}
