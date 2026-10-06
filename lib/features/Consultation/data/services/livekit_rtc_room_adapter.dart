import 'dart:async';

import 'package:app_t/features/Consultation/domain/entities/consultation_entities.dart';
import 'package:app_t/features/Consultation/domain/services/rtc_room_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';

class LiveKitVideoTrackHandle extends RtcVideoTrackHandle {
  const LiveKitVideoTrackHandle(this.track);

  final VideoTrack track;
}

class LiveKitRtcRoomAdapter extends RtcRoomAdapter {
  LiveKitRtcRoomAdapter({
    Room Function(RoomOptions options)? roomFactory,
    Future<LocalVideoTrack> Function(CameraCaptureOptions options)?
    cameraTrackFactory,
    Future<LocalAudioTrack> Function(AudioCaptureOptions options)?
    microphoneTrackFactory,
    Future<void> Function(bool enabled)? setSpeakerOutputPreferred,
  }) : _roomFactory = roomFactory ?? ((options) => Room(roomOptions: options)),
       _cameraTrackFactory =
           cameraTrackFactory ?? LocalVideoTrack.createCameraTrack,
       _microphoneTrackFactory =
           microphoneTrackFactory ?? LocalAudioTrack.create,
       _setSpeakerOutputPreferred =
           setSpeakerOutputPreferred ??
           ((enabled) =>
               AudioManager.instance.setSpeakerOutputPreferred(enabled));

  final Room Function(RoomOptions options) _roomFactory;
  final Future<LocalVideoTrack> Function(CameraCaptureOptions options)
  _cameraTrackFactory;
  final Future<LocalAudioTrack> Function(AudioCaptureOptions options)
  _microphoneTrackFactory;
  final Future<void> Function(bool enabled) _setSpeakerOutputPreferred;
  _RoomSession? _session;
  Room? get _room => _session?.room;
  final Set<Future<void>> _resourceCleanups = {};
  final Set<Future<void>> _pendingOperations = {};
  final Set<Future<void>> _previewControls = {};
  Object? _lateCleanupError;
  StackTrace? _lateCleanupStack;
  Future<void>? _releaseFuture;
  int _generation = 0;
  bool _connecting = false;
  bool _disconnecting = false;
  Future<void>? _activeDisconnect;
  Future<void>? _roomCleanup;
  LocalVideoTrack? _previewTrack;
  CameraPosition _cameraPosition = CameraPosition.front;
  bool _released = false;

  @override
  RtcConnectionState connectionState = RtcConnectionState.idle;

  @override
  bool microphoneEnabled = true;

  @override
  bool cameraEnabled = true;

  @override
  bool speakerEnabled = true;

  @override
  bool remoteParticipantPresent = false;

  @override
  bool remoteMicrophoneEnabled = false;

  @override
  bool remoteCameraEnabled = false;

  @override
  RtcVideoTrackHandle? localVideo;

  @override
  RtcVideoTrackHandle? remoteVideo;

  @override
  String? safeFailureMessage;

  @override
  Future<void> preparePreview({required bool videoEnabled}) {
    if (_released || _connecting || _disconnecting || _session != null) {
      return Future<void>.value();
    }
    return _runOperation(null, () => _preparePreview(videoEnabled));
  }

  Future<void> _preparePreview(bool videoEnabled) async {
    final generation = ++_generation;
    await _disposePreview();
    if (!_isCurrent(generation)) return;
    cameraEnabled = videoEnabled;
    safeFailureMessage = null;
    if (!videoEnabled) {
      connectionState = RtcConnectionState.previewing;
      _notify();
      return;
    }
    try {
      final preview = await _cameraTrackFactory(
        CameraCaptureOptions(
          cameraPosition: _cameraPosition,
          maxFrameRate: 24,
          params: const VideoParameters(dimensions: VideoDimensions(640, 360)),
        ),
      );
      if (!_isCurrent(generation)) {
        try {
          await preview.dispose();
        } catch (error, stack) {
          _lateCleanupError = error;
          _lateCleanupStack = stack;
          rethrow;
        }
        return;
      }
      _previewTrack = preview;
      localVideo = LiveKitVideoTrackHandle(preview);
      connectionState = RtcConnectionState.previewing;
    } catch (_) {
      if (!_isCurrent(generation)) return;
      cameraEnabled = false;
      safeFailureMessage = 'Camera preview is unavailable.';
      connectionState = RtcConnectionState.previewing;
    }
    _notify();
  }

