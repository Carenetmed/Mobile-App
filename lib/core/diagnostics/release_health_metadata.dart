import '../config/app_environment.dart';

enum DiagnosticCode {
  frameworkFailure,
  asynchronousFailure,
  optionalStartupFailure,
}

class ReleaseHealthMetadata {
  ReleaseHealthMetadata({
    required String version,
    required String buildNumber,
    required this.environment,
  }) : version = _validatedVersion(version),
       buildNumber = _validatedBuild(buildNumber);

  final String version;
  final String buildNumber;
  final CareNetEnvironment environment;

  Map<String, String> toJson() => {
    'version': version,
    'buildNumber': buildNumber,
    'environment': environment.name,
    'diagnosticsSchema': '1',
  };

  static String _validatedVersion(String value) {
    if (value.length > 32 ||
        !RegExp(
          r'^\d{1,6}\.\d{1,6}\.\d{1,6}(?:-(?:alpha|beta|rc|dev)(?:\.\d{1,6})?)?$',
        ).hasMatch(value)) {
      throw const FormatException('Invalid release version metadata.');
    }
    return value;
  }

  static String _validatedBuild(String value) {
    if (!RegExp(r'^\d{1,12}$').hasMatch(value)) {
      throw const FormatException('Invalid release build metadata.');
    }
    return value;
  }
}

class SafeDiagnosticReport {
  const SafeDiagnosticReport({
    required this.code,
    required this.release,
    required this.fatal,
  });

  final DiagnosticCode code;
  final ReleaseHealthMetadata release;
  final bool fatal;

  // Deliberately no exception, context, route, user ID, URL, log or payload input.
  Map<String, Object> toJson() => {
    'code': code.name,
    'fatal': fatal,
    'release': release.toJson(),
  };
}
