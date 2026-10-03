import 'dart:async';

import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Consultation/data/repositories/consultation_repository.dart';
import 'package:app_t/features/Consultation/domain/entities/consultation_entities.dart';
import 'package:app_t/features/Consultation/domain/services/consultation_permission_service.dart';
import 'package:app_t/features/Consultation/domain/services/rtc_room_adapter.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class ConsultationController extends ChangeNotifier {
  ConsultationController({
    required this.appointmentId,
    required ConsultationGateway repository,
    required SessionStore sessionStore,
    required ConsultationPermissionService permissionService,
    required RtcRoomAdapter room,
    String? deviceSessionId,
    Duration pollingInterval = const Duration(seconds: 5),
    DateTime Function()? now,
  }) : _repository = repository,
       _sessionStore = sessionStore,
       _permissionService = permissionService,
       _room = room,
       _deviceSessionId = deviceSessionId ?? const Uuid().v4(),
       _pollingInterval = pollingInterval,
       _now = now ?? DateTime.now {
    _room.addListener(_onRoomChanged);
  }

  final String appointmentId;
  final ConsultationGateway _repository;
  final SessionStore _sessionStore;
  final ConsultationPermissionService _permissionService;
  final RtcRoomAdapter _room;
  final String _deviceSessionId;
  final Duration _pollingInterval;
  final DateTime Function() _now;

  ConsultationProjection? projection;
  ConsultationParticipantRole viewerRole = ConsultationParticipantRole.unknown;
  ConsultationPermissionResult? permissions;
  bool microphoneEnabled = true;
  bool cameraEnabled = true;
  bool isLoading = false;
  bool isRefreshing = false;
  bool isPreparing = false;
  bool isActing = false;
  bool isReporting = false;
  String? errorMessage;
  String? actionMessage;
  String? incidentMessage;

  String? _accountId;
  Future<void>? _activeProjectionLoad;
  Future<void>? _activeAction;
  Timer? _pollTimer;
  int _generation = 0;
  bool _disposed = false;
  Future<void>? _accountRevocation;

  RtcRoomAdapter get room => _room;

  ConsultationMode? get supportedMode => projection?.mode;

  ConsultationMode get mode => supportedMode ?? ConsultationMode.audio;

  bool get isConnected =>
      _room.connectionState == RtcConnectionState.connected ||
      _room.connectionState == RtcConnectionState.reconnecting;

  bool get canPrepare =>
      projection != null &&
      supportedMode != null &&
      !projection!.isTerminal &&
      (projection!.canJoin ||
          projection!.canRejoin ||
          projection!.canEnterWaitingRoom);

  Future<void> initialize() => refresh();

  Future<void> refresh() {
    if (_disposed) return Future<void>.value();
    final active = _activeProjectionLoad;
    if (active != null) {
      return active;
    }
    final future = _loadProjection();
    _activeProjectionLoad = future;
    return future.whenComplete(() {
      if (identical(_activeProjectionLoad, future)) {
        _activeProjectionLoad = null;
      }
    });
  }

  Future<void> _loadProjection() async {
    final generation = ++_generation;
    final hasProjection = projection != null;
    isLoading = !hasProjection;
    isRefreshing = hasProjection;
    errorMessage = null;
    _notify();
    try {
      await _resolveViewer();
      final loaded = await _accountOperation(
        () => _repository.projection(appointmentId: appointmentId),
      );
      await _assertSameAccount();
      if (!_accept(generation)) {
        return;
      }
      projection = loaded;
      cameraEnabled = loaded.mode == ConsultationMode.video && cameraEnabled;
      _configurePolling();
    } catch (error) {
      if (_accept(generation)) {
        errorMessage = safeConsultationFailure(error);
      }
    } finally {
      if (_accept(generation)) {
        isLoading = false;
        isRefreshing = false;
        _notify();
      }
    }
  }

  Future<void> prepareMedia() async {
    if (_disposed || isPreparing || !canPrepare) {
      return;
    }
    isPreparing = true;
    errorMessage = null;
    _notify();
    try {
      await _assertSameAccount();
      final result = await _accountOperation(
        () => _permissionService.request(mode),
      );
      await _assertSameAccount();
      if (_disposed) {
        return;
      }
      permissions = result;
      if (!result.microphoneReady) {
        errorMessage =
            result.microphone == ConsultationPermissionState.permanentlyDenied
                ? 'Microphone access is blocked. Open app settings to enable it.'
                : 'Microphone access is required for a consultation.';
        return;
      }
      cameraEnabled = mode == ConsultationMode.video && result.cameraReady;
      await _accountOperation(
        () => _room.preparePreview(videoEnabled: cameraEnabled),
      );
      await _assertSameAccount();
    } catch (error) {
      if (!_disposed) {
        errorMessage = safeConsultationFailure(error);
      }
    } finally {
      if (!_disposed) {
        isPreparing = false;
        _notify();
      }
    }
  }

  Future<void> enterWaitingRoom() {
    return _serializedAction(() async {
      await _assertSameAccount();
      final loaded = await _accountOperation(
        () => _repository.enterWaitingRoom(appointmentId: appointmentId),
      );
      await _assertSameAccount();
      if (_disposed) {
        return;
      }
      projection = loaded;
      actionMessage = 'You are in the waiting room.';
      _configurePolling();
    });
  }

  Future<void> admitPatient() {
    return _serializedAction(() async {
      await _assertSameAccount();
      final loaded = await _accountOperation(
        () => _repository.admitPatient(appointmentId: appointmentId),
      );
      await _assertSameAccount();
      if (_disposed) {
        return;
      }
      projection = loaded;
      actionMessage = 'Patient admitted.';
      _configurePolling();
    });
  }

  Future<void> join() {
    return _serializedAction(() async {
      await _assertSameAccount();
      if (permissions?.microphoneReady != true) {
        throw const _ConsultationSafetyFailure(
          'Allow microphone access before joining.',
        );
      }
      final current = projection;
      if (current == null ||
          supportedMode == null ||
          (!current.canJoin && !current.canRejoin)) {
        throw const _ConsultationSafetyFailure(
          'The consultation is not ready to join.',
        );
      }
      final grant = await _accountOperation(
        () => _repository.joinGrant(
          appointmentId: appointmentId,
          deviceSessionId: _deviceSessionId,
          cameraEnabled: mode == ConsultationMode.video && cameraEnabled,
        ),
      );
      await _assertSameAccount();
      if (_disposed) {
        return;
      }
      if (!grant.expiresAt.isAfter(_now().toUtc())) {
        throw const _ConsultationSafetyFailure(
          'The secure join grant expired. Try joining again.',
        );
      }
      if (grant.participantRole != viewerRole) {
        throw const _ConsultationSafetyFailure(
          'The secure join grant did not match this account.',
        );
      }
      await _accountOperation(
        () => _room.connect(
          grant: grant,
          microphoneEnabled: microphoneEnabled,
          cameraEnabled: mode == ConsultationMode.video && cameraEnabled,
        ),
      );
      await _assertSameAccount();
      if (!_disposed) {
        actionMessage =
            grant.replacedPriorDevice
                ? 'This device replaced an earlier call connection.'
                : null;
        await refresh();
      }
    });
  }

  Future<void> endConsultation() {
    return _serializedAction(() async {
      await _assertSameAccount();
      final loaded = await _accountOperation(
        () => _repository.endConsultation(appointmentId: appointmentId),
      );
      await _assertSameAccount();
      await _accountOperation(_room.disconnect);
      await _assertSameAccount();
      if (_disposed) {
        return;
      }
      projection = loaded;
      actionMessage = 'Consultation ended.';
      _configurePolling();
    });
  }

  Future<void> leave() {
    return _serializedAction(() async {
      await _assertSameAccount();
      await _accountOperation(_room.disconnect);
      await _assertSameAccount();
      if (!_disposed) {
        actionMessage = 'You left the consultation.';
        await refresh();
      }
    });
  }

  Future<void> reportIncident({
    required ConsultationIncidentCategory category,
    String? description,
  }) async {
    if (isReporting) {
      return;
    }
    isReporting = true;
    incidentMessage = null;
    _notify();
    try {
      await _assertSameAccount();
      await _accountOperation(
        () => _repository.reportIncident(
          appointmentId: appointmentId,
          category: category,
          description: description,
        ),
      );
      await _assertSameAccount();
      if (!_disposed) {
        incidentMessage = 'Issue reported for review.';
      }
    } catch (error) {
      if (!_disposed) {
        incidentMessage = safeConsultationFailure(error);
      }
    } finally {
      if (!_disposed) {
        isReporting = false;
        _notify();
      }
    }
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    if (isActing) {
      return;
    }
    try {
      await _assertSameAccount();
      await _accountOperation(() => _room.setMicrophoneEnabled(enabled));
      await _assertSameAccount();
      microphoneEnabled = enabled;
    } catch (_) {
      errorMessage = 'Microphone could not be updated.';
    }
    _notify();
  }

  Future<void> setCameraEnabled(bool enabled) async {
    if (mode != ConsultationMode.video || isActing) {
      return;
    }
    try {
      await _assertSameAccount();
      await _accountOperation(() => _room.setCameraEnabled(enabled));
      await _assertSameAccount();
      cameraEnabled = enabled;
    } catch (_) {
      errorMessage = 'Camera could not be updated.';
    }
    _notify();
  }

  Future<void> switchCamera() async {
    try {
      await _assertSameAccount();
      await _accountOperation(_room.switchCamera);
      await _assertSameAccount();
    } catch (_) {
      errorMessage = 'Camera could not be switched.';
      _notify();
    }
  }

  Future<void> setSpeakerEnabled(bool enabled) async {
    try {
      await _assertSameAccount();
      await _accountOperation(() => _room.setSpeakerEnabled(enabled));
      await _assertSameAccount();
    } catch (_) {
      errorMessage = 'Audio output could not be changed.';
      _notify();
    }
  }

  Future<void> openSettings() => _permissionService.openApplicationSettings();

  Future<void> onAppResumed() async {
    if (_disposed) return;
    try {
      String? permissionError;
      await _assertSameAccount();
      final currentMode = supportedMode;
      if (currentMode != null) {
        final currentPermissions = await _accountOperation(
          () => _permissionService.check(currentMode),
        );
        await _assertSameAccount();
        if (_disposed) {
          return;
        }
        permissions = currentPermissions;
        if (!currentPermissions.microphoneReady && isConnected) {
          await _accountOperation(_room.disconnect);
          await _assertSameAccount();
          permissionError =
              'Microphone access was removed. Enable it before rejoining.';
        }
        if (currentMode == ConsultationMode.video &&
            !currentPermissions.cameraReady &&
            cameraEnabled) {
          await _accountOperation(() => _room.setCameraEnabled(false));
          await _assertSameAccount();
          cameraEnabled = false;
          actionMessage =
              'Camera access was removed. You may continue with audio after rejoining.';
        }
      }
      await refresh();
      await _assertSameAccount();
      if (!_disposed && permissionError != null) {
        errorMessage = permissionError;
        _notify();
      }
    } catch (error) {
      if (!_disposed) {
        errorMessage = safeConsultationFailure(error);
        _notify();
      }
    }
  }

  Future<void> _resolveViewer() async {
    if (_accountId != null) {
      await _assertSameAccount();
      return;
    }
    final session = await _sessionStore.read();
    if (_disposed) {
      throw const _ConsultationSafetyFailure('Reopen the consultation.');
    }
    final role = switch (session?.user.role.trim().toUpperCase()) {
      'PATIENT' => ConsultationParticipantRole.patient,
      'PROFESSIONAL' => ConsultationParticipantRole.professional,
      _ => ConsultationParticipantRole.unknown,
    };
    if (session == null || role == ConsultationParticipantRole.unknown) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'This account cannot access this consultation.',
        statusCode: 403,
      );
    }
    _accountId = session.user.id;
    viewerRole = role;
  }

  Future<void> _assertSameAccount() async {
    if (_disposed) {
      throw const _ConsultationSafetyFailure('Reopen the consultation.');
    }
    if (_accountRevocation != null) {
      await _accountRevocation;
      throw const AuthFailure(
        type: AuthFailureType.forbidden,
        message: 'Reopen the consultation with the correct account.',
        statusCode: 403,
      );
    }
    final session = await _sessionStore.read();
    if (_disposed) {
      throw const _ConsultationSafetyFailure('Reopen the consultation.');
    }
    if (_accountRevocation != null) {
      await _accountRevocation;
      throw const AuthFailure(
        type: AuthFailureType.forbidden,
        message: 'Reopen the consultation with the correct account.',
        statusCode: 403,
      );
    }
    if (session == null) {
      await _revokeAccountMedia();
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Your session has expired. Please sign in again.',
        statusCode: 401,
      );
    }
    if (_accountId != null && session.user.id != _accountId) {
      await _revokeAccountMedia();
      throw const AuthFailure(
        type: AuthFailureType.validation,
        message: 'The signed-in account changed. Reopen the consultation.',
        statusCode: 403,
      );
    }
    final currentRole = switch (session.user.role.trim().toUpperCase()) {
      'PATIENT' => ConsultationParticipantRole.patient,
      'PROFESSIONAL' => ConsultationParticipantRole.professional,
      _ => ConsultationParticipantRole.unknown,
    };
    if (currentRole != viewerRole ||
        currentRole == ConsultationParticipantRole.unknown) {
      await _revokeAccountMedia();
      throw const AuthFailure(
        type: AuthFailureType.validation,
        message: 'This account cannot access this consultation.',
        statusCode: 403,
      );
    }
  }

  Future<T> _accountOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (_) {
      // Failed completions must revoke stale authority too, while preserving
      // the original failure when the bound account is still current.
      await _assertSameAccount();
      rethrow;
    }
  }

  Future<void> _revokeAccountMedia() {
    final active = _accountRevocation;
    if (active != null) return active;
    final completion = Completer<void>();
    _accountRevocation = completion.future;
    projection = null;
    permissions = null;
    actionMessage = null;
    _pollTimer?.cancel();
    completion.complete(Future<void>.sync(_room.release));
    return completion.future;
  }

  Future<void> _serializedAction(Future<void> Function() action) {
    if (_disposed) return Future<void>.value();
    final active = _activeAction;
    if (active != null) {
      return active;
    }
    final future = _runAction(action);
    _activeAction = future;
    return future.whenComplete(() {
      if (identical(_activeAction, future)) {
        _activeAction = null;
      }
    });
  }

  Future<void> _runAction(Future<void> Function() action) async {
    isActing = true;
    errorMessage = null;
    actionMessage = null;
    _notify();
    try {
      await action();
    } catch (error) {
      if (!_disposed) {
        errorMessage = safeConsultationFailure(error);
      }
    } finally {
      if (!_disposed) {
        isActing = false;
        _notify();
      }
    }
  }

  void _configurePolling() {
    _pollTimer?.cancel();
    final current = projection;
    if (_disposed || current == null || current.isTerminal || isConnected) {
      return;
    }
    _pollTimer = Timer.periodic(_pollingInterval, (_) {
      if (_activeProjectionLoad == null && !_disposed) {
        unawaited(refresh());
      }
    });
  }

  void _onRoomChanged() {
    if (_disposed) {
      return;
    }
    if (_room.connectionState == RtcConnectionState.disconnected ||
        _room.connectionState == RtcConnectionState.failed) {
      _configurePolling();
    }
    notifyListeners();
  }

  bool _accept(int generation) => !_disposed && generation == _generation;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> _releaseOnDispose() async {
    try {
      final revocation = _accountRevocation;
      if (revocation != null) {
        try {
          await revocation;
          return;
        } catch (_) {
          // Retry cleanup only after the in-flight revocation has settled.
        }
      }
      await _room.release();
    } catch (_) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: StateError(
            'Consultation media cleanup failed; resource release is unverified.',
          ),
          library: 'consultation',
          context: ErrorDescription(
            'while disposing a consultation controller',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _pollTimer?.cancel();
    _room.removeListener(_onRoomChanged);
    unawaited(_releaseOnDispose());
    super.dispose();
  }
}

String safeConsultationFailure(Object error) {
  if (error is _ConsultationSafetyFailure) {
    return error.message;
  }
  if (error is AuthFailure) {
    if (error.statusCode == 401) {
      return 'Your session has expired. Please sign in again.';
    }
    if (error.statusCode == 403) {
      return 'This account cannot access this consultation.';
    }
    if (error.statusCode == 404) {
      return 'This consultation is no longer available.';
    }
    if (error.statusCode == 409) {
      return 'The consultation changed. Refresh and try again.';
    }
    if (error.type == AuthFailureType.network) {
      return 'Network error. Check your connection and try again.';
    }
    if (error.type == AuthFailureType.server) {
      return 'Consultation service is temporarily unavailable.';
    }
    return 'Something went wrong. Please try again.';
  }
  if (error is FormatException) {
    return 'The consultation response was invalid. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}

class _ConsultationSafetyFailure implements Exception {
  const _ConsultationSafetyFailure(this.message);

  final String message;
}
