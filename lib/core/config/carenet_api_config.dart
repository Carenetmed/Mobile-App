class CareNetApiConfig {
  const CareNetApiConfig({required this.baseUrl});

  static const String environmentKey = 'CARENET_API_BASE_URL';

  factory CareNetApiConfig.fromEnvironment() {
    return const CareNetApiConfig(
      baseUrl: String.fromEnvironment(environmentKey),
    );
  }

  final String baseUrl;

  bool get isConfigured => normalizedBaseUrl != null;

  String? get normalizedBaseUrl {
    final value = baseUrl.trim();
    if (value.isEmpty) {
      return null;
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}

class MissingCareNetApiConfigException implements Exception {
  const MissingCareNetApiConfigException();

  @override
  String toString() {
    return 'CareNet API base URL is not configured.';
  }
}
