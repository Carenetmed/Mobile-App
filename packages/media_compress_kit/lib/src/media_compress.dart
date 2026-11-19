import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'batch_output.dart';
import 'download.dart';
import 'options.dart';
import 'planner.dart';
import 'results.dart';

/// Why a [MediaCompress] call failed.
enum MediaCompressError {
  /// The input file doesn't exist or can't be read.
  fileNotFound,

  /// The file isn't an image or video this device can decode, or the
  /// requested output format or codec isn't available on this platform.
  unsupported,

  /// The arguments don't make sense, e.g. a trim that starts after it ends.
  invalidArgument,

  /// The work was cancelled with [CompressController.cancel].
  cancelled,

  /// Downloading a URL failed: no connection, a timeout, or an HTTP error
  /// such as 404.
  network,

  /// Decoding, encoding or writing failed. See [MediaCompressException.message].
  failed,
}

/// Thrown when compressing, reading info, picking or making a thumbnail
/// fails.
class MediaCompressException implements Exception {
  /// Creates an exception.
  const MediaCompressException(this.error, this.message);

  factory MediaCompressException._fromPlatform(PlatformException e) {
    final error = switch (e.code) {
      'FILE_NOT_FOUND' => MediaCompressError.fileNotFound,
      'UNSUPPORTED' => MediaCompressError.unsupported,
      'INVALID_ARGUMENT' => MediaCompressError.invalidArgument,
      'CANCELLED' => MediaCompressError.cancelled,
      'NETWORK' => MediaCompressError.network,
      _ => MediaCompressError.failed,
    };
    return MediaCompressException(error, e.message ?? e.code);
  }

  /// What kind of failure this is.
  final MediaCompressError error;

  /// A description of what went wrong, for logs.
  final String message;

  @override
  String toString() => 'MediaCompressException(${error.name}): $message';
}

const _cancelled = MediaCompressException(
  MediaCompressError.cancelled,
  'The compression was cancelled.',
);

/// Cancels compressions it is passed to.
///
/// ```dart
/// final controller = CompressController();
/// MediaCompress.compressVideo(path, controller: controller);
/// // Later:
/// controller.cancel();
/// ```
///
/// The cancelled call throws a [MediaCompressException] with
/// [MediaCompressError.cancelled] and deletes its partial output. One
/// controller can cancel several calls at once, such as a whole
/// [MediaCompress.compressAll] batch. Once cancelled, it stays cancelled;
/// use a new controller for new work.
class CompressController {
  final _jobs = <int>{};
  final _aborts = <void Function()>{};
  var _isCancelled = false;

  /// Whether [cancel] was called.
  bool get isCancelled => _isCancelled;

  /// Cancels every compression this controller was passed to.
  Future<void> cancel() async {
    if (_isCancelled) return;
    _isCancelled = true;
    for (final abort in _aborts.toList()) {
      abort();
    }
    await Future.wait([
      for (final id in _jobs.toList())
        MediaCompress._invoke<void>('cancel', {'id': id}),
    ]);
  }
}

/// Reports progress that only goes up, mapped into a range of the overall
/// progress.
class _Progress {
  _Progress(this._report);

  final void Function(double progress)? _report;
  var _last = -1.0;

  void report(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (clamped <= _last) return;
    _last = clamped;
    _report?.call(clamped);
  }

  /// A callback for progress from 0 to 1 within [from] to [to] overall.
  void Function(double) range(double from, double to) =>
      (p) => report(from + (to - from) * p);
}

/// Compresses images and videos with the platform's own encoders: Media3
/// Transformer and the Android image codecs on Android, AVFoundation and
/// ImageIO on iOS.
///
/// ```dart
/// final image = await MediaCompress.compressImage(photoPath);
///
/// final video = await MediaCompress.compressVideo(
///   videoPath,
///   options: const VideoOptions(maxSizeMB: 16),
///   onProgress: (p) => print('${(p * 100).round()}%'),
/// );
/// ```
abstract final class MediaCompress {
  static const _methods = MethodChannel('media_compress_kit');
  static const _events = EventChannel('media_compress_kit/progress');

