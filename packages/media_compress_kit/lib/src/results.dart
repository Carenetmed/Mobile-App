import 'media_compress.dart';
import 'options.dart';

/// Whether a file is an image or a video.
enum MediaType {
  /// A still image.
  image,

  /// A video.
  video,
}

/// Facts about an image or video file, from [MediaCompress.getInfo].
class MediaInfo {
  /// Creates media info.
  const MediaInfo({
    required this.path,
    required this.type,
    required this.size,
    required this.width,
    required this.height,
    this.mimeType,
    this.rotation = 0,
    this.duration,
    this.frameRate,
    this.bitrate,
    this.videoBitrate,
    this.audioBitrate,
    this.hasAudio = false,
  });

  /// Reads info from the map sent by the platform side.
  factory MediaInfo.fromMap(String path, Map<Object?, Object?> map) {
    final durationMs = (map['durationMs'] as num?)?.toInt();
    return MediaInfo(
      path: path,
      type: map['type'] == 'video' ? MediaType.video : MediaType.image,
      size: (map['size'] as num).toInt(),
      width: (map['width'] as num).toInt(),
      height: (map['height'] as num).toInt(),
      mimeType: map['mimeType'] as String?,
      rotation: (map['rotation'] as num?)?.toInt() ?? 0,
      duration: durationMs == null ? null : Duration(milliseconds: durationMs),
      frameRate: _positive(map['frameRate']),
      bitrate: _positive(map['bitrate'])?.round(),
      videoBitrate: _positive(map['videoBitrate'])?.round(),
      audioBitrate: _positive(map['audioBitrate'])?.round(),
      hasAudio: map['hasAudio'] == true,
    );
  }

  static double? _positive(Object? value) {
    final number = (value as num?)?.toDouble();
    return number == null || number <= 0 || number.isNaN ? null : number;
  }

  /// The file path.
  final String path;

  /// Whether the file is an image or a video.
  final MediaType type;

  /// The file size in bytes.
  final int size;

  /// The width as displayed, after [rotation] is applied.
  final int width;

  /// The height as displayed, after [rotation] is applied.
  final int height;

  /// The MIME type, such as `image/jpeg` or `video/mp4`, when known.
  final String? mimeType;

  /// How much the stored pixels are rotated for display, in degrees: 0, 90,
  /// 180 or 270. Phones record portrait videos as landscape frames with a
  /// rotation of 90.
  final int rotation;

  /// How long the video is. Null for images.
  final Duration? duration;

  /// The video's frame rate, when known.
  final double? frameRate;

  /// The video's overall bitrate in bits per second, when known.
  final int? bitrate;

  /// The bitrate of the video track in bits per second, when known.
  final int? videoBitrate;

  /// The bitrate of the audio track in bits per second, when known.
  final int? audioBitrate;

  /// Whether the video has an audio track.
  final bool hasAudio;

  /// Whether the video is in portrait orientation, i.e. taller than wide.
  bool get isPortrait => height > width;

  @override
  String toString() =>
      'MediaInfo(${type.name}, ${width}x$height, $size bytes'
      '${duration == null ? '' : ', $duration'})';
}

/// The result of compressing an image or a video.
abstract class CompressResult {
  /// Creates a result.
  const CompressResult({
    required this.path,
    required this.size,
    required this.originalSize,
    required this.width,
    required this.height,
    this.isOriginal = false,
  });

  /// The path of the compressed file. When [isOriginal] is true, it is the
  /// original file's path.
  final String path;

  /// The size of the file at [path] in bytes.
  final int size;

  /// The size of the original file in bytes.
  final int originalSize;

  /// The width of the result in pixels.
  final int width;

  /// The height of the result in pixels.
  final int height;

  /// True when the original file is returned instead of a compressed copy,
  /// because it was already small enough, or compressing it would have made
  /// it bigger. Don't delete the file at [path] in that case.
  final bool isOriginal;

  /// The result's size as a fraction of the original's, e.g. 0.25 when the
  /// result is a quarter of the size.
  double get ratio => originalSize == 0 ? 1 : size / originalSize;

  /// How many bytes were saved.
  int get savedBytes => originalSize - size;
}

/// The result of [MediaCompress.compressImage].
class ImageResult extends CompressResult {
  /// Creates an image result.
  const ImageResult({
    required super.path,
    required super.size,
    required super.originalSize,
    required super.width,
    required super.height,
    required this.format,
    super.isOriginal,
  });

  /// The image's format. When [isOriginal] is true, this is the requested
  /// format, which the original already has.
  final ImageFormat format;

  @override
  String toString() =>
      'ImageResult(${width}x$height ${format.name}, $originalSize -> $size '
      'bytes${isOriginal ? ', original' : ''})';
}

/// The result of compressing a video with [MediaCompress.compressVideo].
class VideoResult extends CompressResult {
  /// Creates a video result.
  const VideoResult({
    required super.path,
    required super.size,
    required super.originalSize,
    required super.width,
    required super.height,
    required this.duration,
    super.isOriginal,
  });

  /// How long the result is.
  final Duration duration;

  /// The average bitrate of the result in bits per second.
  int get bitrate => duration.inMicroseconds == 0
      ? 0
      : (size * 8 * 1000000 / duration.inMicroseconds).round();

  @override
  String toString() =>
      'VideoResult(${width}x$height, $duration, $originalSize -> $size '
      'bytes${isOriginal ? ', original' : ''})';
}

/// A still frame from a video, from [MediaCompress.thumbnail].
class Thumbnail {
  /// Creates a thumbnail.
  const Thumbnail({
    required this.path,
    required this.width,
    required this.height,
    required this.size,
  });

  /// The path of the JPEG file.
  final String path;

  /// The width in pixels.
  final int width;

  /// The height in pixels.
  final int height;

  /// The file size in bytes.
  final int size;

  @override
  String toString() => 'Thumbnail(${width}x$height, $size bytes)';
}

/// A predicted result, from [MediaCompress.estimateImage] and
/// [MediaCompress.estimateVideo].
class SizeEstimate {
  /// Creates an estimate.
  const SizeEstimate({
    required this.size,
    required this.width,
    required this.height,
    this.isOriginal = false,
  });

  /// The predicted size in bytes.
  final int size;

  /// The width the result will have.
  final int width;

  /// The height the result will have.
  final int height;

  /// True when compressing would return the original as is (see
  /// [CompressResult.isOriginal]); [size] is then the original's size.
  final bool isOriginal;

  @override
  String toString() =>
      'SizeEstimate(${width}x$height, ~$size bytes'
      '${isOriginal ? ', original' : ''})';
}

/// One file's outcome in [MediaCompress.compressAll]: a [result] or an
/// [error].
class BatchItem {
  /// Creates a batch item.
  const BatchItem({required this.path, this.result, this.error})
    : assert((result == null) != (error == null));

  /// The input path.
  final String path;

  /// The compressed file: an [ImageResult] or a [VideoResult]. Null when it
  /// failed.
  final CompressResult? result;

  /// Why it failed. Null when it succeeded.
  final MediaCompressException? error;

  /// Whether it succeeded.
  bool get isSuccess => result != null;

  @override
  String toString() =>
      'BatchItem($path, ${isSuccess ? result : 'error: $error'})';
}
