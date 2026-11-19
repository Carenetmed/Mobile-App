<h1 align="center">media_compress_kit</h1>

<p align="center">
  <b>Compress images and videos in Flutter with the phone's own encoders.</b><br>
  Size limits · progress · cancel · batch · URLs · size estimates · system picker · no permissions
</p>

<p align="center">
  <a href="https://pub.dev/packages/media_compress_kit"><img src="https://img.shields.io/pub/v/media_compress_kit.svg" alt="pub package"></a>
  <a href="https://github.com/parthbhensdadiya226/media_compress_kit/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20iOS-4F46E5.svg" alt="Android and iOS">
  <img src="https://img.shields.io/badge/dependencies-none-brightgreen.svg" alt="No dependencies">
</p>

<table align="center">
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/parthbhensdadiya226/media_compress_kit/main/doc/video_result.png" width="190" alt="A portrait video compressed to half its size"></td>
    <td align="center"><img src="https://raw.githubusercontent.com/parthbhensdadiya226/media_compress_kit/main/doc/video_progress.png" width="190" alt="Compression progress with a cancel button"></td>
    <td align="center"><img src="https://raw.githubusercontent.com/parthbhensdadiya226/media_compress_kit/main/doc/image_result.png" width="190" alt="A 12 megapixel photo compressed and turned upright, with a size estimate"></td>
    <td align="center"><img src="https://raw.githubusercontent.com/parthbhensdadiya226/media_compress_kit/main/doc/batch.png" width="190" alt="Photos and a video compressed together"></td>
  </tr>
  <tr>
    <td align="center"><b>Video</b></td>
    <td align="center"><b>Progress and cancel</b></td>
    <td align="center"><b>Image and estimate</b></td>
    <td align="center"><b>Batch</b></td>
  </tr>
</table>

It uses **Media3 Transformer** on Android and **AVFoundation** with **ImageIO** on iOS: hardware-accelerated, already on every phone, and with no FFmpeg, so it adds far less to your app than an FFmpeg build and raises no GPL licensing questions. The Dart side has no dependencies at all.

## ✨ Highlights

| | |
|---|---|
| 🎯 **Fits a size limit** | `maxSizeMB: 16` for a chat app, `maxSizeKB: 200` for an avatar. It works out the bitrate, resolution or quality, and compresses again if an encoder overshoots. |
| 📊 **Progress for everything** | `onProgress` from 0 to 1 for images, videos and whole batches. It only goes up, even across extra passes. |
| ✋ **Cancel anything** | One `CompressController` cancels an image, a video or a batch, and deletes the partial file. |
| 🧮 **Estimates before compressing** | `estimateImage` and `estimateVideo` predict the result's size and dimensions, so you can show "≈ 1.7 MB" next to each choice. |
| 📚 **Batch** | `compressAll` does a list of photos and videos two at a time, with one overall progress. |
| 🌐 **URLs too** | Pass an `https://` link instead of a path: it's downloaded with progress, cancel and headers, then compressed. |
| 🖼️ **System picker, no permissions** | `pick()` opens Android's Photo Picker or iOS's `PHPicker`. No storage or photo permission, no extra package. |
| 🔄 **Right way up** | Portrait videos stay portrait, and photos are turned upright from their EXIF orientation. |
| 📉 **Never bigger** | If compressing wouldn't make a file smaller, you get the original back with `isOriginal: true`. |
| 🔒 **Private by default** | Photo metadata, including the GPS location, is removed unless you ask to keep it. |
| 🎛️ **Full control** | Bitrate, resolution, frame rate, H.264 or HEVC, trimming, audio, JPEG, PNG, WebP or HEIC. |

## 📑 Contents

