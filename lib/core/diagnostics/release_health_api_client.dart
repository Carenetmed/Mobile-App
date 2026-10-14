import 'dart:async';

import 'package:dio/dio.dart';

import '../config/carenet_api_config.dart';
import '../network/carenet_http_client.dart';
import 'release_health_metadata.dart';

enum DiagnosticSubmissionResult {
  accepted,
  unavailable,
  unauthorized,
  throttled,
  cancelled,
}

abstract class ReleaseHealthTransport {
  Future<DiagnosticSubmissionResult> send({
    required SafeDiagnosticReport report,
    required String accessToken,
    CancelToken? cancelToken,
  });
}

class ReleaseHealthApiClient implements ReleaseHealthTransport {
  ReleaseHealthApiClient({required CareNetApiConfig config, Dio? dio})
    : _config = config,
      _dio = dio ?? CareNetHttpClient.create() {
    _dio.options.connectTimeout = const Duration(seconds: 3);
  }

  final CareNetApiConfig _config;
  final Dio _dio;

  @override
  Future<DiagnosticSubmissionResult> send({
    required SafeDiagnosticReport report,
    required String accessToken,
    CancelToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled ?? false) {
      return DiagnosticSubmissionResult.cancelled;
    }
    final baseUrl = _config.normalizedBaseUrl;
    if (baseUrl == null || accessToken.trim().isEmpty) {
      return DiagnosticSubmissionResult.unavailable;
    }

    // Link caller cancellation without cancelling or replacing its token.
    final requestToken = CancelToken();
    var active = true;
    var deadlineExpired = false;
    unawaited(
      cancelToken?.whenCancel.then((_) {
        if (active) requestToken.cancel();
      }),
    );
    try {
      final response = await _dio
          .post<Object?>(
            '$baseUrl/diagnostics/release-health',
            data: report.toJson(),
            cancelToken: requestToken,
            options: Options(
              headers: {'Authorization': 'Bearer $accessToken'},
              contentType: Headers.jsonContentType,
              sendTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
              followRedirects: false,
              validateStatus: (_) => true,
            ),
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              deadlineExpired = true;
              requestToken.cancel();
              throw TimeoutException('Diagnostic submission deadline.');
            },
          );
      if (cancelToken?.isCancelled ?? false) {
        return DiagnosticSubmissionResult.cancelled;
      }
      return switch (response.statusCode) {
        401 => DiagnosticSubmissionResult.unauthorized,
        429 => DiagnosticSubmissionResult.throttled,
        202
            when response.data is Map &&
                (response.data as Map).length == 1 &&
                (response.data as Map)['accepted'] == true =>
          DiagnosticSubmissionResult.accepted,
        _ => DiagnosticSubmissionResult.unavailable,
      };
    } on DioException catch (error) {
      return !deadlineExpired &&
              (CancelToken.isCancel(error) ||
                  (cancelToken?.isCancelled ?? false))
          ? DiagnosticSubmissionResult.cancelled
          : DiagnosticSubmissionResult.unavailable;
    } catch (_) {
      return !deadlineExpired && (cancelToken?.isCancelled ?? false)
          ? DiagnosticSubmissionResult.cancelled
          : DiagnosticSubmissionResult.unavailable;
    } finally {
      active = false;
    }
  }
}
