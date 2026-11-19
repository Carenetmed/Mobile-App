import 'dart:async';
import 'dart:io';

import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/presentation/state/education_video_preparer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_compress_kit/media_compress_kit.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('education-video-');
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('normalizes silent input and deletes the generated output', () async {
    final outputPath = '${directory.path}/normalized.mp4';
    await File(outputPath).writeAsBytes([1, 2, 3]);
    final preparer = NativeEducationVideoPreparer(
      inspect: (path) async => _info(path, hasAudio: path == outputPath),
      compressVideo: (path, controller, onProgress) async {
        onProgress(0.5);
        return _result(outputPath);
      },
    );

    final prepared = await preparer.prepare(
      const EducationPickedVideo(name: 'silent.mov', path: 'silent.mov'),
      controller: EducationVideoPreparationController(),
      onProgress: (_) {},
    );

    expect(prepared.bytes, [1, 2, 3]);
    expect(prepared.duration, const Duration(seconds: 30));
    expect(await File(outputPath).exists(), isFalse);
  });

  test('deletes generated output rejected for missing audio', () async {
    final outputPath = '${directory.path}/normalized.mp4';
    await File(outputPath).writeAsBytes([1, 2, 3]);
    final preparer = NativeEducationVideoPreparer(
      inspect: (path) async => _info(path, hasAudio: false),
      compressVideo:
          (path, controller, onProgress) async => _result(outputPath),
    );

    await expectLater(
      preparer.prepare(
        const EducationPickedVideo(name: 'silent.mov', path: 'silent.mov'),
        controller: EducationVideoPreparationController(),
        onProgress: (_) {},
      ),
      throwsA(isA<AuthFailure>()),
    );
    expect(await File(outputPath).exists(), isFalse);
  });

  test(
    'an original result is rejected without deleting the picked source',
    () async {
      final sourcePath = '${directory.path}/source.mp4';
      await File(sourcePath).writeAsBytes([9, 8, 7]);
      final preparer = NativeEducationVideoPreparer(
        inspect: (path) async => _info(path, hasAudio: true),
        compressVideo:
            (path, controller, onProgress) async =>
                _result(sourcePath, isOriginal: true),
      );

      await expectLater(
        preparer.prepare(
          EducationPickedVideo(name: 'source.mp4', path: sourcePath),
          controller: EducationVideoPreparationController(),
          onProgress: (_) {},
        ),
        throwsA(isA<AuthFailure>()),
      );
      expect(await File(sourcePath).readAsBytes(), [9, 8, 7]);
    },
  );

  test(
    'cancellation while inspecting returns promptly and removes output',
    () async {
      final outputPath = '${directory.path}/normalized.mp4';
      await File(outputPath).writeAsBytes([1, 2, 3]);
      final inspectionStarted = Completer<void>();
      final pendingInspection = Completer<MediaInfo>();
      final controller = EducationVideoPreparationController();
      final preparer = NativeEducationVideoPreparer(
        inspect: (path) {
          if (path == outputPath) {
            inspectionStarted.complete();
            return pendingInspection.future;
          }
          return Future.value(_info(path, hasAudio: false));
        },
        compressVideo:
            (path, controller, onProgress) async => _result(outputPath),
      );

      final preparing = preparer.prepare(
        const EducationPickedVideo(name: 'silent.mov', path: 'source.mov'),
        controller: controller,
        onProgress: (_) {},
      );
      await inspectionStarted.future;
      controller.cancel();
      await expectLater(
        preparing,
        throwsA(isA<EducationVideoPreparationCancelled>()),
      );
      expect(await File(outputPath).exists(), isFalse);
      pendingInspection.complete(_info(outputPath, hasAudio: true));
      await Future<void>.delayed(Duration.zero);
      expect(await File(outputPath).exists(), isFalse);
    },
  );

  test(
    'inspection timeout bounds waiting and cleans late completion',
    () async {
      final outputPath = '${directory.path}/normalized.mp4';
      await File(outputPath).writeAsBytes([1, 2, 3]);
      final pendingInspection = Completer<MediaInfo>();
      final preparer = NativeEducationVideoPreparer(
        inspectTimeout: const Duration(milliseconds: 10),
        inspect:
            (path) =>
                path == outputPath
                    ? pendingInspection.future
                    : Future.value(_info(path, hasAudio: false)),
        compressVideo:
            (path, controller, onProgress) async => _result(outputPath),
      );

      await expectLater(
        preparer.prepare(
          const EducationPickedVideo(name: 'silent.mov', path: 'source.mov'),
          controller: EducationVideoPreparationController(),
          onProgress: (_) {},
        ),
        throwsA(isA<AuthFailure>()),
      );
      expect(await File(outputPath).exists(), isFalse);
      pendingInspection.complete(_info(outputPath, hasAudio: true));
      await Future<void>.delayed(Duration.zero);
      expect(await File(outputPath).exists(), isFalse);
    },
  );

  test(
    'late compression result after cancellation is deleted, source retained',
    () async {
      final sourcePath = '${directory.path}/source.mov';
      final outputPath = '${directory.path}/normalized.mp4';
      await File(sourcePath).writeAsBytes([9, 8, 7]);
      final compressionStarted = Completer<void>();
      final pendingCompression = Completer<VideoResult>();
      final controller = EducationVideoPreparationController();
      final preparer = NativeEducationVideoPreparer(
        inspect: (path) async => _info(path, hasAudio: path == outputPath),
        compressVideo: (path, nativeController, onProgress) {
          compressionStarted.complete();
          return pendingCompression.future;
        },
      );

      final preparing = preparer.prepare(
        EducationPickedVideo(name: 'source.mov', path: sourcePath),
        controller: controller,
        onProgress: (_) {},
      );
      await compressionStarted.future;
      controller.cancel();
      await expectLater(
        preparing,
        throwsA(isA<EducationVideoPreparationCancelled>()),
      );
      await File(outputPath).writeAsBytes([1, 2, 3]);
      pendingCompression.complete(_result(outputPath));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(await File(outputPath).exists(), isFalse);
      expect(await File(sourcePath).readAsBytes(), [9, 8, 7]);
    },
  );

  test(
    'chunked output read can be cancelled without deleting source',
    () async {
      final sourcePath = '${directory.path}/source.mov';
      final outputPath = '${directory.path}/normalized.mp4';
      await File(sourcePath).writeAsBytes([9, 8, 7]);
      await File(outputPath).writeAsBytes(List<int>.filled(128 * 1024, 3));
      final controller = EducationVideoPreparationController();
      var chunks = 0;
      final preparer = NativeEducationVideoPreparer(
        inspect: (path) async => _info(path, hasAudio: path == outputPath),
        compressVideo:
            (path, nativeController, onProgress) async =>
                _result(outputPath, size: 128 * 1024),
        readChunk: (file, length) async {
          final chunk = await file.read(length);
          chunks++;
          if (chunks == 1) controller.cancel();
          return chunk;
        },
      );

      await expectLater(
        preparer.prepare(
          EducationPickedVideo(name: 'source.mov', path: sourcePath),
          controller: controller,
          onProgress: (_) {},
        ),
        throwsA(isA<EducationVideoPreparationCancelled>()),
      );
      expect(chunks, 1);
      expect(await File(outputPath).exists(), isFalse);
      expect(await File(sourcePath).readAsBytes(), [9, 8, 7]);
    },
  );
}

VideoResult _result(String path, {int size = 3, bool isOriginal = false}) =>
    VideoResult(
      path: path,
      size: size,
      originalSize: 128,
      width: 720,
      height: 1280,
      duration: const Duration(seconds: 30),
      isOriginal: isOriginal,
    );

MediaInfo _info(String path, {required bool hasAudio}) => MediaInfo(
  path: path,
  type: MediaType.video,
  size: 128,
  width: 720,
  height: 1280,
  duration: const Duration(seconds: 30),
  hasAudio: hasAudio,
);
