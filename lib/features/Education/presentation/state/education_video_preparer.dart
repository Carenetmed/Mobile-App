import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:media_compress_kit/media_compress_kit.dart';

class EducationPickedVideo {
  const EducationPickedVideo({required this.name, required this.path});

  final String name;
  final String path;
}

class PreparedEducationVideo {
  const PreparedEducationVideo({
    required this.name,
    required this.bytes,
    required this.duration,
  });

  final String name;
  final Uint8List bytes;
  final Duration duration;
}

abstract interface class EducationVideoPreparer {
  Future<PreparedEducationVideo> prepare(
    EducationPickedVideo video, {
    required EducationVideoPreparationController controller,
    required void Function(double progress) onProgress,
  });
}

class EducationVideoPreparationController {
  CompressController? _nativeController;
  bool _cancelled = false;
  final Completer<void> _cancelledCompleter = Completer<void>();

  bool get isCancelled => _cancelled;
  Future<void> get whenCancelled => _cancelledCompleter.future;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _cancelledCompleter.complete();
    final nativeController = _nativeController;
    if (nativeController != null) {
      unawaited(nativeController.cancel().catchError((Object _) {}));
    }
  }

  void bind(CompressController controller) {
    _nativeController = controller;
    if (_cancelled) controller.cancel();
  }
}

class NativeEducationVideoPreparer implements EducationVideoPreparer {
  NativeEducationVideoPreparer({
    this.inspect,
    this.compressVideo,
    this.inspectTimeout = const Duration(seconds: 20),
    this.readChunk,
  });

  final Future<MediaInfo> Function(String path)? inspect;
  final Future<VideoResult> Function(
    String path,
    CompressController controller,
    void Function(double progress) onProgress,
  )?
  compressVideo;
  final Duration inspectTimeout;
  final Future<Uint8List> Function(RandomAccessFile file, int length)?
  readChunk;

  static const Duration maxDuration = Duration(seconds: 60);
  static const int maxBytes = 25 * 1024 * 1024;
  static const int _readChunkSize = 64 * 1024;
  static const int maxLongEdge = 1280;
  static const int maxPixels = 1280 * 720;

  @override
  Future<PreparedEducationVideo> prepare(
    EducationPickedVideo video, {
    required EducationVideoPreparationController controller,
    required void Function(double progress) onProgress,
  }) async {
    if (controller.isCancelled) {
      throw const EducationVideoPreparationCancelled();
    }

    String? ownedOutputPath;
    try {
      final source = await _inspectBounded(video.path, controller);
      if (source.type != MediaType.video || source.duration == null) {
        throw _invalidVideo();
      }
      if (source.duration! <= Duration.zero || source.duration! > maxDuration) {
        throw _durationFailure();
      }
      final nativeController = CompressController();
      controller.bind(nativeController);
      void reportProgress(double value) {
        if (!controller.isCancelled) onProgress(value.clamp(0, 1));
      }

      final compression =
          compressVideo == null
              ? MediaCompress.compressVideo(
                video.path,
                options: const VideoOptions(
                  resolution: 720,
                  bitrate: 3000000,
                  maxSizeMB: 24,
                  codec: VideoCodec.h264,
                  includeAudio: true,
                  audioBitrate: 128000,
                  allowLarger: true,
                ),
                controller: nativeController,
                onProgress: reportProgress,
              )
              : compressVideo!(video.path, nativeController, reportProgress);
      final result = await _awaitCancellable(
        compression,
        controller,
        onLateValue: (lateResult) => _deleteResult(lateResult, video.path),
      );
      if (result.isOriginal || await _samePath(result.path, video.path)) {
        throw _invalidVideo();
      }
      ownedOutputPath = result.path;

      final output = await _inspectBounded(
        result.path,
        controller,
        onAbandoned: () => _deleteOwnedOutput(result.path, video.path),
        timeoutFailure: _outputFailure,
      );
      final pixels = output.width * output.height;
      if (output.type != MediaType.video ||
          !output.hasAudio ||
          output.duration == null ||
          output.duration! <= Duration.zero ||
          output.duration! > maxDuration ||
          output.width > maxLongEdge ||
          output.height > maxLongEdge ||
          pixels > maxPixels ||
          output.size <= 0 ||
          output.size > maxBytes) {
        throw _outputFailure();
      }

      final bytes = await _readBounded(result.path, controller);
      onProgress(1);
      return PreparedEducationVideo(
        name: 'education-video.mp4',
        bytes: bytes,
        duration: output.duration!,
      );
    } finally {
      if (ownedOutputPath != null) {
        await _deleteOwnedOutput(ownedOutputPath, video.path);
      }
    }
  }

