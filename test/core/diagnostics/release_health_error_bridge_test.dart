import 'package:app_t/core/diagnostics/release_health_error_bridge.dart';
import 'package:app_t/core/diagnostics/release_health_metadata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _PrivateError {
  @override
  String toString() => throw StateError('Must not stringify private errors');
}

void main() {
  test('release framework handling never evaluates private context', () async {
    final codes = <DiagnosticCode>[];
    final bridge = ReleaseHealthErrorBridge(
      preserveDebugHandlers: false,
      report: (code) async => codes.add(code),
    );
    final previous = FlutterError.onError;
    bridge.install();
    try {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: _PrivateError(),
          informationCollector: () => throw StateError('Private context read'),
        ),
      );
      expect(codes, [DiagnosticCode.frameworkFailure]);
    } finally {
      bridge.dispose();
    }
    expect(FlutterError.onError, same(previous));
  });

  test(
    'release platform handling suppresses raw fallback without stringify',
    () {
      final codes = <DiagnosticCode>[];
      final bridge = ReleaseHealthErrorBridge(
        preserveDebugHandlers: false,
        report: (code) async => codes.add(code),
      );
      final previous = PlatformDispatcher.instance.onError;
      bridge.install();
      try {
        expect(
          PlatformDispatcher.instance.onError!(
            _PrivateError(),
            StackTrace.empty,
          ),
          isTrue,
        );
        expect(codes, [DiagnosticCode.asynchronousFailure]);
      } finally {
        bridge.dispose();
      }
      expect(PlatformDispatcher.instance.onError, same(previous));
    },
  );

  test('synchronous reporter failure cannot escape framework handler', () {
    final bridge = ReleaseHealthErrorBridge(
      preserveDebugHandlers: false,
      report: (_) => throw StateError('synthetic diagnostic failure'),
    );
    bridge.install();
    try {
      expect(
        () => FlutterError.reportError(
          FlutterErrorDetails(exception: _PrivateError()),
        ),
        returnsNormally,
      );
    } finally {
      bridge.dispose();
    }
  });

  test('disposing does not overwrite a handler installed later', () {
    final bridge = ReleaseHealthErrorBridge(report: (_) async {});
    final previous = FlutterError.onError;
    bridge.install();
    void later(FlutterErrorDetails _) {}
    FlutterError.onError = later;
    bridge.dispose();
    expect(FlutterError.onError, same(later));
    FlutterError.onError = previous;
  });
}