  static StreamSubscription<Object?>? _progressSubscription;
  static final _listeners = <int, void Function(double)>{};
  static var _nextId = 0;

  /// Reads the type, size, dimensions and, for videos, the duration, frame
  /// rate and bitrates of the image or video at [path].
  ///
  /// [path] can be a URL: the file is downloaded (sending [headers]), read
  /// and deleted.
  static Future<MediaInfo> getInfo(
    String path, {
    Map<String, String>? headers,
  }) async {
    if (!isUrl(path)) return _getFileInfo(path);
    final file = await _download(path, headers: headers);
    try {
      return MediaInfo.fromMap(path, await _infoMap(file));
    } finally {
      await _deleteQuietly(file);
    }
  }

  static Future<MediaInfo> _getFileInfo(String path) async =>
      MediaInfo.fromMap(path, await _infoMap(path));

  static Future<Map<Object?, Object?>> _infoMap(String path) =>
      _invoke<Map<Object?, Object?>>('getInfo', {'path': path});

  /// Runs [compress] on [path], downloading it first when it is a URL. The
  /// download takes the first 40% of the progress and is deleted after,
  /// unless the result is that file.
  static Future<R> _withSource<R extends CompressResult>(
    String path, {
    required Map<String, String>? headers,
    required CompressController? controller,
    required void Function(double)? onProgress,
    required Future<R> Function(String file, void Function(double) onProgress)
    compress,
  }) async {
    final progress = _Progress(onProgress)..report(0);
    _checkCancelled(controller);
    if (!isUrl(path)) return compress(path, progress.report);
    final file = await _download(
      path,
      headers: headers,
      controller: controller,
      onProgress: progress.range(0, 0.4),
    );
    try {
      final result = await compress(file, progress.range(0.4, 1));
      if (!result.isOriginal) await _deleteQuietly(file);
      return result;
    } on Object {
      await _deleteQuietly(file);
      rethrow;
    }
  }

  static Future<String> _download(
    String url, {
    Map<String, String>? headers,
    CompressController? controller,
    void Function(double)? onProgress,
  }) async {
    _checkCancelled(controller);
    final folder = await _invoke<String>('cacheDirectory');
    void Function()? abort;
    try {
      return await download(
        url,
        folder: '$folder/downloads',
        headers: headers,
        onProgress: onProgress,
        registerAbort: (callback) {
          abort = callback;
          controller?._aborts.add(callback);
        },
      );
    } on DownloadException catch (e) {
      throw e.cancelled
          ? _cancelled
          : MediaCompressException(MediaCompressError.network, e.message);
    } finally {
      controller?._aborts.remove(abort);
    }
  }

  /// Compresses the image at [path] and returns the new file.
  ///
  /// The image is turned upright (using its EXIF orientation), scaled down
  /// to fit [ImageOptions.maxWidth] x [ImageOptions.maxHeight], and encoded
  /// as [ImageOptions.format]. Any image the platform can decode is
  /// accepted, including HEIC on iOS and on Android 9 and later.
  ///
  /// [path] can also be an `https://` URL: the image is downloaded first
  /// (sending [headers]), and the download takes the first 40% of the
  /// progress.
  ///
  /// [onProgress] gets the progress from 0 to 1 as the image is read,
  /// decoded, scaled, encoded (several times to fit a
  /// [ImageOptions.maxSizeKB]) and saved. [controller] can cancel it.
  ///
  /// The original file is returned instead (with
  /// [CompressResult.isOriginal] set) when it is already small enough, or
  /// compressing it would make it bigger, but only when the original also
  /// has the requested format and size, and [ImageOptions.metadata] is
  /// [ImageMetadata.keepAll]. Otherwise the original would still carry the
  /// metadata you asked to remove.
  static Future<ImageResult> compressImage(
    String path, {
    ImageOptions options = const ImageOptions(),
    void Function(double progress)? onProgress,
    CompressController? controller,
    Map<String, String>? headers,
  }) => _withSource(
    path,
    headers: headers,
    controller: controller,
    onProgress: onProgress,
    compress: (file, onProgress) => _compressImageFile(
      file,
      options: options,
      onProgress: onProgress,
      controller: controller,
    ),
  );

