import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

enum ImageCompressor {
  private static let minQuality = 10
  private static let sampleSides = [400, 800]

  /// Reports progress from 0 to 1 and throws CANCELLED when cancelled.
  struct Job {
    let progress: (Double) -> Void
    let isCancelled: () -> Bool

    func step(_ value: Double) throws {
      if isCancelled() {
        throw MediaError(code: "CANCELLED", message: "The compression was cancelled.")
      }
      progress(value)
    }
  }

  static func compress(_ args: [String: Any], job: Job) throws -> [String: Any] {
    let url = Sources.url(args["path"] as! String)
    let width = args["width"] as! Int
    let height = args["height"] as! Int
    let format = args["format"] as! String
    let quality = args["quality"] as! Int
    let maxBytes = (args["maxBytes"] as? NSNumber)?.intValue
    let metadata = args["metadata"] as! String
    _ = try Sources.size(url)

    let type = try outputType(format)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      CGImageSourceGetCount(source) > 0
    else {
      throw MediaError.unsupported("\(url.path) is not an image this device can decode.")
    }
    let properties = metadataProperties(source, metadata)
    try job.step(0.05)

    var maxPixels = max(width, height)
    var image = try upright(source, maxPixels: maxPixels, opaque: format == "jpeg")
    try job.step(0.5)
    var data = try encode(image, type: type, quality: quality, properties: properties)
    // Fitting a size limit takes several encodes; each moves the bar on.
    var attempts = 0.0
    let encoded: () throws -> Void = {
      attempts += 1
      try job.step(0.7 + 0.25 * (1 - pow(0.85, attempts)))
    }
    try encoded()

    // EXIF tags take some room; keep it out of the budget.
    let budget = maxBytes.map { metadata != "removeAll" && $0 > 64 * 1024 ? $0 - 16 * 1024 : $0 }
    if let budget = budget {
      var rounds = 0
      while data.count > budget && rounds < 8 {
        if format != "png",
          let fitting = try highestQualityUnder(
            image, type: type, quality: quality, budget: budget, properties: properties,
            encoded: encoded)
        {
          data = fitting
          break
        }
        // Even the lowest quality is too big, so scale down by about the
        // missing factor and try again.
        let scale = min(0.9, max(0.3, (Double(budget) / Double(data.count)).squareRoot() * 0.95))
        maxPixels = Int(Double(maxPixels) * scale)
        if maxPixels < 16 { break }
        image = try upright(source, maxPixels: maxPixels, opaque: format == "jpeg")
        data = try encode(image, type: type, quality: quality, properties: properties)
        try encoded()
        rounds += 1
      }
    }

    try job.step(0.96)
    let output = try Sources.outputFile(
      args["outputPath"] as? String, prefix: "IMG", ext: format == "jpeg" ? "jpg" : format)
    try data.write(to: output)
    return [
      "path": output.path,
      "size": data.count,
      "width": image.width,
      "height": image.height,
    ]
  }

  /// Bits per pixel of two small copies encoded as asked, for size estimates.
  static func estimate(_ args: [String: Any]) throws -> [String: Any] {
    let url = Sources.url(args["path"] as! String)
    let width = args["width"] as! Int
    let height = args["height"] as! Int
    let format = args["format"] as! String
    let quality = args["quality"] as! Int
    _ = try Sources.size(url)
    let type = try outputType(format)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      CGImageSourceGetCount(source) > 0
    else {
      throw MediaError.unsupported("\(url.path) is not an image this device can decode.")
    }
    // Two small copies: the trend between them extends to the full size.
    let samples = try sampleSides.map { side -> [Double] in
      let image = try upright(
        source, maxPixels: min(max(width, height), side), opaque: format == "jpeg")
      let data = try encode(image, type: type, quality: quality, properties: [:])
      let pixels = Double(image.width * image.height)
      return [pixels, Double(data.count * 8) / pixels]
    }
    return ["samples": samples]
  }

