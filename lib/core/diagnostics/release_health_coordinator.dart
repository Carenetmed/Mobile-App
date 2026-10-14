import 'dart:async';

import 'package:dio/dio.dart';

import '../../features/Authentication/data/storage/session_store.dart';
import 'diagnostic_consent_store.dart';
import 'release_health_api_client.dart';
import 'release_health_metadata.dart';

/// Best-effort reporting only: this class cannot refresh or clear a session.
class ReleaseHealthCoordinator {
  ReleaseHealthCoordinator({
    required SessionStore sessions,
    required DiagnosticConsentStore consent,
    required ReleaseHealthTransport transport,
    required Future<ReleaseHealthMetadata> Function() metadata,
  }) : _sessions = sessions,
       _consent = consent,
       _transport = transport,
       _metadata = metadata;

  final SessionStore _sessions;
  final DiagnosticConsentStore _consent;
  final ReleaseHealthTransport _transport;
  final Future<ReleaseHealthMetadata> Function() _metadata;
  final Stopwatch _clock = Stopwatch()..start();
  final Map<DiagnosticCode, Duration> _lastAttempt = {};
  bool _disposed = false;
  bool _busy = false;
  bool _reportingSuspended = false;
  int _pendingOperations = 0;
  int _epoch = 0;
  CancelToken? _cancellation;

  // Call immediately on opting out; any pending operation loses permission.
  void cancelPending() {
    _epoch++;
    _cancellation?.cancel();
  }

  void suspendReporting() {
    _reportingSuspended = true;
    cancelPending();
  }

  void resumeReporting() {
    if (!_disposed) _reportingSuspended = false;
  }

  Future<void> report(DiagnosticCode code, {bool fatal = false}) async {
    if (_disposed || _busy || _reportingSuspended || _pendingOperations > 0) {
      return;
    }
    final previous = _lastAttempt[code];
    if (previous != null &&
        _clock.elapsed - previous < const Duration(minutes: 1)) {
      return;
    }
    _busy = true;
    _lastAttempt[code] = _clock.elapsed;
    final epoch = _epoch;
    final cancellation = CancelToken();
    _cancellation = cancellation;
    bool current() => !_disposed && !_reportingSuspended && epoch == _epoch;
    try {
      // Default-off failures must not enter the shared authenticated-store queue.
      final grant = await _bounded(
        _consent.enabledGeneration(),
        const Duration(seconds: 2),
      );
      if (!current() || grant == null) return;
      final snapshot = await _bounded(
        _sessions.capture(),
        const Duration(seconds: 2),
      );
      if (!current() || snapshot == null || snapshot.generation != grant) {
        return;
      }
      final allowed = await _bounded(
        _consent.isEnabledFor(snapshot.generation),
        const Duration(seconds: 2),
      );
      if (!current() || !allowed) return;
      final release = await _bounded(_metadata(), const Duration(seconds: 2));
      if (!current()) return;
      final latest = await _bounded(
        _sessions.capture(),
        const Duration(seconds: 2),
      );
      if (!current() ||
          latest == null ||
          latest.generation != snapshot.generation ||
          latest.session.user.id != snapshot.session.user.id) {
        return;
      }
      // No queue or automatic retry. At most one attempt per code per minute.
      await _bounded(
        _transport.send(
          report: SafeDiagnosticReport(
            code: code,
            release: release,
            fatal: fatal,
          ),
          accessToken: latest.session.accessToken,
          cancelToken: cancellation,
        ),
        const Duration(seconds: 6),
      );
    } catch (_) {
      // Reporting must not recursively report its own failure or affect auth.
    } finally {
      cancellation.cancel();
      if (identical(_cancellation, cancellation)) _cancellation = null;
      _busy = false;
    }
  }

  Future<T> _bounded<T>(Future<T> operation, Duration limit) {
    // A timeout releases the caller, not the underlying plugin operation.
    // Retain capacity until actual settlement so hangs cannot grow a queue.
    _pendingOperations++;
    unawaited(
      operation.then<void>(
        (_) {
          _pendingOperations--;
        },
        onError: (Object _, StackTrace __) {
          _pendingOperations--;
        },
      ),
    );
    return operation.timeout(limit);
  }

  void dispose() {
    _disposed = true;
    cancelPending();
    _clock.stop();
  }
}
