import 'package:flutter_test/flutter_test.dart';
import 'package:media_compress_kit/media_compress_kit.dart';
import 'package:media_compress_kit/src/planner.dart';

MediaInfo video({
  int width = 1920,
  int height = 1080,
  int size = 50 * 1024 * 1024,
  Duration duration = const Duration(seconds: 60),
  double? frameRate = 30,
  int? videoBitrate = 16000000,
  int? audioBitrate = 128000,
  bool hasAudio = true,
}) => MediaInfo(
  path: 'v.mp4',
  type: MediaType.video,
  size: size,
  width: width,
  height: height,
  duration: duration,
  frameRate: frameRate,
  videoBitrate: videoBitrate,
  audioBitrate: audioBitrate,
  hasAudio: hasAudio,
);

void main() {
  group('fitInside', () {
    test('keeps images that fit', () {
      expect(fitInside(800, 600, maxWidth: 1920, maxHeight: 1920), (
        width: 800,
        height: 600,
      ));
    });

    test('scales down by the tighter side, keeping the aspect ratio', () {
      expect(fitInside(4000, 3000, maxWidth: 1920, maxHeight: 1920), (
        width: 1920,
        height: 1440,
      ));
      expect(fitInside(3000, 4000, maxWidth: 1920, maxHeight: 1920), (
        width: 1440,
        height: 1920,
      ));
      expect(fitInside(4000, 1000, maxWidth: 1000, maxHeight: 100), (
        width: 400,
        height: 100,
      ));
    });

    test('a null limit means no limit on that side', () {
      expect(fitInside(4000, 3000, maxWidth: 1000), (width: 1000, height: 750));
      expect(fitInside(4000, 3000), (width: 4000, height: 3000));
    });
  });

  test('isFormat matches MIME types', () {
    expect(isFormat('image/jpeg', ImageFormat.jpeg), isTrue);
    expect(isFormat('image/png', ImageFormat.jpeg), isFalse);
    expect(isFormat('image/heif', ImageFormat.heic), isTrue);
    expect(isFormat(null, ImageFormat.webp), isFalse);
  });

  group('planVideo', () {
    test('the medium preset makes 720p with an even, scaled size', () {
      final plan = planVideo(video(), const VideoOptions());
      expect((plan.width, plan.height), (1280, 720));
      expect(plan.videoBitrate, (1280 * 720 * 30 * 0.07).round());
      expect(plan.includeAudio, isTrue);
      expect(plan.frameRate, isNull);
    });

    test('portrait videos scale by their width', () {
      final plan = planVideo(
        video(width: 1080, height: 1920),
        const VideoOptions(),
      );
      expect((plan.width, plan.height), (720, 1280));
    });

    test('never scales up', () {
      final plan = planVideo(
        video(width: 640, height: 360),
        const VideoOptions(quality: VideoQuality.high),
      );
      expect((plan.width, plan.height), (640, 360));
    });

    test('odd sizes round to even numbers', () {
      final plan = planVideo(
        video(width: 1918, height: 1078),
        const VideoOptions(resolution: 721),
      );
      expect(plan.width.isEven && plan.height.isEven, isTrue);
    });

    test('the bitrate stays below the original', () {
      final plan = planVideo(
        video(videoBitrate: 1000000),
        const VideoOptions(quality: VideoQuality.high),
      );
      expect(plan.videoBitrate, 900000);
    });

    test('an explicit bitrate wins over the preset', () {
      final plan = planVideo(video(), const VideoOptions(bitrate: 3000000));
      expect(plan.videoBitrate, 3000000);
    });

    test('maxSizeMB lowers the bitrate to fit the duration', () {
      final plan = planVideo(video(), const VideoOptions(maxSizeMB: 10));
      final bits =
          (plan.videoBitrate + 128000) * 60; // 60 seconds of video + audio
      expect(bits / 8, lessThanOrEqualTo(10 * 1024 * 1024));
      expect(bits / 8, greaterThan(9 * 1024 * 1024));
    });

    test('maxSizeMB lowers the resolution when the bitrate gets too low', () {
      final plan = planVideo(
        video(duration: const Duration(minutes: 10)),
        const VideoOptions(maxSizeMB: 16),
      );
      expect(plan.height, lessThan(720));
      expect(
        plan.videoBitrate / (plan.width * plan.height * 30),
        greaterThan(0.03),
      );
    });

    test('maxSizeMB keeps an explicit resolution', () {
      final plan = planVideo(
        video(duration: const Duration(minutes: 10)),
        const VideoOptions(maxSizeMB: 16, resolution: 720),
      );
      expect(plan.height, 720);
    });

    test('the bitrate never drops below the minimum', () {
      final plan = planVideo(
        video(duration: const Duration(hours: 2)),
        const VideoOptions(maxSizeMB: 1),
      );
      expect(plan.videoBitrate, minVideoBitrate);
    });

    test('budgets for the bigger audio bitrate', () {
      final plan = planVideo(
        video(audioBitrate: 320000),
        const VideoOptions(maxSizeMB: 10),
      );
      final bits = (plan.videoBitrate + 320000) * 60;
      expect(bits / 8, lessThanOrEqualTo(10 * 1024 * 1024));
    });

    test('no audio budget without audio', () {
      final withAudio = planVideo(video(), const VideoOptions(maxSizeMB: 10));
      final without = planVideo(
        video(),
        const VideoOptions(maxSizeMB: 10, includeAudio: false),
      );
      expect(without.includeAudio, isFalse);
      expect(without.videoBitrate, greaterThan(withAudio.videoBitrate));
    });

    test('requested audio remains in the output plan for silent sources', () {
      final source = video(hasAudio: false, audioBitrate: null);
      final plan = planVideo(
        source,
        const VideoOptions(maxSizeMB: 10, includeAudio: true),
      );

      expect(plan.includeAudio, isTrue);
      expect(
        videoAlreadyFits(source, const VideoOptions(maxSizeMB: 10)),
        isFalse,
      );
    });

    test('trimming shortens the duration the size limit is spread over', () {
      final plan = planVideo(
        video(),
        const VideoOptions(
          start: Duration(seconds: 10),
          end: Duration(seconds: 20),
          maxSizeMB: 2,
        ),
      );
      expect(plan.duration, const Duration(seconds: 10));
      expect(plan.start, const Duration(seconds: 10));
      expect(plan.end, const Duration(seconds: 20));
      expect(
        (plan.videoBitrate + 128000) * 10 / 8,
        lessThanOrEqualTo(2 * 1024 * 1024),
      );
    });

    test('a trim past the end is dropped', () {
      final plan = planVideo(
        video(),
        const VideoOptions(end: Duration(minutes: 5)),
      );
      expect(plan.end, isNull);
      expect(plan.duration, const Duration(seconds: 60));
    });

    test('a start after the end is an error', () {
      expect(
        () => planVideo(
          video(),
          const VideoOptions(
            start: Duration(seconds: 30),
            end: Duration(seconds: 10),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('frameRate only lowers the frame rate', () {
      expect(
        planVideo(
          video(frameRate: 60),
          const VideoOptions(frameRate: 30),
        ).frameRate,
        30,
      );
      expect(
        planVideo(
          video(frameRate: 30),
          const VideoOptions(frameRate: 60),
        ).frameRate,
        isNull,
      );
    });
  });

  group('estimateBitsPerPixel', () {
    test('extends the trend between two samples', () {
      final bits = estimateBitsPerPixel([
        (pixels: 1000, bitsPerPixel: 4),
        (pixels: 4000, bitsPerPixel: 2),
      ], 16000);
      expect(bits, closeTo(1, 0.001)); // halves for every 4× the pixels
    });

    test('uses the larger sample for small images', () {
      expect(
        estimateBitsPerPixel([
          (pixels: 1000, bitsPerPixel: 4),
          (pixels: 4000, bitsPerPixel: 2),
        ], 3000),
        2,
      );
    });

    test('a rising trend is ignored', () {
      expect(
        estimateBitsPerPixel([
          (pixels: 1000, bitsPerPixel: 1),
          (pixels: 4000, bitsPerPixel: 2),
        ], 16000),
        2,
      );
    });
  });

  group('shrinkPlan', () {
    const plan = VideoPlan(
      width: 720,
      height: 1280,
      videoBitrate: 1000000,
      audioBitrate: 128000,
      includeAudio: true,
      duration: Duration(seconds: 10),
    );
    const mb = 1024 * 1024;

    test('lowers only the bitrate after a small miss', () {
      // 1.2 Mbps of video instead of 1 Mbps.
      final next = shrinkPlan(plan, (1328000 * 10) ~/ 8, 1.2 * mb)!;
      expect((next.width, next.height), (720, 1280));
      expect(next.videoBitrate, lessThan(plan.videoBitrate));
    });

    test('lowers the resolution when the encoder ignored the bitrate', () {
      // 3 Mbps of video instead of 1 Mbps.
      final next = shrinkPlan(plan, (3128000 * 10) ~/ 8, 1.2 * mb)!;
      expect(next.width, lessThan(720));
      expect(next.width.isEven && next.height.isEven, isTrue);
      expect(next.width / next.height, closeTo(720 / 1280, 0.01));
    });

    test('null when the result already fits or nothing is left to cut', () {
      expect(shrinkPlan(plan, mb, 2.0 * mb), isNull);
      expect(shrinkPlan(plan, 10 * mb, 0.1 * mb), isNull);
    });
  });

  group('videoAlreadyFits', () {
    test('a small enough video is kept', () {
      expect(
        videoAlreadyFits(
          video(size: 5 << 20),
          const VideoOptions(maxSizeMB: 8),
        ),
        isTrue,
      );
    });

    test('not without a size limit', () {
      expect(videoAlreadyFits(video(size: 1), const VideoOptions()), isFalse);
    });

    test('not when trimmed, muted, too big or too fast', () {
      final small = video(size: 5 << 20, frameRate: 60);
      const limit = 8.0;
      expect(
        videoAlreadyFits(
          small,
          const VideoOptions(maxSizeMB: limit, start: Duration(seconds: 1)),
        ),
        isFalse,
      );
      expect(
        videoAlreadyFits(
          small,
          const VideoOptions(maxSizeMB: limit, includeAudio: false),
        ),
        isFalse,
      );
      expect(
        videoAlreadyFits(
          small,
          const VideoOptions(maxSizeMB: limit, resolution: 720),
        ),
        isFalse,
      );
      expect(
        videoAlreadyFits(
          small,
          const VideoOptions(maxSizeMB: limit, frameRate: 30),
        ),
        isFalse,
      );
    });
  });

  test('MediaInfo.fromMap reads the platform map', () {
    final info = MediaInfo.fromMap('a.mp4', {
      'type': 'video',
      'size': 1000,
      'width': 1080,
      'height': 1920,
      'rotation': 90,
      'durationMs': 5000,
      'frameRate': 29.97,
      'bitrate': 0,
      'hasAudio': true,
    });
    expect(info.type, MediaType.video);
    expect(info.isPortrait, isTrue);
    expect(info.duration, const Duration(seconds: 5));
    expect(info.bitrate, isNull); // 0 means unknown
    expect(info.frameRate, closeTo(29.97, 0.001));
  });
}
