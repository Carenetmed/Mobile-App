import AVFoundation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SampleMedia") else {
      return
    }
    let channel = FlutterMethodChannel(name: "sample_media", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      guard call.method == "makeVideo", let args = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented)
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          try SampleVideo.make(
            path: args["path"] as! String,
            width: args["width"] as! Int,
            height: args["height"] as! Int,
            seconds: (args["seconds"] as! NSNumber).doubleValue,
            fps: args["fps"] as! Int,
            rotation: args["rotation"] as! Int,
            audio: args["audio"] as! Bool,
            bitrate: args["bitrate"] as! Int)
          DispatchQueue.main.async { result(nil) }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "FAILED", message: "\(error)", details: nil))
          }
        }
      }
    }
  }
}

/// Makes a test video without needing any real footage: animated shapes on a
/// moving gradient, with a tone for audio. The rotation is stored as
/// metadata, the way phones store portrait videos.
enum SampleVideo {
  struct Failure: Error {
    let message: String
  }

  static func make(
    path: String, width: Int, height: Int, seconds: Double, fps: Int, rotation: Int, audio: Bool,
    bitrate: Int
  ) throws {
    let url = URL(fileURLWithPath: path)
    try? FileManager.default.removeItem(at: url)
    let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
    let videoInput = AVAssetWriterInput(
      mediaType: .video,
      outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: width,
        AVVideoHeightKey: height,
        AVVideoCompressionPropertiesKey: [
          AVVideoAverageBitRateKey: bitrate,
          AVVideoMaxKeyFrameIntervalKey: fps,
        ],
      ])
    videoInput.expectsMediaDataInRealTime = false
    videoInput.transform = CGAffineTransform(rotationAngle: CGFloat(rotation) * .pi / 180)
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
      assetWriterInput: videoInput,
      sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: width,
        kCVPixelBufferHeightKey as String: height,
      ])
    writer.add(videoInput)

    var audioInput: AVAssetWriterInput?
    if audio {
      let input = AVAssetWriterInput(
        mediaType: .audio,
        outputSettings: [
          AVFormatIDKey: kAudioFormatMPEG4AAC,
          AVSampleRateKey: 44100,
          AVNumberOfChannelsKey: 2,
          AVEncoderBitRateKey: 192_000,
        ])
      input.expectsMediaDataInRealTime = false
      writer.add(input)
      audioInput = input
    }

    guard writer.startWriting() else {
      throw Failure(message: "startWriting: \(String(describing: writer.error))")
    }
    writer.startSession(atSourceTime: .zero)

    let sampleRate = 44100
    let totalAudioFrames = Int(seconds * Double(sampleRate))
    var audioWritten = 0
    let frames = Int(seconds * Double(fps))
    for frame in 0..<frames {
      try wait(for: videoInput)
      guard let pool = adaptor.pixelBufferPool else {
        throw Failure(message: "No pixel buffer pool: \(String(describing: writer.error))")
      }
      var buffer: CVPixelBuffer?
      CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
      guard let pixels = buffer else { throw Failure(message: "No pixel buffer") }
      draw(pixels, width: width, height: height, rotation: rotation, time: Double(frame) / Double(fps))
      adaptor.append(pixels, withPresentationTime: CMTime(value: CMTimeValue(frame), timescale: CMTimeScale(fps)))

      // Keep the audio in step with the video, or the writer waits for it.
      if let audioInput = audioInput {
        let until = min(totalAudioFrames, (frame + 1) * sampleRate / fps)
        while audioWritten < until {
          let count = min(1024, until - audioWritten)
          try wait(for: audioInput)
          audioInput.append(try tone(start: audioWritten, count: count, sampleRate: sampleRate))
          audioWritten += count
        }
      }
    }
    videoInput.markAsFinished()
    audioInput?.markAsFinished()
    let done = DispatchSemaphore(value: 0)
    writer.finishWriting { done.signal() }
    done.wait()
    guard writer.status == .completed else {
      throw Failure(message: "finishWriting: \(String(describing: writer.error))")
    }
  }

  private static func wait(for input: AVAssetWriterInput) throws {
    let deadline = Date().addingTimeInterval(10)
    while !input.isReadyForMoreMediaData {
      if Date() > deadline { throw Failure(message: "The writer stopped accepting data.") }
      Thread.sleep(forTimeInterval: 0.002)
    }
  }

  private static func draw(
    _ buffer: CVPixelBuffer, width: Int, height: Int, rotation: Int, time: Double
  ) {
    CVPixelBufferLockBaseAddress(buffer, [])
    defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
    guard
      let context = CGContext(
        data: CVPixelBufferGetBaseAddress(buffer), width: width, height: height,
        bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
          | CGBitmapInfo.byteOrder32Little.rawValue)
    else { return }
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1, y: -1)
    // Draw upright as displayed: turned a quarter left in the stored frame,
    // which the rotation metadata turns back.
    var w = CGFloat(width)
    var h = CGFloat(height)
    if rotation == 90 {
      context.translateBy(x: 0, y: h)
      context.rotate(by: -.pi / 2)
      swap(&w, &h)
    }
    UIGraphicsPushContext(context)
    defer { UIGraphicsPopContext() }

    let unit = min(w, h)
    let hue = CGFloat((time * 40).truncatingRemainder(dividingBy: 360)) / 360
    UIColor(hue: hue, saturation: 0.55, brightness: 0.35, alpha: 1).setFill()
    UIRectFill(CGRect(x: 0, y: 0, width: w, height: h))
    for i in 0..<7 {
      let angle = time * (0.6 + Double(i) * 0.15) + Double(i)
      let x = w / 2 + w * 0.38 * CGFloat(cos(angle))
      let y = h / 2 + h * 0.38 * CGFloat(sin(angle * 1.3))
      let radius = unit * (0.08 + 0.02 * CGFloat(i))
      UIColor(
        hue: (hue + CGFloat(i) * 50 / 360).truncatingRemainder(dividingBy: 1), saturation: 0.75,
        brightness: 1, alpha: 0.86
      ).setFill()
      UIBezierPath(ovalIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
        .fill()
    }
    // Fine stripes give the encoder real detail to work with.
    UIColor(white: 1, alpha: 0.24).setFill()
    let step = unit / 24
    var x = CGFloat((time * 80).truncatingRemainder(dividingBy: Double(step)))
    while x < w {
      UIRectFillUsingBlendMode(CGRect(x: x, y: 0, width: step / 3, height: h), .normal)
      x += step
    }
    func text(_ string: String, size: CGFloat, centerY: CGFloat) {
      let attributed = NSAttributedString(
        string: string,
        attributes: [
          .font: UIFont.boldSystemFont(ofSize: size), .foregroundColor: UIColor.white,
        ])
      let bounds = attributed.size()
      attributed.draw(at: CGPoint(x: (w - bounds.width) / 2, y: centerY - bounds.height / 2))
    }
    text(String(format: "%.1f s", time), size: unit / 9, centerY: h / 2)
    // An arrow pointing up, so a wrong rotation is easy to spot.
    text("↑", size: unit / 6, centerY: h * 0.22)
  }

  private static func tone(start: Int, count: Int, sampleRate: Int) throws -> CMSampleBuffer {
    var samples = [Int16](repeating: 0, count: count * 2)
    for i in 0..<count {
      let t = Double(start + i) / Double(sampleRate)
      let value = (sin(2 * .pi * 440 * t) * 0.3 + sin(2 * .pi * 660 * t) * 0.2) * Double(Int16.max)
      samples[i * 2] = Int16(value)
      samples[i * 2 + 1] = Int16(value)
    }
    var description = AudioStreamBasicDescription(
      mSampleRate: Double(sampleRate), mFormatID: kAudioFormatLinearPCM,
      mFormatFlags: kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked,
      mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4, mChannelsPerFrame: 2,
      mBitsPerChannel: 16, mReserved: 0)
    var format: CMAudioFormatDescription?
    CMAudioFormatDescriptionCreate(
      allocator: nil, asbd: &description, layoutSize: 0, layout: nil, magicCookieSize: 0,
      magicCookie: nil, extensions: nil, formatDescriptionOut: &format)
    let length = count * 4
    var block: CMBlockBuffer?
    CMBlockBufferCreateWithMemoryBlock(
      allocator: nil, memoryBlock: nil, blockLength: length, blockAllocator: nil,
      customBlockSource: nil, offsetToData: 0, dataLength: length, flags: 0, blockBufferOut: &block)
    guard let block = block, let format = format else { throw Failure(message: "No audio buffer") }
    samples.withUnsafeBytes { bytes in
      _ = CMBlockBufferReplaceDataBytes(
        with: bytes.baseAddress!, blockBuffer: block, offsetIntoDestination: 0, dataLength: length)
    }
    var buffer: CMSampleBuffer?
    CMAudioSampleBufferCreateReadyWithPacketDescriptions(
      allocator: nil, dataBuffer: block, formatDescription: format, sampleCount: count,
      presentationTimeStamp: CMTime(value: CMTimeValue(start), timescale: CMTimeScale(sampleRate)),
      packetDescriptions: nil, sampleBufferOut: &buffer)
    guard let buffer = buffer else { throw Failure(message: "No audio sample buffer") }
    return buffer
  }
}
