import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_compress_kit/media_compress_kit.dart';
import 'package:media_compress_kit/src/download.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // flutter_test answers every HTTP request with 400; this test needs real ones.
  setUpAll(() => HttpOverrides.global = null);

  late HttpServer server;
  late Directory cache;
  late String base;
  final body = List.generate(200000, (i) => i % 251);
  final compressed = <String>[];

  setUp(() async {
    cache = await Directory.systemTemp.createTemp('mck_test');
    compressed.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    base = 'http://127.0.0.1:${server.port}';
    server.listen((request) async {
      final response = request.response;
      switch (request.uri.path) {
        case '/photo.jpg':
          response.contentLength = body.length;
          // In chunks, so progress has steps.
          for (var i = 0; i < body.length; i += 20000) {
            response.add(body.sublist(i, i + 20000));
            await response.flush();
            // A pause, so the chunks don't arrive together.
            await Future<void>.delayed(const Duration(milliseconds: 5));
          }
        case '/private':
          if (request.headers.value('authorization') != 'Bearer secret') {
            response.statusCode = 401;
          } else {
            response.headers.contentType = ContentType('image', 'png');
            response.add(body);
          }
        case '/slow.mp4':
          response.contentLength = body.length;
          response.add(body.sublist(0, 1000));
          await response.flush();
          await Future<void>.delayed(const Duration(seconds: 5));
        default:
          response.statusCode = 404;
      }
      await response.close();
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('media_compress_kit'), (
          call,
        ) async {
          final args = call.arguments as Map<Object?, Object?>? ?? {};
          switch (call.method) {
            case 'cacheDirectory':
              return cache.path;
            case 'getInfo':
              final file = File(args['path']! as String);
              return {
                'type': 'image',
                'size': file.lengthSync(),
                'width': 4000,
                'height': 3000,
                'mimeType': 'image/png',
              };
            case 'compressImage':
              compressed.add(args['path']! as String);
              final out = File('${cache.path}/out.jpg')..writeAsBytesSync([1]);
              return {
                'path': out.path,
                'size': 1,
                'width': args['width'],
                'height': args['height'],
              };
          }
          throw MissingPluginException();
        });
  });

  tearDown(() async {
    await server.close(force: true);
    await cache.delete(recursive: true);
  });

  test('compressImage downloads a URL first, then deletes it', () async {
    final progress = <double>[];
    final result = await MediaCompress.compressImage(
      '$base/photo.jpg',
      onProgress: progress.add,
    );
    expect(result.originalSize, body.length);
    expect(compressed.single, endsWith('.jpg'));
    expect(File(compressed.single).existsSync(), isFalse);
    // The download fills the first 40%, in steps.
    expect(progress.where((p) => p > 0 && p <= 0.4).length, greaterThan(3));
    expect(progress.last, 1);
  });

  test('headers are sent; a refusal is a network error', () async {
    await expectLater(
      MediaCompress.compressImage('$base/private'),
      throwsA(
        isA<MediaCompressException>()
            .having((e) => e.error, 'error', MediaCompressError.network)
            .having((e) => e.message, 'message', contains('401')),
      ),
    );
    await MediaCompress.compressImage(
      '$base/private',
      headers: {'Authorization': 'Bearer secret'},
    );
    // No extension in the URL: it comes from the content type.
    expect(compressed.single, endsWith('.png'));
  });

  test('404 and no server are network errors', () async {
    Matcher network = throwsA(
      isA<MediaCompressException>().having(
        (e) => e.error,
        'error',
        MediaCompressError.network,
      ),
    );
    await expectLater(
      MediaCompress.compressImage('$base/missing.jpg'),
      network,
    );
    await expectLater(
      MediaCompress.compressImage('http://127.0.0.1:1/photo.jpg'),
      network,
    );
    // Short, readable messages.
    Future<String> messageOf(String url) =>
        MediaCompress.compressImage(url).then(
          (_) => '',
          onError: (Object e) => (e as MediaCompressException).message,
        );
    expect(
      await messageOf('$base/missing.jpg'),
      'HTTP 404 Not Found: $base/missing.jpg',
    );
    expect(
      await messageOf('http://127.0.0.1:1/photo.jpg'),
      startsWith("Couldn't connect to 127.0.0.1"),
    );
    expect(
      await messageOf('https://no-such-host.invalid/a.jpg'),
      "Couldn't find no-such-host.invalid. Check the address and the internet "
      'connection.',
    );
  });

  test('cancel stops a download', () async {
    final controller = CompressController();
    final future = MediaCompress.compressVideo(
      '$base/slow.mp4',
      controller: controller,
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await controller.cancel();
    await expectLater(
      future.timeout(const Duration(seconds: 2)),
      throwsA(
        isA<MediaCompressException>().having(
          (e) => e.error,
          'error',
          MediaCompressError.cancelled,
        ),
      ),
    );
    final downloads = Directory('${cache.path}/downloads');
    expect(downloads.existsSync() ? downloads.listSync() : const [], isEmpty);
  });

  test('getInfo on a URL reports the URL as the path', () async {
    final info = await MediaCompress.getInfo('$base/photo.jpg');
    expect(info.path, '$base/photo.jpg');
    expect(info.size, body.length);
  });

  test('estimates need a file', () async {
    await expectLater(
      MediaCompress.estimateImage('$base/photo.jpg'),
      throwsA(
        isA<MediaCompressException>().having(
          (e) => e.error,
          'error',
          MediaCompressError.invalidArgument,
        ),
      ),
    );
  });

  test('compressAll mixes files and URLs', () async {
    final local = File('${cache.path}/local.png')..writeAsBytesSync(body);
    final items = await MediaCompress.compressAll([
      local.path,
      '$base/photo.jpg',
      '$base/missing.jpg',
    ]);
    expect(items[0].isSuccess, isTrue);
    expect(items[1].isSuccess, isTrue);
    expect(items[2].error?.error, MediaCompressError.network);
  });

  test('the same URL twice is downloaded and compressed once', () async {
    final done = <BatchItem>[];
    final items = await MediaCompress.compressAll([
      '$base/photo.jpg',
      '$base/missing.jpg',
      '$base/photo.jpg',
    ], onItemDone: done.add);
    expect(compressed, hasLength(1));
    expect(items, hasLength(3));
    expect(items[0].isSuccess, isTrue);
    expect(identical(items[0], items[2]), isTrue);
    expect(items[1].error?.error, MediaCompressError.network);
    expect(done, hasLength(3));
  });

  test('a duplicate that fails fails for every entry', () async {
    final items = await MediaCompress.compressAll([
      '$base/missing.jpg',
      '$base/missing.jpg',
    ]);
    expect(
      items.map((i) => i.error?.error),
      everyElement(MediaCompressError.network),
    );
  });

  test('extensionFor reads the URL, then the content type', () {
    expect(
      extensionFor(Uri.parse('https://a.com/v/clip.MOV?x=1'), null),
      'mov',
    );
    expect(extensionFor(Uri.parse('https://a.com/v/123'), 'video/mp4'), 'mp4');
    expect(extensionFor(Uri.parse('https://a.com/'), 'image/heic'), 'heic');
    expect(extensionFor(Uri.parse('https://a.com/file'), null), 'bin');
  });
}