  @override
  Future<void> connect({
    required ConsultationJoinGrant grant,
    required bool microphoneEnabled,
    required bool cameraEnabled,
  }) async {
    if (_released || _connecting) return;
    final disconnecting = _activeDisconnect;
    if (disconnecting != null) await disconnecting;
    if (_released || _connecting) return;
    _connecting = true;
    final generation = ++_generation;
    _RoomSession? session;
    try {
      await _disposeRoom();
      if (!_isCurrent(generation)) return;
      await _disposePreview();
      if (!_isCurrent(generation)) return;
      this.microphoneEnabled = grant.microphoneAllowed && microphoneEnabled;
      this.cameraEnabled = grant.cameraAllowed && cameraEnabled;
      safeFailureMessage = null;
      connectionState = RtcConnectionState.connecting;
      _notify();
      if (!_isCurrent(generation)) return;

      final room = _roomFactory(
        const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultCameraCaptureOptions: CameraCaptureOptions(
            maxFrameRate: 24,
            params: VideoParameters(dimensions: VideoDimensions(640, 360)),
          ),
          defaultVideoPublishOptions: VideoPublishOptions(simulcast: true),
          defaultAudioOutputOptions: AudioOutputOptions(speakerOn: true),
        ),
      );
      final owned = _RoomSession(
        room,
        generation,
        microphoneAllowed: grant.microphoneAllowed,
        cameraAllowed: grant.cameraAllowed,
      );
      session = owned;
      _session = owned;
      owned.onChanged = () {
        if (_owns(owned)) _syncFromRoom();
      };
      room.addListener(owned.onChanged);
      owned.listener = room.createListener();
      owned.listener!
        ..on<RoomReconnectingEvent>((_) {
          if (!_owns(owned)) return;
          connectionState = RtcConnectionState.reconnecting;
          _notify();
        })
        ..on<RoomReconnectedEvent>((_) {
          if (!_owns(owned)) return;
          connectionState = RtcConnectionState.connected;
          _syncFromRoom();
        })
        ..on<RoomDisconnectedEvent>((_) {
          if (!_owns(owned)) return;
          connectionState = RtcConnectionState.disconnected;
          _syncFromRoom();
        })
        ..on<ParticipantEvent>((_) => owned.onChanged())
        ..on<TrackSubscribedEvent>((_) => owned.onChanged())
        ..on<TrackUnsubscribedEvent>((_) => owned.onChanged());
      await _runOperation(
        owned,
        () => room.connect(grant.serverUrl.toString(), grant.token),
      );
      if (!_owns(owned)) return;
      final participant = room.localParticipant;
      if (participant != null) {
        owned.participants.add(participant);
        await _runOperation(
          owned,
          () => _setMicrophone(
            owned,
            participant,
            microphoneEnabled && grant.microphoneAllowed,
          ),
        );
      }
      if (!_owns(owned)) return;
      if (participant != null) {
        await _runOperation(
          owned,
          () => _setCamera(owned, participant, this.cameraEnabled),
        );
      }
      if (!_owns(owned)) return;
      await _runOperation(owned, () => _setSpeakerOutputPreferred(true));
      if (!_owns(owned)) return;
      speakerEnabled = true;
      connectionState = RtcConnectionState.connected;
      _syncFromRoom();
    } catch (_) {
      if (!_isCurrent(generation)) return;
      safeFailureMessage = 'Could not connect to the consultation.';
      connectionState = RtcConnectionState.failed;
      if (session != null && identical(_session, session)) {
        await _disposeRoom();
      }
      if (_isCurrent(generation)) _notify();
      rethrow;
    } finally {
      _connecting = false;
    }
  }

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {
    if (_released || _disconnecting) return;
    final generation = _generation;
    final session = _session;
    if (session != null && enabled && !session.microphoneAllowed) {
      throw StateError('Microphone is not allowed by the consultation grant.');
    }
    final participant = _room?.localParticipant;
    if (participant == null) {
      microphoneEnabled = enabled;
      _notify();
      return;
    }
    session!.participants.add(participant);
    await _runOperation(
      session,
      () => _setMicrophone(session, participant, enabled),
    );
    if (!_isCurrent(generation)) return;
    microphoneEnabled = enabled;
    _syncFromRoom();
  }

  @override
  Future<void> setCameraEnabled(bool enabled) async {
    if (_released || _disconnecting) return;
    final generation = _generation;
    final session = _session;
    if (session != null && enabled && !session.cameraAllowed) {
      throw StateError('Camera is not allowed by the consultation grant.');
    }
    final participant = _room?.localParticipant;
    if (participant == null) {
      cameraEnabled = enabled;
      await preparePreview(videoEnabled: enabled);
      return;
    }
    session!.participants.add(participant);
    await _runOperation(
      session,
      () => _setCamera(session, participant, enabled),
    );
    if (!_isCurrent(generation)) return;
    cameraEnabled = enabled;
    _syncFromRoom();
  }

  @override
  Future<void> switchCamera() async {
    if (_released || _disconnecting) return;
    final generation = _generation;
    _cameraPosition = _cameraPosition.switched();
    final currentTrack = _localCameraTrack;
    if (currentTrack != null) {
      await _runOperation(
        _session,
        () => currentTrack.setCameraPosition(_cameraPosition),
      );
    } else if (_previewTrack != null) {
      final preview = _previewTrack!;
      await _runOperation(
        null,
        () => preview.setCameraPosition(_cameraPosition),
        previewControl: true,
      );
    }
    if (_isCurrent(generation)) _syncFromRoom();
  }

  @override
  Future<void> setSpeakerEnabled(bool enabled) async {
    if (_released || _disconnecting) return;
    final generation = _generation;
    await _runOperation(_session, () => _setSpeakerOutputPreferred(enabled));
    if (!_isCurrent(generation)) return;
    speakerEnabled = enabled;
    _notify();
  }

  @override
  Future<void> disconnect() {
    if (_released) return Future<void>.value();
    final active = _activeDisconnect;
    if (active != null) return active;
    _disconnecting = true;
    final generation = ++_generation;
    late final Future<void> operation;
    operation = _performDisconnect(generation).whenComplete(() {
      if (identical(_activeDisconnect, operation)) {
        _activeDisconnect = null;
        _disconnecting = false;
      }
    });
    _activeDisconnect = operation;
    return operation;
  }

  Future<void> _performDisconnect(int generation) async {
    await Future.wait([_disposeRoom(), _disposePreview()]);
    if (!_isCurrent(generation)) return;
    connectionState = RtcConnectionState.disconnected;
    _notify();
  }

  @override
  Future<void> release() {
    if (_releaseFuture != null) return _releaseFuture!;
    _released = true;
    ++_generation;
    final previewCleanup = _disposePreview();
    final roomCleanup = _disposeRoom();
    localVideo = null;
    remoteVideo = null;
    return _releaseFuture = _finishRelease([
      previewCleanup,
      roomCleanup,
      ..._resourceCleanups,
      ..._pendingOperations,
    ]);
  }

  Future<void> _finishRelease(List<Future<void>> pending) async {
    await Future.wait<void>(pending);
    if (_lateCleanupError != null) {
      Error.throwWithStackTrace(_lateCleanupError!, _lateCleanupStack!);
    }
  }

  Future<T> _runOperation<T>(
    _RoomSession? session,
    Future<T> Function() operation, {
    bool previewControl = false,
  }) async {
    final settled = Completer<void>();
    _pendingOperations.add(settled.future);
    session?.pending.add(settled.future);
    if (previewControl) _previewControls.add(settled.future);
    try {
      return await operation();
    } finally {
      session?.pending.remove(settled.future);
      _previewControls.remove(settled.future);
      _pendingOperations.remove(settled.future);
      settled.complete();
    }
  }

  bool _isCurrent(int generation) => !_released && generation == _generation;

  bool _owns(_RoomSession session) =>
      _isCurrent(session.generation) && identical(_session, session);

  Future<void> _setMicrophone(
    _RoomSession session,
    LocalParticipant participant,
    bool enabled,
  ) => _setMedia<LocalAudioTrack>(
    session,
    participant,
    TrackSource.microphone,
    enabled,
    () => _microphoneTrackFactory(const AudioCaptureOptions()),
    (track) => participant.publishAudioTrack(track),
  );

  Future<void> _setCamera(
    _RoomSession session,
    LocalParticipant participant,
    bool enabled,
  ) => _setMedia<LocalVideoTrack>(
    session,
    participant,
    TrackSource.camera,
    enabled,
    () => _cameraTrackFactory(
      CameraCaptureOptions(
        cameraPosition: _cameraPosition,
        maxFrameRate: 24,
        params: const VideoParameters(dimensions: VideoDimensions(640, 360)),
      ),
    ),
    (track) => participant.publishVideoTrack(track),
  );

  Future<void> _setMedia<T extends LocalTrack>(
    _RoomSession session,
    LocalParticipant participant,
    TrackSource source,
    bool enabled,
    Future<T> Function() create,
    Future<LocalTrackPublication<T>> Function(T) publish,
  ) {
    final previous = session.mediaQueues[source] ?? Future<void>.value();
    Future<void> run() async {
      await previous;
      if (!_owns(session)) return;
      final existing = session.media[source];
      if (enabled &&
          existing != null &&
          [
            ...participant.audioTrackPublications,
            ...participant.videoTrackPublications,
          ].any(
            (publication) =>
                identical(publication.track, existing.track) &&
                !publication.muted,
          )) {
        return;
      }
      if (existing != null) {
        await _removeCapture(session, participant, source, existing);
      }
      if (!enabled || !_owns(session)) return;
      final track = await create();
      final capture = _CapturedTrack(track);
      session.captures.add(capture);
      if (!_owns(session)) {
        await _disposeCapture(session, capture);
        return;
      }
      session.media[source] = capture;
      try {
        await publish(track);
      } catch (_) {
        await _removeCapture(session, participant, source, capture);
        rethrow;
      }
      if (!_owns(session)) {
        await _removeCapture(session, participant, source, capture);
      }
    }

    final operation = run();
    // Serialize each source without poisoning later commands after an error.
    session.mediaQueues[source] = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return operation;
  }

  Future<void> _removeCapture(
    _RoomSession session,
    LocalParticipant participant,
    TrackSource source,
    _CapturedTrack capture,
  ) async {
    if (identical(session.media[source], capture)) session.media.remove(source);
    try {
      await _trackCleanup(() async {
        final publications = [
          ...participant.audioTrackPublications,
          ...participant.videoTrackPublications,
        ];
        for (final publication in publications) {
          if (identical(publication.track, capture.track)) {
            await participant.removePublishedTrack(publication.sid);
          }
        }
      });
    } finally {
      await _disposeCapture(session, capture);
    }
  }

  Future<void> _disposeCapture(_RoomSession session, _CapturedTrack capture) {
    return capture.cleanup ??= _trackCleanup(() async {
      try {
        // SDK publication cleanup can have disposed a track before a late
        // publish resumes. Stop again before its idempotent dispose.
        try {
          await capture.track.stop();
        } finally {
          await capture.track.dispose();
        }
      } finally {
        session.captures.remove(capture);
      }
    });
  }

  LocalVideoTrack? get _localCameraTrack {
    final publications = _room?.localParticipant?.videoTrackPublications;
    if (publications == null) {
      return null;
    }
    for (final publication in publications) {
      final track = publication.track;
      if (publication.source == TrackSource.camera &&
          track is LocalVideoTrack) {
        return track;
      }
    }
    return null;
  }

  void _syncFromRoom() {
    if (_released) {
      return;
    }
    final room = _room;
    final localTrack = _localCameraTrack;
    localVideo =
        localTrack == null ? null : LiveKitVideoTrackHandle(localTrack);
    RemoteVideoTrack? remoteTrack;
    RemoteParticipant? remoteParticipant;
    if (room != null && room.remoteParticipants.isNotEmpty) {
      remoteParticipant = room.remoteParticipants.values.first;
      for (final publication in remoteParticipant.videoTrackPublications) {
        final track = publication.track;
        if (publication.source == TrackSource.camera &&
            track is RemoteVideoTrack &&
            !publication.muted) {
          remoteTrack = track;
          break;
        }
      }
    }
    remoteParticipantPresent = remoteParticipant != null;
    remoteCameraEnabled = remoteTrack != null;
    remoteVideo =
        remoteTrack == null ? null : LiveKitVideoTrackHandle(remoteTrack);
    remoteMicrophoneEnabled =
        remoteParticipant?.audioTrackPublications.any(
          (publication) => publication.subscribed && !publication.muted,
        ) ??
        false;
    microphoneEnabled =
        _room?.localParticipant?.audioTrackPublications.any(
          (publication) => !publication.muted,
        ) ??
        microphoneEnabled;
    cameraEnabled = localTrack != null && !localTrack.muted;
    _notify();
  }

  Future<void> _disposePreview() {
    final preview = _previewTrack;
    _previewTrack = null;
    if (_room == null) localVideo = null;
    if (preview == null) return Future<void>.value();
    final controls = _previewControls.toList();
    return _trackCleanup(() async {
      await Future.wait<void>(controls);
      await preview.dispose();
    });
  }

  Future<void> _disposeRoom() {
    final session = _session;
    if (session == null) return _roomCleanup ?? Future<void>.value();
    _session = null;
    localVideo = null;
    remoteVideo = null;
    remoteParticipantPresent = false;
    remoteMicrophoneEnabled = false;
    remoteCameraEnabled = false;
    session.room.removeListener(session.onChanged);
    late final Future<void> cleanup;
    cleanup = _trackCleanup(() => _cleanupRoom(session)).whenComplete(() {
      if (identical(_roomCleanup, cleanup)) _roomCleanup = null;
    });
    _roomCleanup = cleanup;
    return cleanup;
  }

  Future<void> _cleanupRoom(_RoomSession session) async {
    Object? failure;
    StackTrace? failureStack;
    Future<void> attempt(Future<void> Function() action) async {
      try {
        await action();
      } catch (error, stack) {
        failure ??= error;
        failureStack ??= stack;
      }
    }

    final hadPending = session.pending.isNotEmpty;
    final participant = session.room.localParticipant;
    if (participant != null) session.participants.add(participant);
    // Capture is explicitly owned before publication, so disconnect can safely
    // interrupt pending publishes while final disposal waits for their drain.
    final tracks = <LocalTrack>{
      for (final capture in session.captures) capture.track,
    };
    for (final participant in session.participants) {
      for (final publication in [
        ...participant.audioTrackPublications,
        ...participant.videoTrackPublications,
      ]) {
        final track = publication.track;
        if (track != null) tracks.add(track);
      }
    }
    final stops = [
      for (final track in tracks)
        attempt(() async {
          await track.stop();
        }),
    ];
    final listenerCleanup = attempt(() async {
      await session.listener?.dispose();
    });
    final earlyDisconnect = attempt(session.room.disconnect);
    await Future.wait<void>([listenerCleanup, earlyDisconnect, ...stops]);
    // Drain accepted media operations, never connect's adapter-level catch.
    await Future.wait<void>(session.pending.toList());
    final lateParticipant = session.room.localParticipant;
    if (lateParticipant != null) session.participants.add(lateParticipant);
    for (final participant in session.participants) {
      await attempt(() => participant.unpublishAllTracks());
    }
    for (final capture in session.captures.toList()) {
      await attempt(() => _disposeCapture(session, capture));
    }
    session.media.clear();
    if (hadPending) await attempt(session.room.disconnect);
    await attempt(() async {
      await session.room.dispose();
    });
    if (failure != null) {
      Error.throwWithStackTrace(failure!, failureStack!);
    }
  }

  Future<void> _trackCleanup(Future<void> Function() disposeResource) {
    late final Future<void> cleanup;
    Future<void> run() async {
      try {
        await disposeResource();
      } catch (error, stack) {
        _lateCleanupError ??= error;
        _lateCleanupStack ??= stack;
        rethrow;
      } finally {
        _resourceCleanups.remove(cleanup);
      }
    }

    cleanup = run();
    _resourceCleanups.add(cleanup);
    return cleanup;
  }

  void _notify() {
    if (!_released) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_releaseAfterDispose());
    super.dispose();
  }

  Future<void> _releaseAfterDispose() async {
    try {
      await release();
    } catch (_) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError(
            'RTC media cleanup failed; completion could not be verified.',
          ),
          library: 'CareNet RTC adapter',
          context: ErrorDescription(
            'while releasing disposed consultation media',
          ),
        ),
      );
    }
  }
}

class _RoomSession {
  _RoomSession(
    this.room,
    this.generation, {
    required this.microphoneAllowed,
    required this.cameraAllowed,
  });

  final Room room;
  final int generation;
  final bool microphoneAllowed;
  final bool cameraAllowed;
  late void Function() onChanged;
  EventsListener<RoomEvent>? listener;
  final Set<Future<void>> pending = {};
  final Set<LocalParticipant> participants = {};
  final Set<_CapturedTrack> captures = {};
  final Map<TrackSource, _CapturedTrack> media = {};
  final Map<TrackSource, Future<void>> mediaQueues = {};
}

class _CapturedTrack {
  _CapturedTrack(this.track);
  final LocalTrack track;
  Future<void>? cleanup;
}