  static Future<ImageResult> _compressImageFile(
    String path, {
    required ImageOptions options,
    required void Function(double progress) onProgress,
    required CompressController? controller,
  }) async {
    final progress = _Progress(onProgress)..report(0);
    _checkCancelled(controller);
    final info = await _getFileInfo(path);
    _expectType(info, MediaType.image);
    final size = _imageSize(info, options);
    final mayReturnOriginal = _imageMayReturnOriginal(info, options, size);
    ImageResult original() {
      progress.report(1);
      return ImageResult(
        path: path,
        size: info.size,
        originalSize: info.size,
        width: info.width,
        height: info.height,
        format: options.format,
        isOriginal: true,
      );
    }

    final maxSizeKB = options.maxSizeKB;
    if (mayReturnOriginal &&
        maxSizeKB != null &&
        info.size <= maxSizeKB * 1024) {
      return original();
    }
    progress.report(0.05);

    final map = await _run(
      'compressImage',
      {
        'path': path,
        'outputPath': options.outputPath,
        'width': size.width,
        'height': size.height,
        'format': options.format.name,
        'quality': options.quality,
        'maxBytes': maxSizeKB == null ? null : maxSizeKB * 1024,
        'metadata': options.metadata.name,
      },
      controller: controller,
      onProgress: progress.range(0.05, 1),
    );
    final result = ImageResult(
      path: map['path']! as String,
      size: (map['size']! as num).toInt(),
      originalSize: info.size,
      width: (map['width']! as num).toInt(),
      height: (map['height']! as num).toInt(),
      format: options.format,
    );
    if (mayReturnOriginal &&
        !options.allowLarger &&
        result.size >= info.size &&
        options.outputPath == null) {
      await _deleteQuietly(result.path);
      return original();
    }
    progress.report(1);
    return result;
  }

  /// Compresses the video at [path] into an `.mp4` file and returns it.
  ///
  /// Rotation is kept, so portrait videos stay portrait. Several videos can
  /// be compressed at once.
  ///
  /// [path] can also be an `https://` URL: the video is downloaded first
  /// (sending [headers]), and the download takes the first 40% of the
  /// progress.
  ///
  /// [onProgress] gets the progress from 0 to 1. When a
  /// [VideoOptions.maxSizeMB] limit needs extra passes, they continue the
  /// same progress instead of starting over. [controller] can cancel it,
  /// which also deletes the partial file.
  ///
  /// The original file is returned instead (with
  /// [CompressResult.isOriginal] set) when it already fits
  /// [VideoOptions.maxSizeMB], or compressing it would make it bigger, as
  /// long as it isn't trimmed, losing its audio, or above the requested
  /// resolution or frame rate.
  static Future<VideoResult> compressVideo(
    String path, {
    VideoOptions options = const VideoOptions(),
    void Function(double progress)? onProgress,
    CompressController? controller,
    Map<String, String>? headers,
  }) => _withSource(
    path,
    headers: headers,
    controller: controller,
    onProgress: onProgress,
    compress: (file, onProgress) => _compressVideoFile(
      file,
      options: options,
      onProgress: onProgress,
      controller: controller,
    ),
  );

