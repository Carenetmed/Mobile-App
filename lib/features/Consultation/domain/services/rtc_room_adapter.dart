import 'package:app_t/features/Consultation/domain/entities/consultation_entities.dart';
import 'package:flutter/foundation.dart';

enum RtcConnectionState {
  idle,
  previewing,
  connecting,
  connected,
  reconnecting,
  disconnected,
  failed,
}

abstract class RtcVideoTrackHandle {
  const RtcVideoTrackHandle();
}

abstract class RtcRoomAdapter extends ChangeNotifier {
  RtcConnectionState get connectionState;
  bool get microphoneEnabled;
  bool get cameraEnabled;
  bool get speakerEnabled;
  bool get remoteParticipantPresent;
  bool get remoteMicrophoneEnabled;
  bool get remoteCameraEnabled;
  RtcVideoTrackHandle? get localVideo;
  RtcVideoTrackHandle? get remoteVideo;
  String? get safeFailureMessage;

  Future<void> preparePreview({required bool videoEnabled});

  Future<void> connect({
    required ConsultationJoinGrant grant,
    required bool microphoneEnabled,
    required bool cameraEnabled,
  });

  Future<void> setMicrophoneEnabled(bool enabled);

  Future<void> setCameraEnabled(bool enabled);

  Future<void> switchCamera();

  Future<void> setSpeakerEnabled(bool enabled);

  Future<void> disconnect();

  Future<void> release();
}
