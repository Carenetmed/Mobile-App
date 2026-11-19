import AVFoundation
import ImageIO
import UniformTypeIdentifiers

enum MediaInfoReader {
  static func read(_ path: String) async throws -> [String: Any] {
    let url = Sources.url(path)
    let size = try Sources.size(url)
    if let image = readImage(url, size: size) { return image }
    return try await readVideo(url, size: size)
  }

  private static func readImage(_ url: URL, size: Int64) -> [String: Any]? {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      let type = CGImageSourceGetType(source),
      CGImageSourceGetCount(source) > 0,
      let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
      let width = (properties[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue,
      let height = (properties[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue,
      width > 0, height > 0
    else { return nil }
    let orientation = (properties[kCGImagePropertyOrientation] as? NSNumber)?.intValue ?? 1
    let swapped = orientation >= 5
    return [
      "type": "image",
      "size": size,
      "width": swapped ? height : width,
      "height": swapped ? width : height,
      "mimeType": UTType(type as String)?.preferredMIMEType as Any,
      "rotation": degrees(orientation),
    ]
  }

  /// The rotation of an EXIF orientation, matching the Android side.
  static func degrees(_ orientation: Int) -> Int {
    switch orientation {
    case 3, 4: return 180
    case 5, 6: return 90
    case 7, 8: return 270
    default: return 0
    }
  }

  private static func readVideo(_ url: URL, size: Int64) async throws -> [String: Any] {
    let asset = AVURLAsset(url: url)
    let duration: CMTime
    let video: AVAssetTrack
    do {
      duration = try await asset.load(.duration)
      guard let track = try await asset.loadTracks(withMediaType: .video).first else {
        throw MediaError.unsupported("\(url.path) is not an image or video this device can read.")
      }
      video = track
    } catch let error as MediaError {
      throw error
    } catch {
      throw MediaError.unsupported(
        "\(url.path) is not an image or video this device can read: \(error.localizedDescription)")
    }
    let (natural, transform, frameRate, videoRate) = try await video.load(
      .naturalSize, .preferredTransform, .nominalFrameRate, .estimatedDataRate)
    let audio = try await asset.loadTracks(withMediaType: .audio).first
    let audioRate = try await audio?.load(.estimatedDataRate)

    let display = CGRect(origin: .zero, size: natural).applying(transform)
    var rotation = Int((atan2(transform.b, transform.a) * 180 / .pi).rounded())
    rotation = ((rotation % 360) + 360) % 360
    let seconds = duration.seconds
    let ext = url.pathExtension.lowercased()
    return [
      "type": "video",
      "size": size,
      "width": Int(abs(display.width).rounded()),
      "height": Int(abs(display.height).rounded()),
      "rotation": rotation,
      "durationMs": seconds.isFinite ? Int((seconds * 1000).rounded()) : 0,
      "mimeType": (ext == "mov" ? "video/quicktime" : UTType(filenameExtension: ext)?.preferredMIMEType)
        as Any,
      "bitrate": seconds > 0 ? Int(Double(size) * 8 / seconds) : 0,
      "frameRate": Double(frameRate),
      "videoBitrate": Int(videoRate),
      "audioBitrate": audioRate.map { Int($0) } as Any,
      "hasAudio": audio != nil,
    ]
  }
}
