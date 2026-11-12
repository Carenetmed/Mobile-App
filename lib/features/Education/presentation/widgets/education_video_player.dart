import 'dart:async';

import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Education/domain/entities/public_education_content.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

abstract class EducationVideoPlayback extends ChangeNotifier {
  Future<void> initialize();
  Future<void> togglePlayback();
  Future<void> pause();
  Widget buildSurface();
  Widget buildProgress();
  bool get initialized;
  bool get playing;
  bool get failed;
  double get aspectRatio;
}

typedef EducationVideoPlaybackFactory =
    EducationVideoPlayback Function(PublicEducationVideo video);

class NativeEducationVideoPlayback extends EducationVideoPlayback {
  NativeEducationVideoPlayback(PublicEducationVideo video)
    : _controller = VideoPlayerController.networkUrl(video.url) {
    _controller.addListener(_onControllerChanged);
  }

  final VideoPlayerController _controller;
  bool _initialized = false;
  bool _failed = false;
  bool _disposed = false;

  @override
  bool get initialized => _initialized && _controller.value.isInitialized;

  @override
  bool get playing => initialized && _controller.value.isPlaying;

  @override
  bool get failed => _failed || (_initialized && _controller.value.hasError);

  @override
  double get aspectRatio {
    final value = _controller.value.aspectRatio;
    return value.isFinite && value > 0 ? value : 9 / 16;
  }

  void _onControllerChanged() {
    if (_disposed) return;
    if (_controller.value.hasError) _failed = true;
    notifyListeners();
  }

  @override
  Future<void> initialize() async {
    try {
      await _controller.initialize();
      if (_disposed) return;
      _initialized = true;
    } catch (_) {
      _failed = true;
    }
    if (!_disposed) notifyListeners();
  }

  @override
  Future<void> togglePlayback() async {
    if (!initialized || failed) return;
    try {
      if (_controller.value.isPlaying) {
        await _controller.pause();
      } else {
        await _controller.play();
      }
    } catch (_) {
      _failed = true;
    }
    if (!_disposed) notifyListeners();
  }

  @override
  Future<void> pause() async {
    if (!initialized || !_controller.value.isPlaying) return;
    try {
      await _controller.pause();
    } catch (_) {
      _failed = true;
    }
    if (!_disposed) notifyListeners();
  }

  @override
  Widget buildSurface() => VideoPlayer(_controller);

  @override
  Widget buildProgress() => VideoProgressIndicator(
    _controller,
    allowScrubbing: true,
    colors: const VideoProgressColors(
      playedColor: CarenetColors.primary300,
      bufferedColor: CarenetColors.neutral300,
      backgroundColor: CarenetColors.neutral500,
    ),
  );

  @override
  void dispose() {
    _disposed = true;
    _controller.removeListener(_onControllerChanged);
    unawaited(_controller.dispose());
    super.dispose();
  }
}

class EducationVideoPlayer extends StatefulWidget {
  const EducationVideoPlayer({
    super.key,
    required this.video,
    required this.onRefresh,
    this.playbackFactory = NativeEducationVideoPlayback.new,
    this.now,
  });

  final PublicEducationVideo video;
  final Future<void> Function() onRefresh;
  final EducationVideoPlaybackFactory playbackFactory;
  final DateTime Function()? now;

  @override
  State<EducationVideoPlayer> createState() => _EducationVideoPlayerState();
}

class _EducationVideoPlayerState extends State<EducationVideoPlayer>
    with WidgetsBindingObserver {
  late EducationVideoPlayback _playback;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _createPlayback();
  }

  void _createPlayback() {
    _playback = widget.playbackFactory(widget.video);
    _playback.addListener(_onChanged);
    if (!widget.video.isExpiredAt((widget.now ?? DateTime.now)().toUtc())) {
      unawaited(_playback.initialize());
    }
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant EducationVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.url != widget.video.url) {
      _playback.removeListener(_onChanged);
      _playback.dispose();
      _createPlayback();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      unawaited(_playback.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _playback.removeListener(_onChanged);
    _playback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expired = widget.video.isExpiredAt(
      (widget.now ?? DateTime.now)().toUtc(),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(
        color: CarenetColors.neutral700,
        child: AspectRatio(
          aspectRatio: _playback.initialized ? _playback.aspectRatio : 9 / 16,
          child:
              expired || _playback.failed
                  ? _VideoUnavailable(onRefresh: widget.onRefresh)
                  : !_playback.initialized
                  ? const Center(
                    child: CircularProgressIndicator(
                      color: CarenetColors.white,
                    ),
                  )
                  : Stack(
                    alignment: Alignment.center,
                    children: [
                      _playback.buildSurface(),
                      IconButton.filledTonal(
                        tooltip:
                            _playback.playing ? 'Pause video' : 'Play video',
                        onPressed: _playback.togglePlayback,
                        icon: Icon(
                          _playback.playing ? Icons.pause : Icons.play_arrow,
                          size: 34,
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 8,
                        child: _playback.buildProgress(),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class _VideoUnavailable extends StatelessWidget {
  const _VideoUnavailable({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined, color: CarenetColors.white),
            const SizedBox(height: 10),
            const Text(
              'This video link has expired or could not be loaded.',
              textAlign: TextAlign.center,
              style: TextStyle(color: CarenetColors.white),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Load video again'),
              style: TextButton.styleFrom(foregroundColor: CarenetColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
