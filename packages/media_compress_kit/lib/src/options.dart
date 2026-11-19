/// The file format of a compressed image.
enum ImageFormat {
  /// JPEG. Works everywhere; the best default for photos.
  jpeg,

  /// PNG. Lossless, so [ImageOptions.quality] is ignored. Good for
  /// screenshots and graphics with flat colors.
  png,

  /// WebP (lossy). Smaller than JPEG at the same quality. Android only;
  /// iOS can read WebP but not write it.
  webp,

  /// HEIC. About half the size of JPEG at the same quality. iOS only.
  heic,
}

/// What happens to an image's metadata (EXIF: camera, date, location...).
enum ImageMetadata {
  /// Remove all metadata. The default: it is the smallest and leaks nothing.
  removeAll,

  /// Keep metadata such as the camera and date taken, but remove the GPS
  /// location.
  keepWithoutLocation,

  /// Keep all metadata, including the GPS location.
  keepAll,
}

/// Options for [MediaCompress.compressImage].
class ImageOptions {
  /// Creates image compression options.
  const ImageOptions({
    this.quality = 80,
    this.maxWidth = 1920,
    this.maxHeight = 1920,
    this.format = ImageFormat.jpeg,
    this.maxSizeKB,
    this.metadata = ImageMetadata.removeAll,
    this.outputPath,
    this.allowLarger = false,
  }) : assert(quality >= 1 && quality <= 100),
       assert(maxWidth == null || maxWidth > 0),
       assert(maxHeight == null || maxHeight > 0),
       assert(maxSizeKB == null || maxSizeKB > 0);

  /// Encoder quality from 1 (smallest) to 100 (best). Ignored for PNG.
  final int quality;

  /// The largest width of the result in pixels, or null for no limit. The
  /// image is scaled down to fit inside [maxWidth] x [maxHeight], keeping
  /// its aspect ratio. It is never scaled up.
  final int? maxWidth;

  /// The largest height of the result in pixels, or null for no limit.
  final int? maxHeight;

  /// The output format.
  final ImageFormat format;

  /// A size the result should not exceed, in kilobytes (1 KB = 1024 bytes).
  ///
  /// The quality is lowered until the image fits, and if even a low quality
  /// is too big, the image is also scaled down. When the original image is
  /// already small enough (and in the same format and within the size
  /// limits), it is returned as is.
  final int? maxSizeKB;

  /// What to do with the image's metadata.
  final ImageMetadata metadata;

  /// Where to write the result. By default a new file in the app's cache
  /// directory (see [MediaCompress.clearCache]).
  ///
  /// In [MediaCompress.compressAll], this is a folder: each image is written
  /// into it, named after its input.
  final String? outputPath;

  /// Whether to return the compressed file even when it is bigger than the
  /// original. By default the original is returned instead (see
  /// [CompressResult.isOriginal]), unless the result had to change format
  /// or be scaled down.
  final bool allowLarger;
}

/// A quality preset for [VideoOptions].
enum VideoQuality {
  /// 480p, a low bitrate. For previews and slow networks.
  low(480, 0.05),

  /// 720p. A good balance for sharing and uploads.
  medium(720, 0.07),

  /// 1080p, a high bitrate.
  high(1080, 0.1);

  const VideoQuality(this.resolution, this.bitsPerPixel);

  /// The short side of the output in pixels, e.g. 720 for 720p.
  final int resolution;

  /// Bits per pixel per frame, used to pick a bitrate.
  final double bitsPerPixel;
}

/// The video codec of a compressed video.
enum VideoCodec {
  /// H.264 (AVC). Plays everywhere. The default.
  h264,

  /// H.265 (HEVC). About 30-40% smaller at the same quality, but older
  /// devices and some browsers can't play it. Falls back to H.264 on
  /// Android devices without an HEVC encoder.
  hevc,
}

/// Options for [MediaCompress.compressVideo].
class VideoOptions {
  /// Creates video compression options.
  const VideoOptions({
    this.quality = VideoQuality.medium,
    this.resolution,
    this.bitrate,
    this.maxSizeMB,
    this.frameRate,
    this.includeAudio = true,
    this.audioBitrate = 128000,
    this.start,
    this.end,
    this.codec = VideoCodec.h264,
    this.outputPath,
    this.allowLarger = false,
  }) : assert(resolution == null || resolution >= 16),
       assert(bitrate == null || bitrate > 0),
       assert(maxSizeMB == null || maxSizeMB > 0),
       assert(frameRate == null || frameRate > 0),
       assert(audioBitrate > 0);

  /// The quality preset. It picks the [resolution] and a bitrate that fits
  /// it, unless they are set explicitly.
  final VideoQuality quality;

  /// The short side of the output in pixels, e.g. 720 for 720p, so a
  /// portrait video becomes 720 pixels wide. Videos are never scaled up.
  final int? resolution;

  /// The video bitrate in bits per second. Overrides the bitrate picked by
  /// [quality]. It is never raised above the original's.
  final int? bitrate;

  /// A size the result should not exceed, in megabytes (1 MB = 1024 KB),
  /// e.g. 16 for a messaging app's limit.
  ///
  /// The bitrate is computed from the video's length, and the resolution is
  /// lowered when the bitrate would be too low for it. Encoders treat the
  /// bitrate as a rough target, so if the result still comes out too big, it
  /// is compressed again (up to three more times), aiming lower each time,
  /// and lowering the resolution if the encoder won't go below its minimum
  /// quality.
  /// When the original is already small enough, and nothing else asks for a
  /// change, the original is returned as is.
  final double? maxSizeMB;

  /// The highest frame rate of the output, e.g. 30. Frames are dropped to
  /// reach it; the frame rate is never raised.
  final double? frameRate;

  /// Whether to keep the audio track.
  final bool includeAudio;

  /// The audio bitrate in bits per second, used when the audio is
  /// re-encoded.
  final int audioBitrate;

  /// Where the output starts in the original. Null for the beginning.
  final Duration? start;

  /// Where the output ends in the original. Null for the end.
  final Duration? end;

  /// The video codec.
  final VideoCodec codec;

  /// Where to write the result, an `.mp4` file. By default a new file in the
  /// app's cache directory (see [MediaCompress.clearCache]).
  ///
  /// In [MediaCompress.compressAll], this is a folder: each video is written
  /// into it, named after its input.
  final String? outputPath;

  /// Whether to return the compressed file even when it is bigger than the
  /// original. By default the original is returned instead (see
  /// [CompressResult.isOriginal]), unless it is trimmed, or too big for the
  /// requested resolution or frame rate.
  final bool allowLarger;
}

/// What [MediaCompress.pick] lets the user choose.
enum PickType {
  /// Photos only.
  image,

  /// Videos only.
  video,

  /// Photos and videos.
  any,
}
