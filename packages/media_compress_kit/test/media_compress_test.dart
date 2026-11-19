import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_compress_kit/media_compress_kit.dart';

/// The platform side, faked: every method answers from [answers].
void fakePlatform(
  Map<String, Object? Function(Map<Object?, Object?>)> answers,
) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('media_compress_kit'), (
        call,
      ) async {
        final answer = answers[call.method];
        if (answer == null) throw MissingPluginException();
        return answer(call.arguments as Map<Object?, Object?>? ?? {});
      });
}

const _video = {
  'type': 'video',
  'size': 20 * 1024 * 1024,
  'width': 1080,
  'height': 1920,
  'rotation': 90,
  'durationMs': 10000,
  'frameRate': 30.0,
  'videoBitrate': 15000000,
  'audioBitrate': 128000,
  'hasAudio': true,
};

const _image = {
  'type': 'image',
  'size': 3 * 1024 * 1024,
  'width': 3024,
  'height': 4032,
  'mimeType': 'image/jpeg',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('estimateVideo is the bitrate times the length', () async {
    fakePlatform({'getInfo': (_) => _video});
    final estimate = await MediaCompress.estimateVideo('v.mp4');
    expect((estimate.width, estimate.height), (720, 1280));
    final bitrate = 720 * 1280 * 30 * 0.07 + 128000;
    expect(estimate.size, closeTo(bitrate * 10 / 8, bitrate * 10 / 8 * 0.02));
    expect(estimate.isOriginal, isFalse);
  });

  test('estimateVideo keeps a video that already fits', () async {
    fakePlatform({'getInfo': (_) => _video});
    final estimate = await MediaCompress.estimateVideo(
      'v.mp4',
      options: const VideoOptions(maxSizeMB: 30),
    );
    expect(estimate.isOriginal, isTrue);
    expect(estimate.size, 20 * 1024 * 1024);
  });

  test('estimateImage scales the sample up to the full size', () async {
    fakePlatform({
      'getInfo': (_) => _image,
      'estimateImage': (args) {
        expect((args['width'], args['height']), (1440, 1920));
        return {
          'samples': [
            [300 * 400, 4.0],
            [600 * 800, 3.0],
          ],
        };
      },
    });
    final estimate = await MediaCompress.estimateImage('p.jpg');
    expect((estimate.width, estimate.height), (1440, 1920));
    // 4 → 3 bits per pixel over 4× the pixels: about 0.81× per 4×.
    final bitsPerPixel = 3.0 * math.pow(600 * 800 / (1440 * 1920), 0.2075);
    expect(
      estimate.size,
      closeTo(bitsPerPixel * 1440 * 1920 / 8, 1440 * 1920 / 8 * 0.02),
    );
  });

  test('compressImage sends the size and maps progress', () async {
    late Map<Object?, Object?> sent;
    fakePlatform({
      'getInfo': (_) => _image,
      'compressImage': (args) {
        sent = args;
        return {
          'path': '/out.jpg',
          'size': 300000,
          'width': 1440,
          'height': 1920,
        };
      },
    });
    final progress = <double>[];
    final result = await MediaCompress.compressImage(
      'p.jpg',
      onProgress: progress.add,
    );
    expect((sent['width'], sent['height']), (1440, 1920));
    expect(sent['format'], 'jpeg');
    expect(sent['id'], isA<int>());
    expect(result.size, 300000);
    expect(result.originalSize, 3 * 1024 * 1024);
    expect(progress, [0, 0.05, 1]);
  });

  test('a cancelled controller stops before any work', () async {
    var calls = 0;
    fakePlatform({
      'getInfo': (_) {
        calls++;
        return _image;
      },
    });
    final controller = CompressController();
    await controller.cancel();
    await expectLater(
      MediaCompress.compressImage('p.jpg', controller: controller),
      throwsA(
        isA<MediaCompressException>().having(
          (e) => e.error,
          'error',
          MediaCompressError.cancelled,
        ),
      ),
    );
    expect(calls, 0);
  });

  test('platform errors become MediaCompressException', () async {
    fakePlatform({
      'getInfo': (_) =>
          throw PlatformException(code: 'FILE_NOT_FOUND', message: 'No file'),
    });
    await expectLater(
      MediaCompress.getInfo('x'),
      throwsA(
        isA<MediaCompressException>()
            .having((e) => e.error, 'error', MediaCompressError.fileNotFound)
            .having((e) => e.message, 'message', 'No file'),
      ),
    );
  });

  test('pick passes its options and returns the paths', () async {
    late Map<Object?, Object?> sent;
    fakePlatform({
      'pick': (args) {
        sent = args;
        return ['/a.jpg', '/b.mp4'];
      },
    });
    final paths = await MediaCompress.pick(multiple: true, maxItems: 5);
    expect(paths, ['/a.jpg', '/b.mp4']);
    expect(sent, {'type': 'any', 'multiple': true, 'maxItems': 5});

    fakePlatform({'pick': (_) => null});
    expect(await MediaCompress.pick(), isEmpty);
  });

  test('compressAll keeps the order and reports failures per file', () async {
    fakePlatform({
      'getInfo': (args) => args['path'] == 'missing.jpg'
          ? throw PlatformException(code: 'FILE_NOT_FOUND')
          : _image,
      'compressImage': (args) => {
        'path': '/out_${args['id']}.jpg',
        'size': 1000,
        'width': 1440,
        'height': 1920,
      },
    });
    final items = await MediaCompress.compressAll([
      'a.jpg',
      'missing.jpg',
      'b.jpg',
    ]);
    expect(items.map((i) => i.path), ['a.jpg', 'missing.jpg', 'b.jpg']);
    expect(items[0].isSuccess, isTrue);
    expect(items[1].error?.error, MediaCompressError.fileNotFound);
    expect(items[2].isSuccess, isTrue);
  });
}
