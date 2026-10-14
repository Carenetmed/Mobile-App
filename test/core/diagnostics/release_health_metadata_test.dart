import 'package:app_t/core/config/app_environment.dart';
import 'package:app_t/core/diagnostics/release_health_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ReleaseHealthMetadata release() => ReleaseHealthMetadata(
    version: '1.0.0',
    buildNumber: '42',
    environment: CareNetEnvironment.staging,
  );

  test('release metadata contains only reviewed build fields', () {
    expect(release().toJson(), {
      'version': '1.0.0',
      'buildNumber': '42',
      'environment': 'staging',
      'diagnosticsSchema': '1',
    });
  });

  test('report accepts a closed code and no arbitrary error fields', () {
    final report = SafeDiagnosticReport(
      code: DiagnosticCode.frameworkFailure,
      release: release(),
      fatal: false,
    );
    expect(report.toJson(), {
      'code': 'frameworkFailure',
      'fatal': false,
      'release': release().toJson(),
    });
  });

  test('mutating a serialized map does not mutate later reports', () {
    final metadata = release();
    metadata.toJson()['userId'] = 'synthetic-private-id';
    expect(metadata.toJson().containsKey('userId'), isFalse);
  });

  test('accepts a bounded prerelease build without runtime labels', () {
    expect(
      ReleaseHealthMetadata(
        version: '1.2.3-beta.2',
        buildNumber: '123',
        environment: CareNetEnvironment.production,
      ).toJson()['version'],
      '1.2.3-beta.2',
    );
  });

  test('rejects URLs, account-like values and free text as versions', () {
    for (final version in [
      'https://example.invalid/?token=synthetic-secret',
      'patient@example.invalid',
      'synthetic health concern',
      '1.0.0\nsynthetic-private-detail',
      '',
      '1.0.0+synthetic-private-id',
      '1.0.0-private',
      '1.0.0\n',
    ]) {
      expect(
        () => ReleaseHealthMetadata(
          version: version,
          buildNumber: '42',
          environment: CareNetEnvironment.staging,
        ),
        throwsFormatException,
      );
    }
  });

  test('rejects unbounded or nonnumeric build values', () {
    for (final build in ['', '1\nprivate', 'account-42', '1234567890123']) {
      expect(
        () => ReleaseHealthMetadata(
          version: '1.0.0',
          buildNumber: build,
          environment: CareNetEnvironment.staging,
        ),
        throwsFormatException,
      );
    }
  });

  test('metadata validation errors do not repeat rejected private input', () {
    const privateValue = 'synthetic-private-token';
    try {
      ReleaseHealthMetadata(
        version: privateValue,
        buildNumber: '1',
        environment: CareNetEnvironment.staging,
      );
      fail('Expected metadata rejection');
    } on FormatException catch (error) {
      expect(error.toString(), isNot(contains(privateValue)));
    }
  });
}