  static Future<VideoResult> _compressVideoFile(
    String path, {
    required VideoOptions options,
    required void Function(double progress) onProgress,
    required CompressController? controller,
  }) async {
    final progress = _Progress(onProgress)..report(0);
    _checkCancelled(controller);
    final info = await _getFileInfo(path);
    _expectType(info, MediaType.video);
    VideoResult original() {
      progress.report(1);
      return VideoResult(
        path: path,
        size: info.size,
        originalSize: info.size,
        width: info.width,
        height: info.height,
        duration: info.duration ?? Duration.zero,
        isOriginal: true,
      );
    }

    if (videoAlreadyFits(info, options)) return original();
    final plan = _planVideo(info, options);

    // A size limit may need extra passes; they get ever smaller slices of
    // the progress, so it keeps going up.
    final maxSizeMB = options.maxSizeMB;
    const slices = [(0.02, 0.7), (0.7, 0.9), (0.9, 0.97), (0.97, 0.99)];
    var result = await _encodeVideo(
      path,
      info,
      options,
      plan,
      controller: controller,
      onProgress: progress.range(
        slices[0].$1,
        maxSizeMB == null ? 1 : slices[0].$2,
      ),
    );

    // Encoders treat the bitrate as a rough target, so a size limit gets up
    // to three more passes, each aimed lower by how much the last one missed.
    if (maxSizeMB != null) {
      final maxBytes = maxSizeMB * 1024 * 1024;
      var current = plan;
      for (
        var pass = 1;
        pass < slices.length && result.size > maxBytes;
        pass++
      ) {
        final next = shrinkPlan(current, result.size, maxBytes);
        if (next == null) break;
        await _deleteQuietly(result.path);
        current = next;
        result = await _encodeVideo(
          path,
          info,
          options,
          current,
          controller: controller,
          onProgress: progress.range(slices[pass].$1, slices[pass].$2),
        );
      }
    }

    if (!options.allowLarger &&
        options.outputPath == null &&
        result.size >= info.size &&
        videoMayReturnOriginal(info, options)) {
      await _deleteQuietly(result.path);
      return original();
    }
    progress.report(1);
    return result;
  }

  static Future<VideoResult> _encodeVideo(
    String path,
    MediaInfo info,
    VideoOptions options,
    VideoPlan plan, {
    required CompressController? controller,
    required void Function(double) onProgress,
  }) async {
    final map = await _run(
      'compressVideo',
      {
        'path': path,
        'outputPath': options.outputPath,
        'width': plan.width,
        'height': plan.height,
        'videoBitrate': plan.videoBitrate,
        'audioBitrate': plan.audioBitrate,
        'includeAudio': plan.includeAudio,
        'frameRate': plan.frameRate,
        'startMs': plan.start?.inMilliseconds,
        'endMs': plan.end?.inMilliseconds,
        'codec': options.codec.name,
        // A size limit needs the encoder to stick to the bitrate.
        'constantBitrate': options.maxSizeMB != null,
      },
      controller: controller,
      onProgress: onProgress,
    );
    return VideoResult(
      path: map['path']! as String,
      size: (map['size']! as num).toInt(),
      originalSize: info.size,
      width: (map['width']! as num).toInt(),
      height: (map['height']! as num).toInt(),
      duration: Duration(
        milliseconds:
            (map['durationMs'] as num?)?.toInt() ??
            plan.duration.inMilliseconds,
      ),
    );
  }

