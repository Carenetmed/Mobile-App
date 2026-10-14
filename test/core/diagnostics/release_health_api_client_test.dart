import 'dart:async';
import 'dart:typed_data';

import 'package:app_t/core/config/app_environment.dart';
import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/diagnostics/release_health_api_client.dart';
import 'package:app_t/core/diagnostics/release_health_metadata.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final report = SafeDiagnosticReport(
    code: DiagnosticCode.frameworkFailure,
    release: ReleaseHealthMetadata(
      version: '1.0.0',
      buildNumber: '1',
      environment: CareNetEnvironment.staging,
    ),
    fatal: true,
  );

  Future<DiagnosticSubmissionResult> send(
    ReleaseHealthTransport client, {
    String token = 'test-jwt',
    CancelToken? cancelToken,
  }) =>
      client.send(report: report, accessToken: token, cancelToken: cancelToken);

  test(
    'posts only allowlisted metadata with JWT and bounded options',
    () async {
      final adapter = _FakeAdapter();
      final client = _client(adapter);
      expect(await send(client), DiagnosticSubmissionResult.accepted);
      final request = adapter.requests.single;
      expect(
        request.path,
        'https://api.example.test/diagnostics/release-health',
      );
      expect(request.method, 'POST');
      expect(request.headers['Authorization'], 'Bearer test-jwt');
      expect(request.data, {
        'code': 'frameworkFailure',
        'fatal': true,
        'release': {
          'version': '1.0.0',
          'buildNumber': '1',
          'environment': 'staging',
          'diagnosticsSchema': '1',
        },
      });
      expect(request.queryParameters, isEmpty);
      expect(request.extra, isEmpty);
      expect(
        request.headers.keys.any(
          (key) => key.toLowerCase().contains('idempotency'),
        ),
        isFalse,
      );
      expect(request.connectTimeout, const Duration(seconds: 3));
      expect(request.sendTimeout, const Duration(seconds: 3));
      expect(request.receiveTimeout, const Duration(seconds: 3));
      expect(request.followRedirects, isFalse);
    },
  );

  for (final status in [200, 201, 202, 204, 301, 400, 401, 403, 429, 500]) {
    test('maps status $status without retries', () async {
      final adapter = _FakeAdapter(status: status);
      expect(await send(_client(adapter)), switch (status) {
        202 => DiagnosticSubmissionResult.accepted,
        401 => DiagnosticSubmissionResult.unauthorized,
        429 => DiagnosticSubmissionResult.throttled,
        _ => DiagnosticSubmissionResult.unavailable,
      });
      expect(adapter.requests, hasLength(1));
    });
  }

  for (final body in [
    '{}',
    '{"accepted":false}',
    '{"accepted":"true"}',
    '{"accepted":1}',
    '{"accepted":true,"extra":true}',
    'null',
    '[]',
    'true',
    '"accepted"',
    'not-json',
  ]) {
    test('rejects non-contract body $body', () async {
      expect(
        await send(_client(_FakeAdapter(body: body))),
        DiagnosticSubmissionResult.unavailable,
      );
    });
  }

  test('missing config or token never requests', () async {
    final adapter = _FakeAdapter();
    expect(
      await send(_client(adapter, baseUrl: '  ')),
      DiagnosticSubmissionResult.unavailable,
    );
    expect(
      await send(_client(adapter), token: '  '),
      DiagnosticSubmissionResult.unavailable,
    );
    expect(adapter.requests, isEmpty);
  });

  test('already cancelled token never requests', () async {
    final adapter = _FakeAdapter();
    final token = CancelToken()..cancel('private reason');
    expect(
      await send(_client(adapter), cancelToken: token),
      DiagnosticSubmissionResult.cancelled,
    );
    expect(adapter.requests, isEmpty);
  });

  test(
    'caller cancellation reaches adapter without exposing its reason',
    () async {
      final adapter = _FakeAdapter(hang: true);
      final token = CancelToken();
      final result = send(_client(adapter), cancelToken: token);
      await adapter.started.future;
      token.cancel('private reason');
      expect(await result, DiagnosticSubmissionResult.cancelled);
      await adapter.cancelled.future;
      expect(token.cancelError?.error, 'private reason');
      expect(adapter.requests, hasLength(1));
    },
  );

  test('five second deadline cancels Dio but preserves caller token', () async {
    final adapter = _FakeAdapter(hang: true);
    final token = CancelToken();
    final watch = Stopwatch()..start();
    expect(
      await send(_client(adapter), cancelToken: token),
      DiagnosticSubmissionResult.unavailable,
    );
    await adapter.cancelled.future;
    expect(watch.elapsed, greaterThanOrEqualTo(const Duration(seconds: 5)));
    expect(watch.elapsed, lessThan(const Duration(seconds: 8)));
    expect(token.isCancelled, isFalse);
    expect(adapter.requests, hasLength(1));
  });

  test('Dio cancellation maps to cancelled', () async {
    final adapter = _FakeAdapter(failure: DioExceptionType.cancel);
    expect(await send(_client(adapter)), DiagnosticSubmissionResult.cancelled);
    expect(adapter.requests, hasLength(1));
  });

  for (final type in [
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
    DioExceptionType.unknown,
  ]) {
    test('contains $type without raw exception propagation', () async {
      final adapter = _FakeAdapter(failure: type);
      expect(
        await send(_client(adapter)),
        DiagnosticSubmissionResult.unavailable,
      );
      expect(adapter.requests, hasLength(1));
    });
  }
}

ReleaseHealthApiClient _client(
  _FakeAdapter adapter, {
  String baseUrl = 'https://api.example.test/',
}) => ReleaseHealthApiClient(
  config: CareNetApiConfig(baseUrl: baseUrl),
  dio: Dio()..httpClientAdapter = adapter,
);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({
    this.status = 202,
    this.body = '{"accepted":true}',
    this.hang = false,
    this.failure,
  });

  final int status;
  final String body;
  final bool hang;
  final DioExceptionType? failure;
  final requests = <RequestOptions>[];
  final started = Completer<void>();
  final cancelled = Completer<void>();

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    started.complete();
    if (failure case final type?) {
      throw DioException(
        requestOptions: options,
        type: type,
        error: StateError('private raw content'),
      );
    }
    if (hang) {
      await cancelFuture;
      cancelled.complete();
    }
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
