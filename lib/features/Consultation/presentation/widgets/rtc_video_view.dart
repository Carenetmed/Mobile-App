import 'package:app_t/features/Consultation/data/services/livekit_rtc_room_adapter.dart';
import 'package:app_t/features/Consultation/domain/services/rtc_room_adapter.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class RtcVideoView extends StatelessWidget {
  const RtcVideoView({
    required this.track,
    this.mirror = false,
    this.placeholder,
    super.key,
  });

  final RtcVideoTrackHandle? track;
  final bool mirror;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final current = track;
    if (current is! LiveKitVideoTrackHandle) {
      return placeholder ??
          const Center(
            child: Icon(Icons.videocam_off_outlined, color: Colors.white70),
          );
    }
    return VideoTrackRenderer(
      current.track,
      fit: VideoViewFit.cover,
      mirrorMode: mirror ? VideoViewMirrorMode.mirror : VideoViewMirrorMode.off,
    );
  }
}
