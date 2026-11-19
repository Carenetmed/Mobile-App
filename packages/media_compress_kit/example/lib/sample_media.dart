import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:media_compress_kit/media_compress_kit.dart';

import 'exif.dart';

/// Test media made on the device, so the example and its tests need no real
/// photos or footage.
abstract final class SampleMedia {
  static const _channel = MethodChannel('sample_media');

  static Future<String> _path(String name) async {
    final dir = Directory('${Directory.systemTemp.path}/samples');
    await dir.create(recursive: true);
    return '${dir.path}/$name';
  }

  /// A video of animated shapes with a tone, stored [rotation] degrees
  /// sideways like a phone's portrait video. It takes [seconds] to make on
  /// Android, which draws it in real time.
  static Future<String> video({
    String name = 'sample.mp4',
    int width = 1920,
    int height = 1080,
    double seconds = 6,
    int fps = 30,
    int rotation = 90,
    bool audio = true,
    int bitrate = 12000000,
  }) async {
    final path = await _path(name);
    await _channel.invokeMethod<void>('makeVideo', {
      'path': path,
      'width': width,
      'height': height,
      'seconds': seconds,
      'fps': fps,
      'rotation': rotation,
      'audio': audio,
      'bitrate': bitrate,
    });
    return path;
  }

  /// A JPEG photo like a phone camera's: [width] x [height] stored pixels,
  /// EXIF orientation 6 (shown rotated 90 degrees, so it displays as
  /// portrait), and a camera make, model and GPS location.
  static Future<String> photo({
    String name = 'sample.jpg',
    int width = 4032,
    int height = 3024,
  }) async {
    // Draw upright, then store it turned a quarter left, as orientation 6
    // expects.
    final displayWidth = height;
    final displayHeight = width;
    final png = await _render(width, height, (canvas) {
      canvas.translate(0, displayWidth.toDouble());
      canvas.rotate(-math.pi / 2);
      _paintScene(
        canvas,
        Size(displayWidth.toDouble(), displayHeight.toDouble()),
        opaque: true,
      );
    });
    // The plugin turns the PNG into a JPEG; then the EXIF block goes in.
    final pngPath = await _path('photo_source.png');
    await File(pngPath).writeAsBytes(png);
    final jpeg = await MediaCompress.compressImage(
      pngPath,
      options: const ImageOptions(quality: 95, maxWidth: null, maxHeight: null),
    );
    final bytes = addExif(
      await File(jpeg.path).readAsBytes(),
      make: 'media_compress_kit',
      model: 'Sample camera',
      orientation: 6,
      location: (40.6892, -74.0445),
    );
    await File(jpeg.path).delete();
    await File(pngPath).delete();
    final path = await _path(name);
    await File(path).writeAsBytes(bytes);
    return path;
  }

  /// A PNG with a transparent background, like a logo or sticker.
  static Future<String> graphic({
    String name = 'sample.png',
    int size = 1600,
  }) async {
    final recorder = ui.PictureRecorder();
    _paintScene(
      Canvas(recorder),
      Size(size.toDouble(), size.toDouble()),
      opaque: false,
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final path = await _path(name);
    await File(path).writeAsBytes(png!.buffer.asUint8List());
    return path;
  }

  static Future<Uint8List> _render(
    int width,
    int height,
    void Function(Canvas canvas) paint,
  ) async {
    final recorder = ui.PictureRecorder();
    paint(Canvas(recorder));
    final image = await recorder.endRecording().toImage(width, height);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  static void _paintScene(Canvas canvas, Size size, {required bool opaque}) {
    final rect = Offset.zero & size;
    final unit = size.shortestSide;
    if (opaque) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B2A6B), Color(0xFF6B2A8E), Color(0xFFE0607E)],
          ).createShader(rect),
      );
    }
    final random = math.Random(7);
    for (var i = 0; i < 40; i++) {
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      canvas.drawCircle(
        center,
        unit * (0.03 + random.nextDouble() * 0.12),
        Paint()
          ..color = HSVColor.fromAHSV(
            0.85,
            random.nextDouble() * 360,
            0.7,
            1,
          ).toColor(),
      );
    }
    // Fine detail, as in a real photo, so the encoder has work to do.
    final grain = Paint()..color = const Color(0x22FFFFFF);
    for (var i = 0; i < 3000; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        unit * 0.003,
        grain,
      );
    }
    final text = TextPainter(
      text: TextSpan(
        text: '↑\nmedia_compress_kit',
        style: TextStyle(
          color: const Color(0xFFFFFFFF),
          fontSize: unit * 0.07,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    text.paint(
      canvas,
      Offset((size.width - text.width) / 2, size.height * 0.2),
    );
  }
}