  Future<MediaInfo> _inspectBounded(
    String path,
    EducationVideoPreparationController controller, {
    Future<void> Function()? onAbandoned,
    AuthFailure Function()? timeoutFailure,
  }) async {
    final inspection = _inspect(path);
    var abandoned = false;
    final lateCleanup = inspection.then<void>((_) async {
      if (abandoned) await onAbandoned?.call();
    }, onError: (Object _, StackTrace __) {});
    try {
      return await _awaitCancellable(
        inspection.timeout(inspectTimeout),
        controller,
        onLateValue: (_) => onAbandoned?.call() ?? Future<void>.value(),
      );
    } on TimeoutException {
      abandoned = true;
      unawaited(lateCleanup);
      if (controller.isCancelled) {
        throw const EducationVideoPreparationCancelled();
      }
      throw (timeoutFailure ?? _invalidVideo)();
    } on EducationVideoPreparationCancelled {
      abandoned = true;
      unawaited(lateCleanup);
      throw const EducationVideoPreparationCancelled();
    }
  }

  Future<T> _awaitCancellable<T>(
    Future<T> operation,
    EducationVideoPreparationController controller, {
    Future<void> Function(T value)? onLateValue,
  }) {
    final guarded = operation.then<T>((value) {
      if (controller.isCancelled) {
        if (onLateValue != null) unawaited(onLateValue(value));
        throw const EducationVideoPreparationCancelled();
      }
      return value;
    });
    return Future.any<T>([
      guarded,
      controller.whenCancelled.then<T>(
        (_) => throw const EducationVideoPreparationCancelled(),
      ),
    ]);
  }

  Future<Uint8List> _readBounded(
    String path,
    EducationVideoPreparationController controller,
  ) async {
    final file = File(path);
    final length = await file.length();
    if (length <= 0 || length > maxBytes) throw _outputFailure();
    final handle = await file.open();
    final bytes = BytesBuilder(copy: false);
    try {
      var read = 0;
      while (read < length) {
        if (controller.isCancelled) {
          throw const EducationVideoPreparationCancelled();
        }
        final chunk =
            await (readChunk?.call(
                  handle,
                  math.min(_readChunkSize, length - read),
                ) ??
                handle.read(math.min(_readChunkSize, length - read)));
        if (controller.isCancelled) {
          throw const EducationVideoPreparationCancelled();
        }
        if (chunk.isEmpty) break;
        read += chunk.length;
        if (read > maxBytes) throw _outputFailure();
        bytes.add(chunk);
      }
    } finally {
      await handle.close();
    }
    final result = bytes.takeBytes();
    if (result.isEmpty || result.length != length || result.length > maxBytes) {
      throw _outputFailure();
    }
    return result;
  }

  Future<void> _deleteResult(VideoResult result, String sourcePath) async {
    if (!result.isOriginal) {
      await _deleteOwnedOutput(result.path, sourcePath);
    }
  }

  Future<void> _deleteOwnedOutput(String path, String sourcePath) async {
    if (await _samePath(path, sourcePath)) return;
    try {
      await File(path).delete();
    } on FileSystemException {
      // The native compressor may already have removed a cancelled output.
    }
  }

  Future<bool> _samePath(String first, String second) async {
    Future<String> canonicalPath(String value) async {
      try {
        return await File(value).resolveSymbolicLinks();
      } on FileSystemException {
        return File(value).absolute.path;
      }
    }

    final paths = await Future.wait([
      canonicalPath(first),
      canonicalPath(second),
    ]);
    final a = File(paths[0]).absolute.path;
    final b = File(paths[1]).absolute.path;
    return Platform.isWindows ? a.toLowerCase() == b.toLowerCase() : a == b;
  }

  AuthFailure _invalidVideo() => const AuthFailure(
    type: AuthFailureType.validation,
    message: 'Choose a readable video recording and try again.',
  );

  AuthFailure _durationFailure() => const AuthFailure(
    type: AuthFailureType.validation,
    message: 'Choose a video that is 60 seconds or shorter.',
  );

  AuthFailure _outputFailure() => const AuthFailure(
    type: AuthFailureType.validation,
    message:
        'This video could not be prepared within the upload limits. Your draft is still saved.',
  );

  Future<MediaInfo> _inspect(String path) =>
      inspect == null ? MediaCompress.getInfo(path) : inspect!(path);
}

class EducationVideoPreparationCancelled implements Exception {
  const EducationVideoPreparationCancelled();
}