  /// Compresses several images and videos, [concurrency] at a time, and
  /// returns one [BatchItem] per path, in the same order.
  ///
  /// Paths can be files or URLs, mixed; URLs are downloaded first, sending
  /// [headers]. Images use [imageOptions] and videos [videoOptions]. A file
  /// that fails doesn't stop the others: its item has the [BatchItem.error]
  /// instead.
  ///
  /// [onProgress] gets the progress of the whole batch from 0 to 1, with
  /// each file weighted by its size. [onItemDone] is called as each file
  /// finishes. [controller] cancels everything still running or waiting.
  ///
  /// The same path or URL more than once is compressed (and downloaded) only
  /// once: each of its entries gets the same [BatchItem], with the same
  /// result file. Don't delete that file after handling the first entry if
  /// you still need it for the others.
  ///
  /// Here, an [ImageOptions.outputPath] or [VideoOptions.outputPath] is a
  /// folder: each result is written into it, named after its input
  /// (`beach.heic` becomes `beach.jpg`), with `_1`, `_2` and so on added
  /// when that name is already taken, so no file is overwritten.
  static Future<List<BatchItem>> compressAll(
    List<String> paths, {
    ImageOptions imageOptions = const ImageOptions(),
    VideoOptions videoOptions = const VideoOptions(),
    int concurrency = 2,
    void Function(double progress)? onProgress,
    void Function(BatchItem item)? onItemDone,
    CompressController? controller,
    Map<String, String>? headers,
  }) async {
    assert(concurrency >= 1);
    final progress = _Progress(onProgress)..report(0);
    final items = List<BatchItem?>.filled(paths.length, null);
    // The same path or URL twice is compressed once; every entry for it gets
    // that result.
    final entries = <String, List<int>>{};
    for (final (index, path) in paths.indexed) {
      entries.putIfAbsent(path, () => []).add(index);
    }
    final unique = entries.keys.toList();
    // Weigh files by size, so a big video moves the bar more than a photo.
    // URLs aren't downloaded twice for this; they weigh as much as the
    // average file.
    final sizes = <int?>[];
    for (final path in unique) {
      try {
        sizes.add(isUrl(path) ? null : (await _getFileInfo(path)).size);
      } on MediaCompressException {
        sizes.add(1);
      }
    }
    final known = sizes.whereType<int>().toList();
    final average = known.isEmpty
        ? 1
        : known.fold(0, (a, b) => a + b) / known.length;
    final weights = [
      for (final size in sizes) math.max(1, size ?? average).toDouble(),
    ];
    final total = weights.fold(0.0, (a, b) => a + b);
    final done = List.filled(unique.length, 0.0);
    void update(int index, double value) {
      done[index] = value;
      var sum = 0.0;
      for (var i = 0; i < done.length; i++) {
        sum += done[i] * weights[i];
      }
      progress.report(sum / total);
    }

    final outputs = BatchOutputs();
    final ordinals = BatchOutputs.ordinals(unique);
    var next = 0;
    Future<void> worker() async {
      while (next < unique.length) {
        final index = next++;
        final path = unique[index];
        BatchItem item;
        try {
          final result = await _withSource<CompressResult>(
            path,
            headers: headers,
            controller: controller,
            onProgress: (p) => update(index, p),
            compress: (file, onProgress) async {
              final info = await _getFileInfo(file);
              // An outputPath is a folder here: each file gets its own name.
              final imageFolder = imageOptions.outputPath;
              final videoFolder = videoOptions.outputPath;
              return info.type == MediaType.image
                  ? _compressImageFile(
                      file,
                      options: imageFolder == null
                          ? imageOptions
                          : imageOptionsWithOutput(
                              imageOptions,
                              outputs.claim(
                                imageFolder,
                                path,
                                imageExtension(imageOptions.format),
                                ordinal: ordinals[index],
                              ),
                            ),
                      onProgress: onProgress,
                      controller: controller,
                    )
                  : _compressVideoFile(
                      file,
                      options: videoFolder == null
                          ? videoOptions
                          : videoOptionsWithOutput(
                              videoOptions,
                              outputs.claim(
                                videoFolder,
                                path,
                                'mp4',
                                ordinal: ordinals[index],
                              ),
                            ),
                      onProgress: onProgress,
                      controller: controller,
                    );
            },
          );
          item = BatchItem(path: path, result: result);
        } on MediaCompressException catch (e) {
          item = BatchItem(path: path, error: e);
        }
        update(index, 1);
        for (final entry in entries[path]!) {
          items[entry] = item;
          onItemDone?.call(item);
        }
      }
    }

    await Future.wait([
      for (var i = 0; i < math.min(concurrency, unique.length); i++) worker(),
    ]);
    progress.report(1);
    return items.cast<BatchItem>();
  }

