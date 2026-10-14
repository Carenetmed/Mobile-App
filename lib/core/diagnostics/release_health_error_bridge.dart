import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'release_health_metadata.dart';

typedef SafeDiagnosticReporter = Future<void> Function(DiagnosticCode code);

/// Raw callback arguments are never forwarded to the reporting layer.
class ReleaseHealthErrorBridge {
  ReleaseHealthErrorBridge({
    required SafeDiagnosticReporter report,
    bool preserveDebugHandlers = kDebugMode,
  }) : _report = report,
       _preserveDebugHandlers = preserveDebugHandlers;

  final SafeDiagnosticReporter _report;
  final bool _preserveDebugHandlers;
  FlutterExceptionHandler? _previousFramework;
  ErrorCallback? _previousPlatform;
  FlutterExceptionHandler? _framework;
  ErrorCallback? _platform;
  bool _installed = false;

  void install() {
    if (_installed) return;
    _installed = true;
    _previousFramework = FlutterError.onError;
    _previousPlatform = PlatformDispatcher.instance.onError;
    _framework = (details) {
      _submit(DiagnosticCode.frameworkFailure);
      if (_preserveDebugHandlers) {
        _previousFramework?.call(details);
      } else {
        debugPrint('CareNet encountered a display error.');
      }
    };
    _platform = (error, stack) {
      _submit(DiagnosticCode.asynchronousFailure);
      if (_preserveDebugHandlers) {
        return _previousPlatform?.call(error, stack) ?? false;
      }
      // Suppress the embedding's raw stderr fallback in distributable builds.
      // This is not a claim of recovery or proof that the process survived.
      debugPrint('CareNet encountered an unexpected error.');
      return true;
    };
    FlutterError.onError = _framework;
    PlatformDispatcher.instance.onError = _platform;
  }

  void _submit(DiagnosticCode code) {
    try {
      unawaited(_report(code).catchError((Object _, StackTrace __) {}));
    } catch (_) {
      // Optional diagnostics must not recursively throw from an error handler.
    }
  }

  void dispose() {
    if (!_installed) return;
    if (identical(FlutterError.onError, _framework)) {
      FlutterError.onError = _previousFramework;
    }
    if (identical(PlatformDispatcher.instance.onError, _platform)) {
      PlatformDispatcher.instance.onError = _previousPlatform;
    }
    _installed = false;
  }
}
