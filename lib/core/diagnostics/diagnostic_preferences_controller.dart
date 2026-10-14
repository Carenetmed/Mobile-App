import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/Authentication/data/storage/session_store.dart';
import 'diagnostic_consent_store.dart';
import 'release_health_coordinator.dart';

/// App-scoped so failed opt-out remains paused across account-page navigation.
/// Call [sessionChanged] on account exit/replacement.
class DiagnosticPreferencesController extends ChangeNotifier {
  DiagnosticPreferencesController({
    required SessionStore sessions,
    required DiagnosticConsentStore consent,
    required ReleaseHealthCoordinator coordinator,
    this.operationTimeout = const Duration(seconds: 2),
  }) : _sessions = sessions,
       _consent = consent,
       _coordinator = coordinator {
    _coordinator.suspendReporting();
  }

  final SessionStore _sessions;
  final DiagnosticConsentStore _consent;
  final ReleaseHealthCoordinator _coordinator;
  final Duration operationTimeout;
  SessionSnapshot? _binding;
  bool _disposed = false;
  bool _inFlight = false;
  bool _explicitChoiceRequired = false;
  int _epoch = 0;
  bool _enabled = false;
  bool _busy = false;
  String? _message;

  bool get enabled => _enabled;
  bool get busy => _busy;
  bool get canChange => !_disposed && !_inFlight && _binding != null;
  bool get canRetry => !_disposed && !_inFlight;
  String? get message => _message;

  bool _current(int epoch) => !_disposed && epoch == _epoch;
  bool _matches(SessionSnapshot? value, SessionSnapshot expected) =>
      value?.generation == expected.generation &&
      value?.session.user.id == expected.session.user.id;

  /// No polling: account lifecycle must explicitly invalidate the old binding.
  void sessionChanged() {
    if (_disposed) return;
    _epoch++;
    _coordinator.suspendReporting();
    _binding = null;
    _enabled = false;
    _busy = false;
    _message = 'Sharing is paused. Check your preference to continue.';
    notifyListeners();
  }

  Future<void> initialize() => _run((epoch) async {
    final snapshot = await _sessions.capture();
    if (!_current(epoch)) return;
    _binding = snapshot;
    if (snapshot == null) return;
    final allowed = await _consent.isEnabledFor(snapshot.generation);
    final latest = await _sessions.capture();
    if (!_current(epoch)) return;
    if (!_matches(latest, snapshot)) {
      sessionChanged();
      return;
    }
    _enabled = allowed && !_explicitChoiceRequired;
    if (_enabled) _coordinator.resumeReporting();
  });

  Future<void> setEnabled(bool value) async {
    if (_disposed) return;
    _coordinator.suspendReporting();
    _explicitChoiceRequired = true;
    _enabled = false;
    if (_inFlight) {
      // Revocation invalidates an outstanding enable without queuing storage.
      _epoch++;
      _busy = false;
      _message = 'Change not saved. Sharing is paused. Try again when ready.';
      notifyListeners();
      return;
    }
    final expected = _binding;
    if (expected == null) {
      _message = 'Sign in again to change this preference.';
      notifyListeners();
      return;
    }
    await _run((epoch) async {
      final latest = await _sessions.capture();
      if (!_current(epoch)) return;
      if (!_matches(latest, expected)) {
        sessionChanged();
        return;
      }
      if (value) {
        await _consent.enableFor(expected.generation);
      } else {
        await _consent.disableFor(expected.generation);
      }
      final after = await _sessions.capture();
      if (!_current(epoch)) return;
      if (!_matches(after, expected)) {
        sessionChanged();
        return;
      }
      _explicitChoiceRequired = false;
      _enabled = value;
      if (value) _coordinator.resumeReporting();
    });
  }

  Future<void> _run(Future<void> Function(int) operation) async {
    if (_disposed || _inFlight) return;
    _coordinator.suspendReporting();
    _enabled = false;
    _inFlight = true;
    _busy = true;
    _message = null;
    final epoch = ++_epoch;
    notifyListeners();
    // Timeout bounds the UI, not the native operation. Keep the lock until the
    // original operation settles, and never let its late result resume sending.
    final pending = Future<void>.sync(() => operation(epoch)).whenComplete(() {
      _inFlight = false;
      if (!_disposed) notifyListeners();
    });
    try {
      await pending.timeout(operationTimeout);
    } catch (_) {
      if (_current(epoch)) {
        _epoch++;
        _explicitChoiceRequired = true;
        _enabled = false;
        _coordinator.suspendReporting();
        _message =
            'Could not save or check this preference. '
            'Sharing is paused in this app session. Please try again.';
      }
    } finally {
      if (!_disposed && (_epoch == epoch || _epoch == epoch + 1)) {
        _busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    if (_inFlight || _explicitChoiceRequired) {
      _coordinator.suspendReporting();
    }
    super.dispose();
  }
}