  /// Predicts the size of [compressImage]'s result with these [options],
  /// without compressing the whole image.
  ///
  /// It encodes two small copies and extends the trend between them to the
  /// full size, which takes a fraction of the time. Expect the real result
  /// within about 20%, since detail differs across an image. Metadata isn't
  /// counted.
  static Future<SizeEstimate> estimateImage(
    String path, {
    ImageOptions options = const ImageOptions(),
  }) async {
    _expectFile(path);
    final info = await getInfo(path);
    _expectType(info, MediaType.image);
    final size = _imageSize(info, options);
    final mayReturnOriginal = _imageMayReturnOriginal(info, options, size);
    SizeEstimate original() => SizeEstimate(
      size: info.size,
      width: info.width,
      height: info.height,
      isOriginal: true,
    );
    final maxBytes = options.maxSizeKB == null
        ? null
        : options.maxSizeKB! * 1024;
    if (mayReturnOriginal && maxBytes != null && info.size <= maxBytes) {
      return original();
    }
    final map = await _invoke<Map<Object?, Object?>>('estimateImage', {
      'path': path,
      'width': size.width,
      'height': size.height,
      'format': options.format.name,
      'quality': options.quality,
    });
    final samples = [
      for (final sample in map['samples']! as List<Object?>)
        (
          pixels: ((sample! as List<Object?>)[0]! as num).toDouble(),
          bitsPerPixel: ((sample as List<Object?>)[1]! as num).toDouble(),
        ),
    ];
    var bytes =
        (estimateBitsPerPixel(samples, size.width * size.height) *
                size.width *
                size.height /
                8)
            .round();
    if (maxBytes != null) bytes = math.min(bytes, maxBytes);
    if (mayReturnOriginal && !options.allowLarger && bytes >= info.size) {
      return original();
    }
    return SizeEstimate(size: bytes, width: size.width, height: size.height);
  }

  /// Predicts the size of [compressVideo]'s result with these [options],
  /// right away, from the bitrate it will use and the video's length.
  ///
  /// Encoders land near the bitrate on average, so expect the real result
  /// within about 20%. With [VideoOptions.maxSizeMB], it never exceeds the
  /// limit.
  static Future<SizeEstimate> estimateVideo(
    String path, {
    VideoOptions options = const VideoOptions(),
  }) async {
    _expectFile(path);
    final info = await getInfo(path);
    _expectType(info, MediaType.video);
    final original = SizeEstimate(
      size: info.size,
      width: info.width,
      height: info.height,
      isOriginal: true,
    );
    if (videoAlreadyFits(info, options)) return original;
    final plan = _planVideo(info, options);
    final seconds =
        plan.duration.inMicroseconds / Duration.microsecondsPerSecond;
    final bitrate =
        plan.videoBitrate + (plan.includeAudio ? plan.audioBitrate : 0);
    // About 1% goes to the file's index.
    var bytes = (bitrate * seconds / 8 * 1.01).round();
    if (options.maxSizeMB != null) {
      bytes = math.min(bytes, (options.maxSizeMB! * 1024 * 1024).floor());
    }
    if (!options.allowLarger &&
        bytes >= info.size &&
        videoMayReturnOriginal(info, options)) {
      return original;
    }
    return SizeEstimate(size: bytes, width: plan.width, height: plan.height);
  }

  /// Opens the system's photo and video picker and returns the paths of
  /// the chosen files, or an empty list when the user cancels.
  ///
  /// It needs no permission: Android shows its Photo Picker (or the file
  /// picker on older versions) and iOS shows `PHPickerViewController`, so
  /// the app only sees what the user picks. The files are copied, unchanged,
  /// into the app's cache (see [clearCache]).
  ///
  /// [multiple] lets the user pick several, up to [maxItems] when set.
  static Future<List<String>> pick({
    PickType type = PickType.any,
    bool multiple = false,
    int? maxItems,
  }) async {
    assert(maxItems == null || maxItems > 0);
    final paths = await _invoke<List<Object?>?>('pick', {
      'type': type.name,
      'multiple': multiple,
      'maxItems': multiple ? maxItems : 1,
    });
    return [...?paths?.cast<String>()];
  }

  /// Saves a frame of the video at [path] as a JPEG, scaled down to fit
  /// [maxWidth] x [maxHeight].
  ///
  /// The frame is the nearest one to [position], which defaults to the
  /// first frame. [path] can be a URL: the video is downloaded (sending
  /// [headers]), and deleted after.
  static Future<Thumbnail> thumbnail(
    String path, {
    Duration position = Duration.zero,
    int maxWidth = 512,
    int maxHeight = 512,
    int quality = 80,
    String? outputPath,
    Map<String, String>? headers,
  }) async {
    assert(quality >= 1 && quality <= 100);
    if (isUrl(path)) {
      final file = await _download(path, headers: headers);
      try {
        return await thumbnail(
          file,
          position: position,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: quality,
          outputPath: outputPath,
        );
      } finally {
        await _deleteQuietly(file);
      }
    }
    final map = await _invoke<Map<Object?, Object?>>('thumbnail', {
      'path': path,
      'positionMs': position.inMilliseconds,
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
      'quality': quality,
      'outputPath': outputPath,
    });
    return Thumbnail(
      path: map['path']! as String,
      width: (map['width']! as num).toInt(),
      height: (map['height']! as num).toInt(),
      size: (map['size']! as num).toInt(),
    );
  }

