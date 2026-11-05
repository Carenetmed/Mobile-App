import 'dart:async';
import 'dart:convert';

import 'package:app_t/core/config/app_environment.dart';
import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/diagnostics/diagnostic_consent_store.dart';
import 'package:app_t/core/diagnostics/release_health_api_client.dart';
import 'package:app_t/core/diagnostics/release_health_coordinator.dart';
import 'package:app_t/core/diagnostics/release_health_error_bridge.dart';
import 'package:app_t/core/diagnostics/release_health_metadata.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _PrivateError {
  @override
  String toString() => throw StateError('Private error must not be read.');
}

class _Consent implements DiagnosticConsentStore {
  String? generation;

  @override
  Future<String?> enabledGeneration() async => generation;

  @override
  Future<bool> isEnabledFor(String value) async => generation == value;

  @override
  Future<void> enableFor(String value) async => generation = value;

  @override
  Future<void> disableFor(String value) async {
    if (generation == value) generation = null;
  }
}

class _Sessions extends InMemorySessionStore {
  int captures = 0;

  @override
  Future<SessionSnapshot?> capture() {
    captures++;
    return super.capture();
  }
}

class _CaptureAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{"accepted":true}',
      202,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Sessions sessions;
  late _Consent consent;
  late _CaptureAdapter adapter;
  late Dio dio;
  late ReleaseHealthCoordinator coordinator;
  late ReleaseHealthErrorBridge bridge;
  late Completer<void> reportFinished;

  setUp(() {
    sessions = _Sessions();
    consent = _Consent();
    adapter = _CaptureAdapter();
    dio = Dio()..httpClientAdapter = adapter;
    coordinator = ReleaseHealthCoordinator(
      sessions: sessions,
      consent: consent,
      transport: ReleaseHealthApiClient(
        config: CareNetApiConfig(baseUrl: 'https://api.example.test'),
        dio: dio,
      ),
      metadata:
          () async => ReleaseHealthMetadata(
            version: '1.2.3',
            buildNumber: '42',
            environment: CareNetEnvironment.staging,
          ),
    );
    reportFinished = Completer<void>();
    bridge = ReleaseHealthErrorBridge(
      preserveDebugHandlers: false,
      report: (code) async {
        await coordinator.report(code);
        if (!reportFinished.isCompleted) reportFinished.complete();
      },
    );
  });

  tearDown(() {
    bridge.dispose();
    coordinator.dispose();
    dio.close(force: true);
  });

  test(
    'default-off framework error never reaches the HTTP transport',
    () async {
      await sessions.save(
        AuthSessionModel.fromJson({
          'accessToken': 'synthetic-access-token',
          'refreshToken': 'synthetic-refresh-token',
          'user': {
            'id': 'synthetic-user',
            'role': 'PATIENT',
            'status': 'ACTIVE',
          },
        }),
      );
      bridge.install();

      FlutterError.reportError(FlutterErrorDetails(exception: _PrivateError()));
      await reportFinished.future.timeout(const Duration(seconds: 1));

      expect(adapter.requests, isEmpty);
      expect(sessions.captures, 0);
    },
  );

  test(
    'consented framework error submits only the allowlisted report',
    () async {
      await sessions.save(
        AuthSessionModel.fromJson({
          'accessToken': 'synthetic-access-token',
          'refreshToken': 'synthetic-refresh-token',
          'user': {
            'id': 'synthetic-user',
            'role': 'PATIENT',
            'status': 'ACTIVE',
          },
        }),
      );
      final initial = (await sessions.capture())!;
      await consent.enableFor(initial.generation);
      sessions.captures = 0;
      bridge.install();

      FlutterError.reportError(
        FlutterErrorDetails(
          exception: _PrivateError(),
          informationCollector: () => throw StateError('Private context read.'),
        ),
      );
      await reportFinished.future.timeout(const Duration(seconds: 1));

      final request = adapter.requests.single;
      expect(request.uri.path, '/diagnostics/release-health');
      expect(request.headers['Authorization'], 'Bearer synthetic-access-token');
      final body = switch (request.data) {
        final Map value => Map<String, Object?>.from(value),
        final String value => Map<String, Object?>.from(
          jsonDecode(value) as Map,
        ),
        _ => fail('Expected a JSON object request body.'),
      };
      expect(body, {
        'code': 'frameworkFailure',
        'fatal': false,
        'release': {
          'version': '1.2.3',
          'buildNumber': '42',
          'environment': 'staging',
          'diagnosticsSchema': '1',
        },
      });
      expect(jsonEncode(body), isNot(contains('Private')));
      expect(sessions.captures, 2);
    },
  );
}
