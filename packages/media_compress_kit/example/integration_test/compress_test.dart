import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:media_compress_kit/media_compress_kit.dart';
import 'package:media_compress_kit_example/exif.dart';
import 'package:media_compress_kit_example/sample_media.dart';

/// Runs the plugin on a real device or simulator, on media made there.
///
/// flutter test integration_test/compress_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late String photo;
  late String graphic;
  late String video;

  setUpAll(() async {
    photo = await SampleMedia.photo();
    graphic = await SampleMedia.graphic();
    // 1920x1080 stored sideways: a portrait video, as phones record them.
    video = await SampleMedia.video();
  });

  ExifSummary exifOf(String path) => readExif(File(path).readAsBytesSync());

  Matcher throwsError(MediaCompressError error) => throwsA(
    isA<MediaCompressException>().having((e) => e.error, 'error', error),
  );

  void expectRising(List<double> progress) {
    expect(progress.first, 0);
    expect(progress.last, 1);
    for (var i = 1; i < progress.length; i++) {
      expect(progress[i], greaterThan(progress[i - 1]));
    }
  }

  group('images', () {
    testWidgets('the sample photo has its EXIF block', (tester) async {
      final exif = exifOf(photo);
      expect(exif.make, 'media_compress_kit');
      expect(exif.orientation, 6);
      expect(exif.hasLocation, isTrue);
    });

    testWidgets('getInfo reads size and orientation', (tester) async {
      final info = await MediaCompress.getInfo(photo);
      expect(info.type, MediaType.image);
      expect((info.width, info.height), (3024, 4032));
      expect(info.rotation, 90);
      expect(info.mimeType, 'image/jpeg');
      expect(info.size, File(photo).lengthSync());
    });

    testWidgets('compresses upright, scaled down, without metadata', (
      tester,
    ) async {
      final result = await MediaCompress.compressImage(photo);
      expect(result.isOriginal, isFalse);
      expect((result.width, result.height), (1440, 1920));
      expect(result.size, lessThan(result.originalSize));
      expect(result.size, File(result.path).lengthSync());
      final info = await MediaCompress.getInfo(result.path);
      expect((info.width, info.height), (1440, 1920));
      expect(info.rotation, 0);
      final exif = exifOf(result.path);
      expect(exif.make, isNull);
      expect(exif.hasLocation, isFalse);
    });

    testWidgets('reports rising progress up to 1', (tester) async {
      final progress = <double>[];
      await MediaCompress.compressImage(
        photo,
        options: const ImageOptions(maxSizeKB: 60),
        onProgress: progress.add,
      );
      expect(progress.length, greaterThan(5));
      expectRising(progress);
    });

    testWidgets('cancel stops an image', (tester) async {
      final controller = CompressController();
      final future = MediaCompress.compressImage(
        photo,
        options: const ImageOptions(maxSizeKB: 20, maxWidth: null),
        controller: controller,
        onProgress: (p) {
          if (p > 0.5) controller.cancel();
        },
      );
      await expectLater(future, throwsError(MediaCompressError.cancelled));
    });

    testWidgets('keepWithoutLocation keeps the camera but not the GPS', (
      tester,
    ) async {
      final result = await MediaCompress.compressImage(
        photo,
        options: const ImageOptions(
          metadata: ImageMetadata.keepWithoutLocation,
        ),
      );
      final exif = exifOf(result.path);
      expect(exif.make, 'media_compress_kit');
      expect(exif.hasLocation, isFalse);
      expect(exif.orientation ?? 1, 1);
      final info = await MediaCompress.getInfo(result.path);
      expect((info.width, info.height), (1440, 1920));
    });

    testWidgets('keepAll keeps the GPS too', (tester) async {
      final result = await MediaCompress.compressImage(
        photo,
        options: const ImageOptions(metadata: ImageMetadata.keepAll),
      );
      final exif = exifOf(result.path);
      expect(exif.make, 'media_compress_kit');
      expect(exif.hasLocation, isTrue);
    });

    testWidgets('maxSizeKB fits the limit', (tester) async {
      final result = await MediaCompress.compressImage(
        photo,
        options: const ImageOptions(maxSizeKB: 120, maxWidth: null),
      );
      expect(result.size, lessThanOrEqualTo(120 * 1024));
      expect(result.width, greaterThan(500));
    });

    testWidgets('a tiny limit also scales down', (tester) async {
      final result = await MediaCompress.compressImage(
        photo,
        options: const ImageOptions(maxSizeKB: 20),
      );
      expect(result.size, lessThanOrEqualTo(20 * 1024));
      expect(result.height, lessThan(1920));
    });

    testWidgets('transparent PNG to JPEG and to PNG', (tester) async {
      final jpeg = await MediaCompress.compressImage(graphic);
      expect((jpeg.width, jpeg.height), (1600, 1600));
      expect((await MediaCompress.getInfo(jpeg.path)).mimeType, 'image/jpeg');
      final png = await MediaCompress.compressImage(
        graphic,
        options: const ImageOptions(format: ImageFormat.png, maxWidth: 800),
      );
      expect((png.width, png.height), (800, 800));
      expect((await MediaCompress.getInfo(png.path)).mimeType, 'image/png');
    });

    testWidgets('WebP on Android, HEIC on iOS', (tester) async {
      final native = Platform.isAndroid ? ImageFormat.webp : ImageFormat.heic;
      final other = Platform.isAndroid ? ImageFormat.heic : ImageFormat.webp;
      final result = await MediaCompress.compressImage(
        photo,
        options: ImageOptions(format: native),
      );
      expect(result.size, lessThan(result.originalSize));
      final info = await MediaCompress.getInfo(result.path);
      expect((info.width, info.height), (1440, 1920));
      await expectLater(
        MediaCompress.compressImage(
          photo,
          options: ImageOptions(format: other),
        ),
        throwsError(MediaCompressError.unsupported),
      );
    });

    testWidgets('returns the original when it already fits', (tester) async {
      final result = await MediaCompress.compressImage(
        photo,
        options: const ImageOptions(
          maxWidth: null,
          maxHeight: null,
          maxSizeKB: 100000,
          metadata: ImageMetadata.keepAll,
        ),
      );
      expect(result.isOriginal, isTrue);
      expect(result.path, photo);
    });

    testWidgets('estimateImage is near the real size', (tester) async {
      for (final options in const [
        ImageOptions(),
        ImageOptions(quality: 50, maxWidth: 1080, maxHeight: 1080),
        ImageOptions(format: ImageFormat.png, maxWidth: 800, maxHeight: 800),
      ]) {
        final estimate = await MediaCompress.estimateImage(
          photo,
          options: options,
        );
        final result = await MediaCompress.compressImage(
          photo,
          options: options,
        );
        expect(
          (estimate.width, estimate.height),
          (result.width, result.height),
        );
        expect(estimate.size, closeTo(result.size, result.size * 0.35));
      }
    });
  });

  group('videos', () {
    testWidgets('getInfo reads a portrait video', (tester) async {
      final info = await MediaCompress.getInfo(video);
      expect(info.type, MediaType.video);
      expect((info.width, info.height), (1080, 1920));
      expect(info.rotation, 90);
      expect(info.duration!.inMilliseconds, closeTo(6000, 300));
      expect(info.hasAudio, isTrue);
      expect(info.frameRate, closeTo(30, 2));
    });

    testWidgets('compresses to 720p portrait with progress', (tester) async {
      final progress = <double>[];
      final result = await MediaCompress.compressVideo(
        video,
        onProgress: progress.add,
      );
      expect(result.isOriginal, isFalse);
      expect((result.width, result.height), (720, 1280));
      expect(result.size, lessThan(result.originalSize));
      expect(progress.length, greaterThan(5));
      expectRising(progress);
      final info = await MediaCompress.getInfo(result.path);
      expect((info.width, info.height), (720, 1280));
      expect(info.hasAudio, isTrue);
      expect(info.duration!.inMilliseconds, closeTo(6000, 300));
      // The result decodes, to its last second.
      final frame = await MediaCompress.thumbnail(
        result.path,
        position: const Duration(milliseconds: 5500),
      );
      expect((frame.width, frame.height), (288, 512));
    });

    testWidgets('maxSizeMB fits the limit, with rising progress', (
      tester,
    ) async {
      final progress = <double>[];
      final result = await MediaCompress.compressVideo(
        video,
        options: const VideoOptions(maxSizeMB: 0.5),
        onProgress: progress.add,
      );
      expect(result.size, lessThanOrEqualTo(0.5 * 1024 * 1024));
      expect(result.size, greaterThan(0.25 * 1024 * 1024));
      expectRising(progress);
      final frame = await MediaCompress.thumbnail(result.path);
      expect(frame.height, greaterThan(frame.width));
    });

    testWidgets('trims, drops audio and lowers the frame rate', (tester) async {
      final result = await MediaCompress.compressVideo(
        video,
        options: const VideoOptions(
          start: Duration(seconds: 1),
          end: Duration(seconds: 3),
          includeAudio: false,
          frameRate: 15,
          quality: VideoQuality.low,
        ),
      );
      final info = await MediaCompress.getInfo(result.path);
      expect(info.duration!.inMilliseconds, closeTo(2000, 300));
      expect(info.hasAudio, isFalse);
      expect((info.width, info.height), (480, 854));
      if (info.frameRate != null) expect(info.frameRate, closeTo(15, 3));
    });

    testWidgets('HEVC', (tester) async {
      final result = await MediaCompress.compressVideo(
        video,
        options: const VideoOptions(codec: VideoCodec.hevc),
      );
      expect(result.size, lessThan(result.originalSize));
    });

    testWidgets('two videos at once', (tester) async {
      final results = await Future.wait([
        MediaCompress.compressVideo(video),
        MediaCompress.compressVideo(
          video,
          options: const VideoOptions(quality: VideoQuality.low),
        ),
      ]);
      expect(results[0].height, 1280);
      expect(results[1].height, 854);
    });

    testWidgets('cancel stops a video', (tester) async {
      final controller = CompressController();
      final future = MediaCompress.compressVideo(
        video,
        options: const VideoOptions(quality: VideoQuality.high),
        controller: controller,
        onProgress: (p) {
          if (p > 0.2) controller.cancel();
        },
      );
      await expectLater(future, throwsError(MediaCompressError.cancelled));
    });

    testWidgets('estimateVideo is near the real size', (tester) async {
      for (final options in const [
        VideoOptions(),
        VideoOptions(quality: VideoQuality.low, includeAudio: false),
      ]) {
        final estimate = await MediaCompress.estimateVideo(
          video,
          options: options,
        );
        final result = await MediaCompress.compressVideo(
          video,
          options: options,
        );
        expect(
          (estimate.width, estimate.height),
          (result.width, result.height),
        );
        expect(estimate.size, closeTo(result.size, result.size * 0.4));
      }
      final small = await MediaCompress.estimateVideo(
        video,
        options: const VideoOptions(maxSizeMB: 0.5),
      );
      expect(small.size, lessThanOrEqualTo(0.5 * 1024 * 1024));
    });

    testWidgets('thumbnail is upright', (tester) async {
      final thumbnail = await MediaCompress.thumbnail(
        video,
        position: const Duration(seconds: 2),
      );
      expect(thumbnail.height, 512);
      expect(thumbnail.width, closeTo(288, 2));
      final info = await MediaCompress.getInfo(thumbnail.path);
      expect(info.mimeType, 'image/jpeg');
    });
  });

  group('batch', () {
    testWidgets('compressAll does images and videos, in order', (tester) async {
      const missing = '/no/such/file.jpg';
      final progress = <double>[];
      final done = <String>[];
      final items = await MediaCompress.compressAll(
        [photo, video, missing, graphic],
        onProgress: progress.add,
        onItemDone: (item) => done.add(item.path),
      );
      expect(items.map((i) => i.path), [photo, video, missing, graphic]);
      expect(items[0].result, isA<ImageResult>());
      expect(items[1].result, isA<VideoResult>());
      expect(items[2].error?.error, MediaCompressError.fileNotFound);
      expect(items[3].isSuccess, isTrue);
      expect(done, hasLength(4));
      expectRising(progress);
    });

    testWidgets('an outputPath is a folder, with a file per input', (
      tester,
    ) async {
      final folder =
          '${Directory.systemTemp.path}/batch_${DateTime.now().microsecondsSinceEpoch}/out';
      String name(String path) => path.split('/').last.split('.').first;
      final items = await MediaCompress.compressAll(
        [photo, photo, graphic, video],
        imageOptions: ImageOptions(outputPath: folder),
        videoOptions: VideoOptions(outputPath: folder),
      );
      expect(items.every((i) => i.isSuccess), isTrue);
      // The same photo twice is compressed once: one file, one shared item.
      expect(identical(items[0], items[1]), isTrue);
      expect(Directory(folder).listSync(), hasLength(3));
      // Named after the input; different inputs with the same name get _1,
      // _2 and so on, in input order, instead of overwriting each other.
      final seen = <String, int>{};
      final expected = [
        for (final (input, ext) in [
          (photo, 'jpg'),
          (graphic, 'jpg'),
          (video, 'mp4'),
        ])
          switch (seen.update(name(input), (n) => n + 1, ifAbsent: () => 0)) {
            0 => '$folder/${name(input)}.$ext',
            final n => '$folder/${name(input)}_$n.$ext',
          },
      ];
      expect(items.skip(1).map((i) => i.result!.path), expected);
      for (final item in items) {
        expect(File(item.result!.path).lengthSync(), item.result!.size);
      }
      await Directory(folder).parent.delete(recursive: true);
    });

    testWidgets('cancelling a batch cancels what is left', (tester) async {
      final controller = CompressController();
      final items = await MediaCompress.compressAll(
        [video, video, video],
        concurrency: 1,
        controller: controller,
        onProgress: (p) {
          if (p > 0.1) controller.cancel();
        },
      );
      expect(
        items.every((i) => i.error?.error == MediaCompressError.cancelled),
        isTrue,
      );
    });
  });

  group('URLs', () {
    // A web server in the test app, serving the samples: no internet needed.
    late HttpServer server;
    late String base;

    setUpAll(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      base = 'http://127.0.0.1:${server.port}';
      server.listen((request) async {
        final response = request.response;
        final file = switch (request.uri.path) {
          '/photo.jpg' => photo,
          '/video.mp4' => video,
          '/video' => video, // No extension: the content type tells.
          _ => null,
        };
        if (file == null) {
          response.statusCode = 404;
        } else if (request.uri.path == '/video' &&
            request.headers.value('authorization') != 'Bearer token') {
          response.statusCode = 401;
        } else {
          if (request.uri.path == '/video') {
            response.headers.contentType = ContentType('video', 'mp4');
          }
          response.contentLength = File(file).lengthSync();
          await response.addStream(File(file).openRead());
        }
        await response.close();
      });
    });

    tearDownAll(() => server.close(force: true));

    testWidgets('compressImage and compressVideo take URLs', (tester) async {
      final image = await MediaCompress.compressImage('$base/photo.jpg');
      expect((image.width, image.height), (1440, 1920));
      expect(image.originalSize, File(photo).lengthSync());

      final progress = <double>[];
      final video = await MediaCompress.compressVideo(
        '$base/video.mp4',
        onProgress: progress.add,
      );
      expect((video.width, video.height), (720, 1280));
      expectRising(progress);
      expect(progress.any((p) => p > 0 && p < 0.4), isTrue);
    });

    testWidgets('headers, and an extension from the content type', (
      tester,
    ) async {
      await expectLater(
        MediaCompress.compressVideo('$base/video'),
        throwsError(MediaCompressError.network),
      );
      final video = await MediaCompress.compressVideo(
        '$base/video',
        headers: {'Authorization': 'Bearer token'},
      );
      expect(video.height, 1280);
    });

    testWidgets('getInfo, thumbnail and compressAll take URLs', (tester) async {
      final info = await MediaCompress.getInfo('$base/video.mp4');
      expect((info.width, info.height), (1080, 1920));
      expect(info.path, '$base/video.mp4');
      final thumbnail = await MediaCompress.thumbnail('$base/video.mp4');
      expect(thumbnail.height, 512);
      final items = await MediaCompress.compressAll([
        graphic,
        '$base/photo.jpg',
        '$base/missing.mp4',
      ]);
      expect(items[0].isSuccess, isTrue);
      expect(items[1].result, isA<ImageResult>());
      expect(items[2].error?.error, MediaCompressError.network);
    });
  });

  testWidgets('a missing file is fileNotFound', (tester) async {
    await expectLater(
      MediaCompress.compressImage('/no/such/file.jpg'),
      throwsError(MediaCompressError.fileNotFound),
    );
  });

  testWidgets('clearCache removes the results', (tester) async {
    final result = await MediaCompress.compressImage(photo);
    expect(File(result.path).existsSync(), isTrue);
    await MediaCompress.clearCache();
    expect(File(result.path).existsSync(), isFalse);
  });
}
