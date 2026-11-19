import 'dart:math' as math;

import 'options.dart';
import 'results.dart';

/// [width] x [height] scaled down to fit inside
/// [maxWidth] x [maxHeight], keeping its aspect ratio, never scaled up.
({int width, int height}) fitInside(
  int width,
  int height, {
  int? maxWidth,
  int? maxHeight,
}) {
  var scale = 1.0;
  if (maxWidth != null && width > maxWidth) scale = maxWidth / width;
  if (maxHeight != null && height * scale > maxHeight) {
    scale = maxHeight / height;
  }
  if (scale >= 1) return (width: width, height: height);
  return (
    width: math.max(1, (width * scale).round()),
    height: math.max(1, (height * scale).round()),
  );
}

/// Whether [mimeType] is already [format].
bool isFormat(String? mimeType, ImageFormat format) => switch (format) {
  ImageFormat.jpeg => mimeType == 'image/jpeg',
  ImageFormat.png => mimeType == 'image/png',
  ImageFormat.webp => mimeType == 'image/webp',
  ImageFormat.heic =>
    mimeType == 'image/heic' ||
        mimeType == 'image/heif' ||
        mimeType == 'image/heic-sequence' ||
        mimeType == 'image/heif-sequence',
};

/// The exact settings a video is encoded with, worked out from the source's
/// [MediaInfo] and the caller's [VideoOptions] by [planVideo].
class VideoPlan {
  /// Creates a plan.
  const VideoPlan({
    required this.width,
    required this.height,
    required this.videoBitrate,
    required this.audioBitrate,
    required this.includeAudio,
    required this.duration,
    this.frameRate,
    this.start,
    this.end,
  });

  /// The output width as displayed.
  final int width;

  /// The output height as displayed.
  final int height;

  /// The video bitrate in bits per second.
  final int videoBitrate;

  /// The audio bitrate in bits per second.
  final int audioBitrate;

  /// Whether the output has audio.
  final bool includeAudio;

  /// The output frame rate, or null to keep the source's.
  final double? frameRate;

  /// Where to start in the source, or null for the beginning.
  final Duration? start;

  /// Where to end in the source, or null for the end.
  final Duration? end;

  /// How long the output is.
  final Duration duration;

  /// A copy with a different size and bitrate.
  VideoPlan copyWith({int? width, int? height, int? videoBitrate}) => VideoPlan(
    width: width ?? this.width,
    height: height ?? this.height,
    videoBitrate: videoBitrate ?? this.videoBitrate,
    audioBitrate: audioBitrate,
    includeAudio: includeAudio,
    duration: duration,
    frameRate: frameRate,
    start: start,
    end: end,
  );

  @override
  String toString() =>
      'VideoPlan(${width}x$height, video $videoBitrate bps, '
      '${includeAudio ? 'audio $audioBitrate bps' : 'no audio'}'
      '${frameRate == null ? '' : ', $frameRate fps'}, $duration)';
}

/// The lowest video bitrate the planner picks, in bits per second.
const minVideoBitrate = 100000;

/// Below this many bits per pixel per frame, video turns to mush, so a
/// size limit lowers the resolution instead.
const _minBitsPerPixel = 0.04;

const _resolutionSteps = [1080, 720, 540, 480, 360, 240];

/// Works out the output settings for [source] under [options].
VideoPlan planVideo(MediaInfo source, VideoOptions options) {
  final sourceDuration = source.duration ?? Duration.zero;
  final start = options.start == null || options.start! <= Duration.zero
      ? null
      : options.start;
  final end = options.end == null || options.end! >= sourceDuration
      ? null
      : options.end;
  final duration = (end ?? sourceDuration) - (start ?? Duration.zero);
  if (duration <= Duration.zero) {
    throw ArgumentError('The start must be before the end and the video end.');
  }
  final seconds = duration.inMicroseconds / Duration.microsecondsPerSecond;

  final sourceRate = source.frameRate ?? 30;
  final frameRate =
      options.frameRate != null && options.frameRate! < sourceRate - 0.5
      ? options.frameRate
      : null;
  final rate = frameRate ?? sourceRate;

  final includeAudio = options.includeAudio;
  // Some platforms copy the audio as is, so budget for the bigger of the two.
  final audioBitrate = includeAudio
      ? math.max(options.audioBitrate, source.audioBitrate ?? 0)
      : 0;

  final sourceShort = math.min(source.width, source.height);
  var short = math.min(
    options.resolution ?? options.quality.resolution,
    sourceShort,
  );

  int pixels(int shortSide) {
    final size = _scaleToShortSide(source.width, source.height, shortSide);
    return size.width * size.height;
  }

  var bitrate =
      options.bitrate ??
      (pixels(short) * rate * options.quality.bitsPerPixel).round();
  final sourceVideoBitrate =
      source.videoBitrate ??
      (source.bitrate == null ? null : source.bitrate! - audioBitrate);
  if (sourceVideoBitrate != null && sourceVideoBitrate > 0) {
    // Re-encoding at the original's bitrate or more only adds size.
    bitrate = math.min(bitrate, (sourceVideoBitrate * 0.9).round());
  }

  if (options.maxSizeMB != null) {
    final bits = options.maxSizeMB! * 1024 * 1024 * 8 * 0.95;
    final budget = (bits / seconds - audioBitrate).floor();
    if (budget < bitrate) {
      bitrate = budget;
      if (options.resolution == null) {
        for (final step in _resolutionSteps) {
          if (step >= short) continue;
          if (bitrate / (pixels(short) * rate) >= _minBitsPerPixel) break;
          short = step;
        }
      }
    }
  }
  bitrate = math.max(bitrate, minVideoBitrate);

  final size = _scaleToShortSide(source.width, source.height, short);
  return VideoPlan(
    width: size.width,
    height: size.height,
    videoBitrate: bitrate,
    audioBitrate: options.audioBitrate,
    includeAudio: includeAudio,
    frameRate: frameRate,
    start: start,
    end: end,
    duration: duration,
  );
}