- [Getting started](#-getting-started)
- [Files from anywhere](#-files-from-anywhere)
- [Network files (URLs)](#-network-files-urls)
- [All methods at a glance](#-all-methods-at-a-glance)
- [compressImage](#-compressimage)
- [compressVideo](#-compressvideo)
- [compressAll](#-compressall) ([what you get back](#what-you-get-back-one-file-vs-many))
- [estimateImage and estimateVideo](#-estimateimage-and-estimatevideo)
- [pick](#-pick)
- [getInfo](#-getinfo)
- [thumbnail](#-thumbnail)
- [clearCache](#-clearcache)
- [CompressController](#-compresscontroller)
- [Results](#-results)
- [A progress bar with cancel](#-a-progress-bar-with-cancel)
- [How size limits work](#-how-size-limits-work)
- [Errors](#️-errors)
- [Platforms](#-platforms)
- [Testing](#-testing)
- [Example app](#-example)
- [Support](#-support)

## 🚀 Getting started

```yaml
dependencies:
  media_compress_kit: ^0.1.0
```

No setup and no permissions are needed for files on the device. Android needs `minSdk` 24 or higher, iOS needs 15 or higher. To compress **links** in an Android release build, add the internet permission (see [Network files](#-network-files-urls)).

```dart
import 'package:media_compress_kit/media_compress_kit.dart';

// Let the user pick a video, then compress it to fit 16 MB.
final paths = await MediaCompress.pick(type: PickType.video);
if (paths.isEmpty) return; // Cancelled.

final video = await MediaCompress.compressVideo(
  paths.first,
  options: const VideoOptions(maxSizeMB: 16),
  onProgress: (p) => print('${(p * 100).round()}%'),
);
print('${video.originalSize} → ${video.size} bytes: ${video.path}');
```

You don't have to use `pick()`: see [Files from anywhere](#-files-from-anywhere).

## 📂 Files from anywhere

Every method takes a plain path, so files can come from any picker, the camera, a download, or the app's own folders. `pick()` is only a convenience.

```dart
// image_picker
final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
final result = await MediaCompress.compressVideo(video!.path);

// file_picker
final picked = await FilePicker.platform.pickFiles(type: FileType.image);
final image = await MediaCompress.compressImage(picked!.files.single.path!);

// Several at once, photos and videos mixed, from anywhere
final media = await ImagePicker().pickMultipleMedia();
final items = await MediaCompress.compressAll([
  ...media.map((f) => f.path),
  cameraPhotoPath,
  downloadedVideoPath,
]);
```

`compressAll` reads each file and sends photos to image compression and videos to video compression, so a mixed list needs no sorting.

| Input | Android | iOS |
|---|---|---|
| File path | ✅ | ✅ |
| `file://` URL | ✅ | ✅ |
| `https://` or `http://` URL | ✅ Downloaded first, see [Network files](#-network-files-urls). | ✅ Downloaded first. |
| `content://` URI (Android pickers and share sheets) | ✅ | |
| Photos asset ID (`ph://...`) | | ❌ Use a file: pickers already give one. |
| Bytes in memory (`Uint8List`) | ❌ Write them to a file first. | ❌ Write them to a file first. |

On iOS, `image_picker` may convert videos to H.264 at a lower quality before handing them over. To compress the original, use `pick()`, which copies files unchanged, or set `image_picker`'s own quality option.

## 🌐 Network files (URLs)

Every compress method also takes a web address. The file is downloaded into the cache, compressed, and the download deleted, all in one call:

```dart
final result = await MediaCompress.compressVideo(
  'https://example.com/videos/clip.mp4',
  options: const VideoOptions(maxSizeMB: 16),
  onProgress: (p) => setState(() => progress = p),
);
```

- **One progress bar for both steps:** the download fills the first 40%, compressing the rest.
- **Cancel** with the same `CompressController`, while downloading or while compressing.
- **Private files:** send headers, such as a login token.

  ```dart
  await MediaCompress.compressImage(
    'https://api.example.com/files/123',
    headers: {'Authorization': 'Bearer $token'},
  );
  ```

- **Mixed batches:** `compressAll` takes files and URLs in one list, with `headers` for all of its URLs.
- **`getInfo` and `thumbnail`** take URLs too: the file is downloaded, read, and deleted.
- **Errors:** no connection, a timeout (30 seconds to connect) or an HTTP error such as 401 or 404 throws `MediaCompressError.network`, with the status in the `message`.
- Redirects are followed. A link without a file extension is fine: the type comes from the server's `Content-Type`.
- If the original already fits (`isOriginal` is true), `path` is the downloaded copy in the cache, not the URL.

> **Android release builds** need the internet permission in `android/app/src/main/AndroidManifest.xml` (debug builds get it automatically, so links can work in debug and fail in release without it):
>
> ```xml
> <uses-permission android:name="android.permission.INTERNET"/>
> ```
>
> Plain `http://` links are also blocked by default on Android 9+ and iOS; use `https://` or allow cleartext for your server.

Downloading uses Dart's own `HttpClient`, so there is still no dependency. Size estimates need the file on the device, so `estimateImage` and `estimateVideo` don't take URLs.

## 🧭 All methods at a glance

| Method | What it does |
|---|---|
| [`compressImage(path)`](#-compressimage) | Compresses a photo: upright, scaled, re-encoded, metadata removed. Takes a path or a URL. |
| [`compressVideo(path)`](#-compressvideo) | Compresses a video to an `.mp4`. Takes a path or a URL. |
| [`compressAll(paths)`](#-compressall) | Compresses a list of photos and videos, files and URLs mixed, a few at a time. |
| [`estimateImage(path)`](#-estimateimage-and-estimatevideo) | Predicts `compressImage`'s result size in a fraction of the time. |
| [`estimateVideo(path)`](#-estimateimage-and-estimatevideo) | Predicts `compressVideo`'s result size instantly. |
| [`pick()`](#-pick) | Opens the system photo and video picker, with no permission. |
| [`getInfo(path)`](#-getinfo) | Reads type, size, dimensions, rotation, duration, frame rate and bitrates. |
| [`thumbnail(path)`](#-thumbnail) | Saves a frame of a video as a JPEG. |
| [`clearCache()`](#-clearcache) | Deletes the files this package wrote to the cache. |
| [`CompressController`](#-compresscontroller) | Cancels compressions. |

All methods are static on `MediaCompress`.

## 🖼️ compressImage

```dart
Future<ImageResult> MediaCompress.compressImage(
  String path, {
  ImageOptions options = const ImageOptions(),
  void Function(double progress)? onProgress,
  CompressController? controller,
  Map<String, String>? headers, // for URLs
})
```

Turns the photo upright, scales it down to fit, encodes it, and returns the new file. Any image the phone can decode works, including HEIC from iPhones and from Android 9 and later.

```dart
final result = await MediaCompress.compressImage(
  path,
  options: const ImageOptions(
    quality: 80,
    maxWidth: 1920,
    maxHeight: 1920,
    format: ImageFormat.jpeg,
    maxSizeKB: 300,
    metadata: ImageMetadata.removeAll,
  ),
  onProgress: (p) => setState(() => progress = p),
);
```

**`ImageOptions`**

| Option | Default | Description |
|---|---|---|
| `quality` | `80` | Encoder quality from 1 to 100. Ignored for PNG. |
| `maxWidth` / `maxHeight` | `1920` | Scales down to fit inside, keeping the aspect ratio. Never scales up. `null` means no limit. |
| `format` | `ImageFormat.jpeg` | `jpeg`, `png`, `webp` (Android only) or `heic` (iOS only). |
| `maxSizeKB` | none | Lowers the quality until it fits; if even a low quality is too big, scales down too. |
| `metadata` | `ImageMetadata.removeAll` | `removeAll`, `keepWithoutLocation` (camera, date and so on, but no GPS), or `keepAll`. |
| `outputPath` | cache | The file to write. In `compressAll`, a folder (see [compressAll](#-compressall)). |
| `allowLarger` | `false` | Keep the result even when it's bigger than the original. |

**Returns** one `ImageResult` (see [Results](#-results)). **Throws** a `MediaCompressException` if it fails (see [Errors](#️-errors)); passing a video throws `unsupported`.

Progress moves through reading, decoding, scaling, each encode (several when fitting `maxSizeKB`) and saving. Transparent areas become white in JPEG. The original comes back instead of a copy only when it already matches what you asked for (format, size, and `metadata: keepAll`); otherwise it would still carry the metadata you asked to remove.

## 🎬 compressVideo

```dart
Future<VideoResult> MediaCompress.compressVideo(
  String path, {
  VideoOptions options = const VideoOptions(),
  void Function(double progress)? onProgress,
  CompressController? controller,
  Map<String, String>? headers, // for URLs
})
```

Compresses a video to an `.mp4`. Portrait videos stay portrait, and several videos can be compressed at once.

```dart
final controller = CompressController();

final result = await MediaCompress.compressVideo(
  path,
  options: const VideoOptions(
    quality: VideoQuality.medium, // 720p
    maxSizeMB: 16,
    codec: VideoCodec.h264,
  ),
  onProgress: (p) => setState(() => progress = p),
  controller: controller, // controller.cancel() stops it
);
print('${result.width}x${result.height}, ${result.duration}');
```

**`VideoOptions`**

| Option | Default | Description |
|---|---|---|
| `quality` | `VideoQuality.medium` | `low` (480p), `medium` (720p) or `high` (1080p), each with a bitrate to match. |
| `resolution` | from `quality` | The short side in pixels: `720` makes a portrait video 720 wide. Never scales up. |
| `bitrate` | from `quality` | Video bits per second. Never above the original's. |
| `maxSizeMB` | none | A size the result must fit. See [how size limits work](#-how-size-limits-work). |
| `frameRate` | original | Drops frames to reach it, e.g. `30`. Never raises it. |
| `includeAudio` | `true` | `false` removes the audio track. |
| `audioBitrate` | `128000` | Used when the audio is re-encoded. |
| `start` / `end` | whole video | Trims to this part. |
| `codec` | `VideoCodec.h264` | `hevc` is 30-40% smaller but plays on fewer devices. Falls back to H.264 where there's no HEVC encoder. |
| `outputPath` | cache | The `.mp4` file to write. In `compressAll`, a folder (see [compressAll](#-compressall)). |
| `allowLarger` | `false` | Keep the result even when it's bigger than the original. |

**Returns** one `VideoResult` (see [Results](#-results)). **Throws** a `MediaCompressException` if it fails (see [Errors](#️-errors)); passing an image throws `unsupported`.

Videos recorded in HDR, as recent phones do by default, are converted to standard dynamic range, so they look right in every player and app.

## 📚 compressAll

```dart
Future<List<BatchItem>> MediaCompress.compressAll(
  List<String> paths, {
  ImageOptions imageOptions = const ImageOptions(),
  VideoOptions videoOptions = const VideoOptions(),
  int concurrency = 2,
  void Function(double progress)? onProgress,
  void Function(BatchItem item)? onItemDone,
  CompressController? controller,
  Map<String, String>? headers, // for URLs
})
```

Compresses photos and videos together, `concurrency` at a time, and returns one `BatchItem` per path in the same order. A file that fails doesn't stop the others.

```dart
final paths = await MediaCompress.pick(multiple: true, maxItems: 10);

final items = await MediaCompress.compressAll(
  paths,
  imageOptions: const ImageOptions(maxSizeKB: 500),
  videoOptions: const VideoOptions(maxSizeMB: 16),
  onProgress: (p) => setState(() => progress = p), // the whole batch
  onItemDone: (item) => print('${item.path} done'),
);

for (final item in items) {
  if (item.isSuccess) {
    upload(item.result!.path);
  } else {
    print('${item.path}: ${item.error!.message}');
  }
}
```

- **Options:** every photo uses `imageOptions` and every video `videoOptions`. The type is read from each file, so the list needs no sorting.
- **`concurrency`:** how many files compress at the same time. `2` keeps the phone responsive; `1` does them one by one.
- **Progress:** the overall progress weighs each file by its size, so a big video moves the bar more than a small photo.
- **Cancel:** cancelling the controller cancels what's running and what's still waiting.
- **Output folder:** in a batch, `outputPath` is a **folder**. Each result is written into it, named after its input, and nothing is overwritten:

  ```dart
  final items = await MediaCompress.compressAll(
    ['/a/beach.heic', '/b/beach.jpg', 'https://example.com/v/clip.mp4'],
    imageOptions: ImageOptions(outputPath: '${dir.path}/compressed'),
    videoOptions: VideoOptions(outputPath: '${dir.path}/compressed'),
  );
  // compressed/beach.jpg, compressed/beach_1.jpg, compressed/clip.mp4
  ```

  - The extension follows the format: `.jpg`, `.png`, `.webp` or `.heic` for photos, `.mp4` for videos.
  - Inputs with the same name are numbered in input order: the first keeps the name, the next get `_1`, `_2` and so on (`beach.jpg` and `beach.mp4` become `beach.jpg` and `beach_1.mp4`).
  - A name already used by a file in the folder also gets the next number, so existing files are never overwritten.
  - The folder is created if it doesn't exist. Photos and videos can share one folder or use two.
  - A file returned as is (`isOriginal`) isn't copied into the folder; its `path` stays the original.
  - Without `outputPath`, each result gets a new file in the cache.
- An empty list returns an empty list.
- **Duplicates are done once:** the same path or URL more than once is compressed (and downloaded) only once. You still get one `BatchItem` per entry, in order, but the duplicates share the same item, with the same result file, and `onItemDone` is called for each. So don't delete that file after uploading the first entry if you still need it for the others. Only identical strings count: a `content://` URI and a file path for the same photo are two inputs.

### What you get back: one file vs. many

| | `compressImage` / `compressVideo` | `compressAll` |
|---|---|---|
| **Returns** | One `ImageResult` / `VideoResult` | `List<BatchItem>`, one per input, **in the same order** |
| **When something fails** | Throws a `MediaCompressException` | **Never throws.** The other files keep going; the failed one's item has `error` |
| **When cancelled** | Throws with `MediaCompressError.cancelled` | Finished items keep their results; the rest get `error` with `cancelled` |

Each `BatchItem` says which input it is and what happened:

| Field | On success | On failure |
|---|---|---|
| `path` | The path or URL you passed in | The path or URL you passed in |
| `isSuccess` | `true` | `false` |
| `result` | An `ImageResult` or `VideoResult` | `null` |
| `error` | `null` | A `MediaCompressException`: `error.error` is the kind (`network`, `fileNotFound`, `unsupported`, `failed`, `cancelled`), `error.message` the reason, e.g. `HTTP 404` |

```dart
final items = await MediaCompress.compressAll([
  '/path/photo.jpg',
  'https://example.com/clip.mp4',
  'https://example.com/missing.jpg', // fails with network, the others still finish
]);

final done = items.where((i) => i.isSuccess).toList();
final failed = items.where((i) => !i.isSuccess).toList();

for (final item in failed) {
  print('${item.path} failed (${item.error!.error.name}): ${item.error!.message}');
}

// Retry only the ones that failed with a network error.
final retry = failed
    .where((i) => i.error!.error == MediaCompressError.network)
    .map((i) => i.path)
    .toList();
if (retry.isNotEmpty) await MediaCompress.compressAll(retry);
```

`onItemDone` gets each `BatchItem` as soon as that file finishes, success or failure, so a list can update row by row before the whole batch is done.

## 🧮 estimateImage and estimateVideo

```dart
Future<SizeEstimate> MediaCompress.estimateImage(String path, {ImageOptions options})
Future<SizeEstimate> MediaCompress.estimateVideo(String path, {VideoOptions options})
```

Predicts the result's size and dimensions without compressing it, so you can show the effect of each option before the user commits.

```dart
final estimate = await MediaCompress.estimateVideo(
  path,
  options: const VideoOptions(quality: VideoQuality.low),
);
Text(estimate.isOriginal
    ? 'Already small enough'
    : '≈ ${(estimate.size / 1024 / 1024).toStringAsFixed(1)} MB, '
      '${estimate.width} × ${estimate.height}');
```

- **Videos:** instant, from the bitrate it will use and the length. With `maxSizeMB`, never above the limit.
- **Images:** encodes a small copy and scales its size up, which takes a fraction of the time of a full compression.
- Expect the real result within about 20%, since content varies.
- Files on the device only: a URL throws `invalidArgument`. Compress the URL directly, or download it first.

## 🖼️ pick

```dart
Future<List<String>> MediaCompress.pick({
  PickType type = PickType.any, // image, video or any
  bool multiple = false,
  int? maxItems,
})
```

Opens the system's own picker and returns the paths of the chosen files, or an empty list when the user cancels.

```dart
final photos = await MediaCompress.pick(type: PickType.image, multiple: true);
```

- **No permission:** Android shows its Photo Picker (Android 11 and later; the system file picker before that), and iOS shows `PHPickerViewController`. The app only sees what the user picks, so there's nothing to declare in the manifest or `Info.plist`.
- The files are copied unchanged (iPhone videos stay HEVC, photos stay HEIC) into the app's cache, so they can be compressed, uploaded or deleted. `clearCache()` removes them.
- `maxItems` only applies with `multiple: true`. On Android it's also capped by the Photo Picker's own limit.
- The paths can go straight into `compressAll`.

## 🔎 getInfo

```dart
Future<MediaInfo> MediaCompress.getInfo(String path, {Map<String, String>? headers})
```

```dart
final info = await MediaCompress.getInfo(path);
if (info.type == MediaType.video) {
  print('${info.width}x${info.height}, ${info.duration}, '
      '${info.frameRate} fps, ${info.bitrate} bps');
}
```

| Field | Description |
|---|---|
| `path` | The path or URL you passed in. |
| `type` | `MediaType.image` or `MediaType.video`. |
| `size` | File size in bytes. |
| `width`, `height` | As displayed: a portrait video is taller than wide, whatever its stored frames. |
| `rotation` | How far the stored pixels are turned for display: 0, 90, 180 or 270. |
| `mimeType` | Such as `image/jpeg` or `video/mp4`. |
| `duration`, `frameRate` | Videos only. |
| `bitrate`, `videoBitrate`, `audioBitrate` | Videos only, when known. |
| `hasAudio` | Whether the video has sound. |
| `isPortrait` | Taller than wide. |

It doesn't decode the file, so it's fast even for long videos. For a URL, the file is downloaded, read and deleted, and `size` is the downloaded size.

## 🎞️ thumbnail

```dart
Future<Thumbnail> MediaCompress.thumbnail(
  String path, {
  Duration position = Duration.zero,
  int maxWidth = 512,
  int maxHeight = 512,
  int quality = 80,
  String? outputPath,
  Map<String, String>? headers, // for URLs
})
```

Saves the video frame nearest to `position` as an upright JPEG, scaled down to fit, and returns a `Thumbnail` with its `path`, `width`, `height` and `size`. Videos only: for a photo, show the photo itself.

```dart
final thumb = await MediaCompress.thumbnail(videoPath, position: const Duration(seconds: 2));
Image.file(File(thumb.path)); // thumb.width, thumb.height, thumb.size
```

## 🧹 clearCache

```dart
Future<void> MediaCompress.clearCache()
```

Results, thumbnails, picked files and downloads go to a `media_compress_kit` folder in the app's cache unless you pass an `outputPath`. Delete files when you're done with them (for example after uploading), or clear them all at once. Don't call it while a compression is running.

When a result's `isOriginal` is true, its `path` is the original file. Don't delete it.

## ✋ CompressController

```dart
final controller = CompressController();
MediaCompress.compressVideo(path, controller: controller);
// ...
await controller.cancel();
```

Pass the same controller to any `compressImage`, `compressVideo` or `compressAll` call to cancel it. The call then throws a `MediaCompressException` with `MediaCompressError.cancelled`, and its partial file is deleted. One controller can cancel several calls at once. Once cancelled, it stays cancelled, so use a new one for new work. `isCancelled` tells whether it was cancelled.

## 📦 Results

| Class | From | Fields |
|---|---|---|
| `ImageResult` | `compressImage` | `path`, `size`, `originalSize`, `width`, `height`, `format`, `isOriginal`, `ratio`, `savedBytes` |
| `VideoResult` | `compressVideo` | `path`, `size`, `originalSize`, `width`, `height`, `duration`, `bitrate`, `isOriginal`, `ratio`, `savedBytes` |
| `BatchItem` | `compressAll` | `path`, `result` (an `ImageResult` or `VideoResult`), `error`, `isSuccess`. See [what you get back](#what-you-get-back-one-file-vs-many). |
| `SizeEstimate` | `estimateImage`, `estimateVideo` | `size`, `width`, `height`, `isOriginal` |
| `MediaInfo` | `getInfo` | See [getInfo](#-getinfo). |
| `Thumbnail` | `thumbnail` | `path`, `width`, `height`, `size` |

- `path` is the new file. `size` and `originalSize` are in bytes.
- `ratio` is the result's size as a fraction of the original's (0.25 means a quarter of the size), and `savedBytes` is how much was saved.
- `isOriginal` is true when compressing wouldn't have helped, so `path` is the original file (or, for a URL, its downloaded copy). Don't delete it.
- `VideoResult.bitrate` is the result's average bitrate in bits per second; `duration` is its length after any trim.
- `ImageResult.format` is the format the file is in.

## 📊 A progress bar with cancel

```dart
class CompressButton extends StatefulWidget {
  const CompressButton({super.key, required this.path});
  final String path;

  @override
  State<CompressButton> createState() => _CompressButtonState();
}

class _CompressButtonState extends State<CompressButton> {
  CompressController? _controller;
  double _progress = 0;

  Future<void> _compress() async {
    final controller = CompressController();
    setState(() => _controller = controller);
    try {
      final result = await MediaCompress.compressVideo(
        widget.path,
        options: const VideoOptions(maxSizeMB: 16),
        controller: controller,
        onProgress: (p) => setState(() => _progress = p),
      );
      // Upload result.path...
    } on MediaCompressException catch (e) {
      if (e.error != MediaCompressError.cancelled) rethrow;
    } finally {
      setState(() => _controller = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return FilledButton(onPressed: _compress, child: const Text('Compress'));
    }
    return Row(children: [
      Expanded(child: LinearProgressIndicator(value: _progress)),
      Text(' ${(_progress * 100).round()}% '),
      TextButton(onPressed: _controller!.cancel, child: const Text('Cancel')),
    ]);
  }
}
```

The same pattern works for `compressImage` and `compressAll`, and for URLs, where the bar also covers the download.

## 🎯 How size limits work

**Videos (`maxSizeMB`)**

1. If the original already fits, and isn't trimmed, muted, or above the requested resolution or frame rate, you get it back as is.
2. Otherwise the video bitrate is the limit spread over the video's length, minus the audio.
3. If that bitrate is too low for the resolution, the resolution drops (1080p, 720p, 540p, 480p and so on), unless you set `resolution`.
4. Encoders treat the bitrate as a rough target. If the result is still too big, it is compressed again, aiming lower by however much the last attempt missed, up to three more times. Some encoders won't go below a minimum quality, so when one ignores the bitrate, the resolution drops too.

**Images (`maxSizeKB`)**

1. The image is encoded at `quality`. If it's too big, a binary search finds the highest quality that fits.
2. If even a low quality is too big, the image is scaled down by about the missing factor and searched again.

## ⚠️ Errors

Methods throw a `MediaCompressException`, with an `error` and a `message`. `compressAll` is the exception: it never throws for a file; each failed file's `BatchItem` has the same exception in `error` instead (see [what you get back](#what-you-get-back-one-file-vs-many)).

```dart
try {
  final result = await MediaCompress.compressImage(path);
} on MediaCompressException catch (e) {
  switch (e.error) {
    case MediaCompressError.cancelled:
      break; // The user cancelled; nothing to show.
    case MediaCompressError.network:
      showError('Check your connection');
    default:
      showError(e.message);
  }
}
```

| `MediaCompressError` | When |
|---|---|
| `fileNotFound` | The file doesn't exist or can't be read. |
| `unsupported` | Not a media file the phone can decode, a video passed to `compressImage` (or the other way round), a format this platform can't write (WebP on iOS, HEIC on Android), or a platform other than Android and iOS. |
| `invalidArgument` | For example, a trim that starts after it ends, or a URL passed to an estimate. |
| `cancelled` | A `CompressController` cancelled it. |
| `network` | Downloading a URL failed: no connection, a timeout, or an HTTP error such as 404 (in `message`). |
| `failed` | The decoder, encoder or file system failed; `message` has the details. |

## 📱 Platforms

| | Android | iOS |
|---|---|---|
| Minimum version | 7.0 (API 24) | 15 |
| Video | Media3 Transformer | AVAssetReader and AVAssetWriter |
| Image | BitmapFactory, ExifInterface | ImageIO |
| Image formats written | JPEG, PNG, WebP | JPEG, PNG, HEIC |
| Picker | Photo Picker (file picker before Android 11) | PHPickerViewController |
| Inputs | Paths, `file://`, `content://`, URLs | Paths, `file://`, URLs |
| Permissions | None (internet for URLs in release builds) | None |
| Swift Package Manager | | ✅ (and CocoaPods) |

Web and desktop aren't supported; calls there throw `MediaCompressError.unsupported`.

## 🧪 Testing

The example's integration tests compress a photo, a graphic and a video that the test makes on the device, so they need no real media:

```sh
cd example
flutter test integration_test/compress_test.dart
```

They also download files from a small web server inside the test, so the URL support is tested without the internet. The package's unit tests run anywhere:

```sh
flutter test
```

## 📱 Example

The [example app](https://github.com/parthbhensdadiya226/media_compress_kit/tree/main/example) has Video, Image and Batch tabs:

- Pick from the **Gallery** with `pick()`, paste a **Link**, or make a **Sample** on the device.
- Every option, with a live size estimate.
- A progress bar with cancel, then the before and after sizes.
- **Batch:** files and links mixed in one list, each row showing its saving or, in red, why it failed.

It uses no packages besides this one.

## ☕ Support

If this package saves you time, you can support its maintenance with a coffee:

<a href="https://buymeacoffee.com/parthbhensdadiya"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me a Coffee" height="48"></a>

## License

MIT