  /// Deletes every file this package wrote to the app's cache directory:
  /// results, thumbnails, picked files and downloads.
  ///
  /// Files written to an [ImageOptions.outputPath] or
  /// [VideoOptions.outputPath] are not touched. Don't call it while a
  /// compression is running.
  static Future<void> clearCache() => _invoke<void>('clearCache');

  static ({int width, int height}) _imageSize(
    MediaInfo info,
    ImageOptions options,
  ) => fitInside(
    info.width,
    info.height,
    maxWidth: options.maxWidth,
    maxHeight: options.maxHeight,
  );

  static bool _imageMayReturnOriginal(
    MediaInfo info,
    ImageOptions options,
    ({int width, int height}) size,
  ) =>
      options.metadata == ImageMetadata.keepAll &&
      isFormat(info.mimeType, options.format) &&
      size.width == info.width &&
      size.height == info.height;

  static VideoPlan _planVideo(MediaInfo info, VideoOptions options) {
    try {
      return planVideo(info, options);
    } on ArgumentError catch (e) {
      throw MediaCompressException(
        MediaCompressError.invalidArgument,
        '${e.message}',
      );
    }
  }

  static void _expectType(MediaInfo info, MediaType type) {
    if (info.type == type) return;
    throw MediaCompressException(
      MediaCompressError.unsupported,
      type == MediaType.image
          ? '${info.path} is a video. Use compressVideo for videos.'
          : '${info.path} is an image. Use compressImage for images.',
    );
  }

  static void _expectFile(String path) {
    if (!isUrl(path)) return;
    throw const MediaCompressException(
      MediaCompressError.invalidArgument,
      'Estimates need a file on the device, not a URL. Download it first, '
      'or compress the URL directly.',
    );
  }

  static void _checkCancelled(CompressController? controller) {
    if (controller?.isCancelled ?? false) throw _cancelled;
  }

  /// Runs a cancellable native job that reports progress.
  static Future<Map<Object?, Object?>> _run(
    String method,
    Map<String, Object?> arguments, {
    required CompressController? controller,
    required void Function(double) onProgress,
  }) async {
    _checkCancelled(controller);
    final id = _nextId++;
    _listeners[id] = onProgress;
    controller?._jobs.add(id);
    _progressSubscription ??= _events.receiveBroadcastStream().listen((event) {
      final map = event! as Map<Object?, Object?>;
      _listeners[(map['id']! as num).toInt()]?.call(
        (map['progress']! as num).toDouble(),
      );
    }, onError: (Object _) {});
    try {
      final map = await _invoke<Map<Object?, Object?>>(method, {
        ...arguments,
        'id': id,
      });
      if (controller?.isCancelled ?? false) {
        // Cancelled just as it finished.
        await _deleteQuietly(map['path']! as String);
        throw _cancelled;
      }
      return map;
    } finally {
      _listeners.remove(id);
      controller?._jobs.remove(id);
    }
  }

  static Future<T> _invoke<T>(String method, [Object? arguments]) async {
    try {
      return (await _methods.invokeMethod<T>(method, arguments)) as T;
    } on PlatformException catch (e) {
      throw MediaCompressException._fromPlatform(e);
    } on MissingPluginException {
      throw MediaCompressException(
        MediaCompressError.unsupported,
        'media_compress_kit supports Android and iOS, not '
        '${kIsWeb ? 'web' : defaultTargetPlatform.name}.',
      );
    }
  }

  static Future<void> _deleteQuietly(String path) async {
    try {
      await File(path).delete();
    } on FileSystemException {
      // Already gone.
    }
  }
}