  private static func outputType(_ format: String) throws -> CFString {
    let type: UTType
    switch format {
    case "jpeg": type = .jpeg
    case "png": type = .png
    case "heic": type = .heic
    case "webp": type = .webP
    default: throw MediaError(code: "INVALID_ARGUMENT", message: "Unknown image format \(format)")
    }
    let writable = CGImageDestinationCopyTypeIdentifiers() as? [String] ?? []
    guard writable.contains(type.identifier) else {
      throw MediaError.unsupported(
        format == "webp"
          ? "WebP output is only available on Android. Use jpeg or heic on iOS."
          : "This device can't write \(format) images.")
    }
    return type.identifier as CFString
  }

  /// The image turned upright by its EXIF orientation, with its long side at
  /// most [maxPixels].
  private static func upright(_ source: CGImageSource, maxPixels: Int, opaque: Bool) throws
    -> CGImage
  {
    let options: [CFString: Any] = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceThumbnailMaxPixelSize: maxPixels,
      kCGImageSourceShouldCacheImmediately: true,
    ]
    guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
      throw MediaError.unsupported("This image can't be decoded.")
    }
    return opaque ? onWhite(image) : image
  }

  /// JPEG has no transparency; without this, transparent pixels turn black.
  private static func onWhite(_ image: CGImage) -> CGImage {
    switch image.alphaInfo {
    case .none, .noneSkipFirst, .noneSkipLast: return image
    default: break
    }
    guard
      let context = CGContext(
        data: nil, width: image.width, height: image.height, bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
    else { return image }
    let rect = CGRect(x: 0, y: 0, width: image.width, height: image.height)
    context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    context.fill(rect)
    context.draw(image, in: rect)
    return context.makeImage() ?? image
  }

  /// The source's metadata to write with the result, without what the
  /// result no longer matches (orientation and size).
  private static func metadataProperties(_ source: CGImageSource, _ metadata: String) -> [CFString:
    Any]
  {
    guard metadata != "removeAll",
      var properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
    else { return [:] }
    properties[kCGImagePropertyOrientation] = 1
    if var tiff = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any] {
      tiff[kCGImagePropertyTIFFOrientation] = 1
      properties[kCGImagePropertyTIFFDictionary] = tiff
    }
    for key in [
      kCGImagePropertyPixelWidth, kCGImagePropertyPixelHeight, kCGImagePropertyDepth,
      kCGImagePropertyHasAlpha, kCGImagePropertyColorModel, kCGImagePropertyProfileName,
      kCGImagePropertyFileSize,
    ] {
      properties.removeValue(forKey: key)
    }
    if var exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any] {
      exif.removeValue(forKey: kCGImagePropertyExifPixelXDimension)
      exif.removeValue(forKey: kCGImagePropertyExifPixelYDimension)
      properties[kCGImagePropertyExifDictionary] = exif
    }
    if metadata != "keepAll" {
      properties.removeValue(forKey: kCGImagePropertyGPSDictionary)
    }
    return properties
  }

  private static func encode(
    _ image: CGImage, type: CFString, quality: Int, properties: [CFString: Any]
  ) throws -> Data {
    let data = NSMutableData()
    guard let destination = CGImageDestinationCreateWithData(data, type, 1, nil) else {
      throw MediaError.failed("The image encoder failed to start.")
    }
    var options = properties
    options[kCGImageDestinationLossyCompressionQuality] = Double(quality) / 100
    CGImageDestinationAddImage(destination, image, options as CFDictionary)
    guard CGImageDestinationFinalize(destination) else {
      throw MediaError.failed("The image encoder failed.")
    }
    return data as Data
  }

  /// The best-quality encoding under [budget], by binary search, or nil if none fits.
  private static func highestQualityUnder(
    _ image: CGImage, type: CFString, quality: Int, budget: Int, properties: [CFString: Any],
    encoded: () throws -> Void
  ) throws -> Data? {
    var low = minQuality
    var high = quality - 1
    var best: Data?
    while low <= high {
      let mid = (low + high) / 2
      let data = try encode(image, type: type, quality: mid, properties: properties)
      try encoded()
      if data.count <= budget {
        best = data
        low = mid + 1
      } else {
        high = mid - 1
      }
    }
    return best
  }
}
