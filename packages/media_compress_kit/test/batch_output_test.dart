import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:media_compress_kit/media_compress_kit.dart';
import 'package:media_compress_kit/src/batch_output.dart';

void main() {
  test('baseName takes the last segment of paths, URLs and URIs', () {
    expect(baseName('/storage/DCIM/IMG_1234.HEIC'), 'IMG_1234');
    expect(baseName(r'C:\photos\beach.jpg'), 'beach');
    expect(baseName('https://a.com/v/clip.mp4?token=1'), 'clip');
    expect(baseName('https://a.com/files/123'), '123');
    expect(baseName('https://cdn.example.com/'), 'cdn_example_com');
    expect(baseName('content://media/external/images/media/42'), '42');
    expect(baseName('/x/my photo (1).jpg'), 'my_photo_1_');
    expect(baseName('/x/.hidden'), '_hidden');
    expect(baseName('https://a.com/%F0%9F%98%80.jpg'), 'file');
  });

  test('imageExtension', () {
    expect(imageExtension(ImageFormat.jpeg), 'jpg');
    expect(imageExtension(ImageFormat.webp), 'webp');
  });

  test('BatchOutputs never hands out a name twice or one that exists', () {
    final dir = Directory.systemTemp.createTempSync('mck_batch');
    addTearDown(() => dir.deleteSync(recursive: true));
    File('${dir.path}/taken.jpg').writeAsStringSync('x');

    final outputs = BatchOutputs();
    expect(
      outputs.claim(dir.path, '/a/photo.png', 'jpg'),
      '${dir.path}/photo.jpg',
    );
    expect(
      outputs.claim('${dir.path}/', '/b/photo.jpg', 'jpg'),
      '${dir.path}/photo_1.jpg',
    );
    expect(
      outputs.claim(dir.path, '/c/photo.mp4', 'mp4'),
      '${dir.path}/photo.mp4',
    );
    expect(
      outputs.claim(dir.path, 'https://x.com/taken.jpg', 'jpg'),
      '${dir.path}/taken_1.jpg',
    );
  });

  test(
    'ordinals number same-named inputs in order, whatever finishes first',
    () {
      expect(
        BatchOutputs.ordinals([
          '/a/beach.heic',
          '/x/cat.jpg',
          'https://e.com/beach.jpg',
          '/b/beach.mp4',
        ]),
        [0, 0, 1, 2],
      );
      final dir = Directory.systemTemp.createTempSync('mck_batch');
      addTearDown(() => dir.deleteSync(recursive: true));
      final outputs = BatchOutputs();
      // The second input finishes first, but still gets _1.
      expect(
        outputs.claim(dir.path, '/b/beach.jpg', 'jpg', ordinal: 1),
        '${dir.path}/beach_1.jpg',
      );
      expect(
        outputs.claim(dir.path, '/a/beach.heic', 'jpg'),
        '${dir.path}/beach.jpg',
      );
    },
  );

  test('the options copies keep every other option', () {
    const image = ImageOptions(
      quality: 55,
      maxWidth: 800,
      maxHeight: null,
      format: ImageFormat.png,
      maxSizeKB: 90,
      metadata: ImageMetadata.keepAll,
      allowLarger: true,
    );
    final i = imageOptionsWithOutput(image, '/o/a.png');
    expect(
      [
        i.quality,
        i.maxWidth,
        i.maxHeight,
        i.format,
        i.maxSizeKB,
        i.metadata,
        i.allowLarger,
        i.outputPath,
      ],
      [
        55,
        800,
        null,
        ImageFormat.png,
        90,
        ImageMetadata.keepAll,
        true,
        '/o/a.png',
      ],
    );

    const video = VideoOptions(
      quality: VideoQuality.low,
      resolution: 360,
      bitrate: 500000,
      maxSizeMB: 4,
      frameRate: 24,
      includeAudio: false,
      audioBitrate: 64000,
      start: Duration(seconds: 1),
      end: Duration(seconds: 3),
      codec: VideoCodec.hevc,
      allowLarger: true,
    );
    final v = videoOptionsWithOutput(video, '/o/a.mp4');
    expect(
      [
        v.quality,
        v.resolution,
        v.bitrate,
        v.maxSizeMB,
        v.frameRate,
        v.includeAudio,
        v.audioBitrate,
        v.start,
        v.end,
        v.codec,
        v.allowLarger,
        v.outputPath,
      ],
      [
        VideoQuality.low,
        360,
        500000,
        4,
        24,
        false,
        64000,
        const Duration(seconds: 1),
        const Duration(seconds: 3),
        VideoCodec.hevc,
        true,
        '/o/a.mp4',
      ],
    );
  });
}
