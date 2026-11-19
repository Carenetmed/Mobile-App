import AVFoundation
import ImageIO
import UniformTypeIdentifiers

enum Thumbnails {
  static func create(_ args: [String: Any]) async throws -> [String: Any] {
    let url = Sources.url(args["path"] as! String)
    let positionMs = args["positionMs"] as! Int
    let maxWidth = args["maxWidth"] as! Int
    let maxHeight = args["maxHeight"] as! Int
    let quality = args["quality"] as! Int
    _ = try Sources.size(url)

    let asset = AVURLAsset(url: url)
    let duration: CMTime
    do {
      duration = try await asset.load(.duration)
      let tracks = try await asset.loadTracks(withMediaType: .video)
      guard !tracks.isEmpty else {
        throw MediaError.unsupported("\(url.path) is not a video this device can read.")
      }
    } catch let error as MediaError {
      throw error
    } catch {
      throw MediaError.unsupported("\(url.path) is not a video this device can read.")
    }

    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.maximumSize = CGSize(width: maxWidth, height: maxHeight)
    generator.requestedTimeToleranceBefore = .zero
    generator.requestedTimeToleranceAfter = CMTime(value: 1, timescale: 10)
    var time = CMTime(value: CMTimeValue(positionMs), timescale: 1000)
    if duration.isNumeric && time >= duration {
      time = CMTimeSubtract(duration, CMTime(value: 1, timescale: 10))
    }
    let image: CGImage
    do {
      if #available(iOS 16, *) {
        image = try await generator.image(at: time).image
      } else {
        image = try generator.copyCGImage(at: time, actualTime: nil)
      }
    } catch {
      throw MediaError.failed("No frame at \(positionMs) ms in \(url.path): \(error.localizedDescription)")
    }

    let output = try Sources.outputFile(args["outputPath"] as? String, prefix: "THUMB", ext: "jpg")
    guard
      let destination = CGImageDestinationCreateWithURL(
        output as CFURL, UTType.jpeg.identifier as CFString, 1, nil)
    else {
      throw MediaError.failed("The image encoder failed to start.")
    }
    let options = [kCGImageDestinationLossyCompressionQuality: Double(quality) / 100]
    CGImageDestinationAddImage(destination, image, options as CFDictionary)
    guard CGImageDestinationFinalize(destination) else {
      throw MediaError.failed("The image encoder failed.")
    }
    return [
      "path": output.path,
      "width": image.width,
      "height": image.height,
      "size": try Sources.size(output),
    ]
  }
}