/// The plan for one more pass after [plan] produced [actualBytes], more than
/// [maxBytes], or null when another pass can't help.
///
/// The bitrate drops in proportion to the overshoot. Some encoders won't go
/// below a minimum quality whatever the bitrate, so when the result
/// overshot by far, the resolution drops too: fewer pixels are the only way
/// to fewer bytes there.
VideoPlan? shrinkPlan(VideoPlan plan, int actualBytes, double maxBytes) {
  final seconds = plan.duration.inMicroseconds / Duration.microsecondsPerSecond;
  if (seconds <= 0) return null;
  final audioBits = plan.includeAudio ? plan.audioBitrate * seconds : 0.0;
  final videoBits = actualBytes * 8 - audioBits;
  final targetVideoBits = maxBytes * 8 * 0.92 - audioBits;
  if (videoBits <= 0 || targetVideoBits <= 0) return null;
  final ratio = targetVideoBits / videoBits;
  if (ratio >= 1) return null;

  final bitrate = math.max(
    minVideoBitrate,
    (plan.videoBitrate * ratio).floor(),
  );
  final ignoredBitrate = videoBits / seconds > plan.videoBitrate * 1.3;
  if (!ignoredBitrate) {
    return bitrate < plan.videoBitrate
        ? plan.copyWith(videoBitrate: bitrate)
        : null;
  }
  final scale = math.sqrt(ratio);
  int even(double value) => math.max(2, (value / 2).round() * 2);
  final width = even(plan.width * scale);
  final height = even(plan.height * scale);
  if (math.min(width, height) < 96) return null;
  return plan.copyWith(width: width, height: height, videoBitrate: bitrate);
}

/// Whether [source] can be returned as is under [options], without
/// compressing it: it fits the size limit and nothing else asks for a
/// change.
bool videoAlreadyFits(MediaInfo source, VideoOptions options) {
  final maxSizeMB = options.maxSizeMB;
  if (maxSizeMB == null || source.size > maxSizeMB * 1024 * 1024) {
    return false;
  }
  return videoMayReturnOriginal(source, options) && options.bitrate == null;
}

/// Whether the original may stand in for a result that came out bigger:
/// it isn't trimmed, its audio is kept, and it isn't too big for the
/// requested resolution or frame rate.
bool videoMayReturnOriginal(MediaInfo source, VideoOptions options) {
  final duration = source.duration ?? Duration.zero;
  final trimmed =
      (options.start != null && options.start! > Duration.zero) ||
      (options.end != null && options.end! < duration);
  final dropsAudio = !options.includeAudio && source.hasAudio;
  final missingRequestedAudio = options.includeAudio && !source.hasAudio;
  final tooTall =
      options.resolution != null &&
      math.min(source.width, source.height) > options.resolution!;
  final tooFast =
      options.frameRate != null &&
      source.frameRate != null &&
      source.frameRate! > options.frameRate! + 0.5;
  return !trimmed &&
      !dropsAudio &&
      !missingRequestedAudio &&
      !tooTall &&
      !tooFast;
}

/// [width] x [height] scaled so the short side is [shortSide], rounded to
/// even numbers, which video encoders need.
({int width, int height}) _scaleToShortSide(
  int width,
  int height,
  int shortSide,
) {
  final short = math.min(width, height);
  if (short <= 0) return (width: width, height: height);
  final scale = math.min(1.0, shortSide / short);
  int even(double value) => math.max(2, (value / 2).round() * 2);
  return (width: even(width * scale), height: even(height * scale));
}

/// The bits per pixel an image will take at [pixels], from encodes of
/// smaller copies.
///
/// Smaller copies pack more detail into each pixel, so they take more bits
/// per pixel. Between two copies that follows a power of the pixel count,
/// which is extended to the full size.
double estimateBitsPerPixel(
  List<({double pixels, double bitsPerPixel})> samples,
  int pixels,
) {
  final sorted = [...samples]..sort((a, b) => a.pixels.compareTo(b.pixels));
  final large = sorted.last;
  if (pixels <= large.pixels || sorted.length < 2) {
    return large.bitsPerPixel;
  }
  final small = sorted.first;
  var exponent = 0.0;
  if (large.pixels > small.pixels &&
      small.bitsPerPixel > 0 &&
      large.bitsPerPixel > 0) {
    exponent =
        math.log(small.bitsPerPixel / large.bitsPerPixel) /
        math.log(large.pixels / small.pixels);
  }
  // Keep a noisy pair of samples from predicting something absurd.
  exponent = exponent.clamp(0.0, 0.6);
  return large.bitsPerPixel *
      math.pow(large.pixels / pixels, exponent).toDouble();
}
