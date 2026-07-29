import 'dart:async';

import 'package:app_t/features/Consultation/domain/entities/consultation_entities.dart';
import 'package:app_t/features/Consultation/domain/services/rtc_room_adapter.dart';
import 'package:livekit_client/livekit_client.dart';

class LiveKitVideoTrackHandle extends RtcVideoTrackHandle {
  const LiveKitVideoTrackHandle(this.track);

  final VideoTrack track;
}

class LiveKitRtcRoomAdapter extends RtcRoomAdapter {
  Room? _room;
  EventsListener<RoomEvent>? _listener;
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
  Future<void> preparePreview({required bool videoEnabled}) async {
    if (_released) {
      return;
    }
    await _disposePreview();
    cameraEnabled = videoEnabled;
    safeFailureMessage = null;
    if (!videoEnabled) {
      connectionState = RtcConnectionState.previewing;
      _notify();
      return;
    }
    try {
      _previewTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          cameraPosition: _cameraPosition,
          maxFrameRate: 24,
          params: const VideoParameters(dimensions: VideoDimensions(640, 360)),
        ),
      );
      localVideo = LiveKitVideoTrackHandle(_previewTrack!);
      connectionState = RtcConnectionState.previewing;
    } catch (_) {
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
    if (_released || connectionState == RtcConnectionState.connecting) {
      return;
    }
    await _disposeRoom();
    await _disposePreview();
    this.microphoneEnabled = microphoneEnabled;
    this.cameraEnabled = grant.cameraAllowed && cameraEnabled;
    safeFailureMessage = null;
    connectionState = RtcConnectionState.connecting;
    _notify();

    final room = Room(
      roomOptions: const RoomOptions(
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
    _room = room;
    room.addListener(_syncFromRoom);
    _listener =
        room.createListener()
          ..on<RoomReconnectingEvent>((_) {
            connectionState = RtcConnectionState.reconnecting;
            _notify();
          })
          ..on<RoomReconnectedEvent>((_) {
            connectionState = RtcConnectionState.connected;
            _syncFromRoom();
          })
          ..on<RoomDisconnectedEvent>((_) {
            connectionState = RtcConnectionState.disconnected;
            _syncFromRoom();
          })
          ..on<ParticipantEvent>((_) => _syncFromRoom())
          ..on<TrackSubscribedEvent>((_) => _syncFromRoom())
          ..on<TrackUnsubscribedEvent>((_) => _syncFromRoom());
    try {
      await room.connect(grant.serverUrl.toString(), grant.token);
      await room.localParticipant?.setMicrophoneEnabled(
        microphoneEnabled && grant.microphoneAllowed,
      );
      await room.localParticipant?.setCameraEnabled(
        this.cameraEnabled,
        cameraCaptureOptions: CameraCaptureOptions(
          cameraPosition: _cameraPosition,
          maxFrameRate: 24,
          params: const VideoParameters(dimensions: VideoDimensions(640, 360)),
        ),
      );
      await AudioManager.instance.setSpeakerOutputPreferred(true);
      speakerEnabled = true;
      connectionState = RtcConnectionState.connected;
      _syncFromRoom();
    } catch (_) {
      safeFailureMessage = 'Could not connect to the consultation.';
      connectionState = RtcConnectionState.failed;
      await _disposeRoom();
      _notify();
      rethrow;
    }
  }

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {
    final participant = _room?.localParticipant;
    if (participant == null) {
      microphoneEnabled = enabled;
      _notify();
      return;
    }
    await participant.setMicrophoneEnabled(enabled);
    microphoneEnabled = enabled;
    _syncFromRoom();
  }

  @override
  Future<void> setCameraEnabled(bool enabled) async {
    final participant = _room?.localParticipant;
    if (participant == null) {
      cameraEnabled = enabled;
      await preparePreview(videoEnabled: enabled);
      return;
    }
    await participant.setCameraEnabled(
      enabled,
      cameraCaptureOptions: CameraCaptureOptions(
        cameraPosition: _cameraPosition,
        maxFrameRate: 24,
        params: const VideoParameters(dimensions: VideoDimensions(640, 360)),
      ),
    );
    cameraEnabled = enabled;
    _syncFromRoom();
  }

  @override
  Future<void> switchCamera() async {
    _cameraPosition = _cameraPosition.switched();
    final currentTrack = _localCameraTrack;
    if (currentTrack != null) {
      await currentTrack.setCameraPosition(_cameraPosition);
    } else if (_previewTrack != null) {
      await _previewTrack!.setCameraPosition(_cameraPosition);
    }
    _syncFromRoom();
  }

  @override
  Future<void> setSpeakerEnabled(bool enabled) async {
    await AudioManager.instance.setSpeakerOutputPreferred(enabled);
    speakerEnabled = enabled;
    _notify();
  }

  @override
  Future<void> disconnect() async {
    await _disposeRoom();
    connectionState = RtcConnectionState.disconnected;
    _notify();
  }

  @override
  Future<void> release() async {
    if (_released) {
      return;
    }
    _released = true;
    await _disposePreview();
    await _disposeRoom();
    localVideo = null;
    remoteVideo = null;
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

  Future<void> _disposePreview() async {
    final preview = _previewTrack;
    _previewTrack = null;
    if (preview != null) {
      await preview.dispose();
    }
    if (_room == null) {
      localVideo = null;
    }
  }

  Future<void> _disposeRoom() async {
    final room = _room;
    _room = null;
    if (room != null) {
      room.removeListener(_syncFromRoom);
      await room.disconnect();
      await _listener?.dispose();
      await room.dispose();
    }
    _listener = null;
    localVideo = null;
    remoteVideo = null;
    remoteParticipantPresent = false;
    remoteMicrophoneEnabled = false;
    remoteCameraEnabled = false;
  }

  void _notify() {
    if (!_released) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(release());
    super.dispose();
  }
}
