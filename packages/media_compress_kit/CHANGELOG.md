## 0.1.0

* Initial release.
* `MediaCompress.compressImage`: upright (EXIF orientation), scaled to fit, JPEG, PNG, WebP (Android) or HEIC (iOS), a `maxSizeKB` limit, and metadata removed, kept without GPS, or kept.
* `MediaCompress.compressVideo`: quality presets, resolution, bitrate, frame rate, H.264 or HEVC, trimming, removing audio, and a `maxSizeMB` limit with extra passes when the encoder overshoots. HDR becomes standard dynamic range.
* `onProgress` from 0 to 1 and cancelling with a `CompressController`, for images, videos and batches.
* `MediaCompress.compressAll`: photos and videos together, a few at a time, with overall progress and a result or error per file. An `outputPath` is a folder there, with each result named after its input. The same path or URL twice is compressed once.
* `MediaCompress.estimateImage` and `MediaCompress.estimateVideo`: the result's size and dimensions before compressing.
* `MediaCompress.pick`: the system photo and video picker, with no permission.
* URLs: compress, `getInfo`, `thumbnail` and `compressAll` take `https://` links, downloaded with progress, cancel and `headers`; `MediaCompressError.network` for failed downloads.
* Returns the original instead when compressing wouldn't make it smaller.
* `MediaCompress.getInfo`, `MediaCompress.thumbnail` and `MediaCompress.clearCache`.
* Android: Media3 Transformer, `content://` URIs. iOS: AVFoundation and ImageIO, Swift Package Manager and CocoaPods.
