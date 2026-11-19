import AVFoundation

/// One video compression with AVAssetReader and AVAssetWriter.
final class VideoCompressor {
  private let url: URL
  private let output: URL
  private let width: Int
  private let height: Int
  private let videoBitrate: Int
  private let audioBitrate: Int
  private let includeAudio: Bool
  private let frameRate: Double?
  private let startMs: Int?
  private let endMs: Int?
  private let codec: String

  private let lock = NSLock()
  private var cancelled = false
  private var reader: AVAssetReader?

  init(_ args: [String: Any]) throws {
    url = Sources.url(args["path"] as! String)
    width = args["width"] as! Int
    height = args["height"] as! Int
    videoBitrate = args["videoBitrate"] as! Int
    // AAC at 44.1 kHz stereo takes 64-320 kbps.
    audioBitrate = min(320_000, max(64_000, args["audioBitrate"] as! Int))
    includeAudio = args["includeAudio"] as! Bool
    frameRate = (args["frameRate"] as? NSNumber)?.doubleValue
    startMs = (args["startMs"] as? NSNumber)?.intValue
    endMs = (args["endMs"] as? NSNumber)?.intValue
    codec = args["codec"] as! String
    _ = try Sources.size(url)
    output = try Sources.outputFile(args["outputPath"] as? String, prefix: "VID", ext: "mp4")
  }

  private var isCancelled: Bool {
    lock.lock()
    defer { lock.unlock() }
    return cancelled
  }

  func cancel() {
    lock.lock()
    cancelled = true
    let reader = self.reader
    lock.unlock()
    reader?.cancelReading()
  }

  func start(
    progress: @escaping (Double) -> Void,
    done: @escaping ([String: Any]?, MediaError?) -> Void
  ) {
    Task.detached(priority: .userInitiated) {
      do {
        done(try await self.run(progress), nil)
      } catch let error as MediaError {
        try? FileManager.default.removeItem(at: self.output)
        done(nil, error)
      } catch {
        try? FileManager.default.removeItem(at: self.output)
        done(nil, MediaError.failed("\(error)"))
      }
    }
  }

  private func run(_ progress: @escaping (Double) -> Void) async throws -> [String: Any] {
    let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
    let duration: CMTime
    let videoTrack: AVAssetTrack
    do {
      duration = try await asset.load(.duration)
      guard let track = try await asset.loadTracks(withMediaType: .video).first else {
        throw MediaError.unsupported("\(url.path) has no video track.")
      }
      videoTrack = track
    } catch let error as MediaError {
      throw error
    } catch {
      throw MediaError.unsupported("\(url.path) is not a video this device can read.")
    }
    let (natural, transform, nominalRate) = try await videoTrack.load(
      .naturalSize, .preferredTransform, .nominalFrameRate)
    var audioTrack: AVAssetTrack?
    if includeAudio {
      audioTrack = try await asset.loadTracks(withMediaType: .audio).first
    }

    let start = CMTime(value: CMTimeValue(startMs ?? 0), timescale: 1000)
    let end = endMs.map { CMTime(value: CMTimeValue($0), timescale: 1000) } ?? duration
    let range = CMTimeRange(start: start, end: CMTimeMinimum(end, duration))
    guard range.duration.seconds > 0 else {
      throw MediaError(code: "INVALID_ARGUMENT", message: "The start must be before the end.")
    }

    let reader: AVAssetReader
    let writer: AVAssetWriter
    do {
      reader = try AVAssetReader(asset: asset)
      writer = try AVAssetWriter(outputURL: output, fileType: .mp4)
    } catch {
      throw MediaError.failed("Can't start: \(error.localizedDescription)")
    }
    reader.timeRange = range
    writer.shouldOptimizeForNetworkUse = true
    lock.lock()
    self.reader = reader
    lock.unlock()
    if isCancelled { throw cancelledError }

    // Video: draw each frame upright and scaled into the output size, in
    // standard dynamic range so it looks right everywhere.
    let fps = frameRate ?? (nominalRate > 0 ? Double(nominalRate) : 30)
    let composition = AVMutableVideoComposition()
    composition.renderSize = CGSize(width: width, height: height)
    composition.frameDuration = CMTime(seconds: 1 / fps, preferredTimescale: 600)
    composition.colorPrimaries = AVVideoColorPrimaries_ITU_R_709_2
    composition.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2
    composition.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2
    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRange(start: .zero, duration: duration)
    let layer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
    let display = CGRect(origin: .zero, size: natural).applying(transform)
    layer.setTransform(
      transform
        .concatenating(CGAffineTransform(translationX: -display.minX, y: -display.minY))
        .concatenating(
          CGAffineTransform(
            scaleX: CGFloat(width) / abs(display.width),
            y: CGFloat(height) / abs(display.height))),
      at: .zero)
    instruction.layerInstructions = [layer]
    composition.instructions = [instruction]

    let videoOutput = AVAssetReaderVideoCompositionOutput(
      videoTracks: [videoTrack],
      videoSettings: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
      ])
    videoOutput.videoComposition = composition
    videoOutput.alwaysCopiesSampleData = false
    guard reader.canAdd(videoOutput) else {
      throw MediaError.unsupported("This video can't be decoded.")
    }
    reader.add(videoOutput)

    let videoInput = try makeVideoInput(writer, fps: fps)
    writer.add(videoInput)

    var audio: (AVAssetReaderTrackOutput?, AVAssetWriterInput)?
    if includeAudio {
      let audioInput = AVAssetWriterInput(
        mediaType: .audio,
        outputSettings: [
          AVFormatIDKey: kAudioFormatMPEG4AAC,
          AVSampleRateKey: 44100,
          AVNumberOfChannelsKey: 2,
          AVEncoderBitRateKey: audioBitrate,
        ],
        sourceFormatHint: audioTrack == nil ? silentAudioFormat() : nil)
      audioInput.expectsMediaDataInRealTime = false
      if let audioTrack = audioTrack {
        let audioOutput = AVAssetReaderTrackOutput(
          track: audioTrack,
          outputSettings: [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false,
          ])
        audioOutput.alwaysCopiesSampleData = false
        if reader.canAdd(audioOutput) && writer.canAdd(audioInput) {
          reader.add(audioOutput)
          writer.add(audioInput)
          audio = (audioOutput, audioInput)
        }
      } else if writer.canAdd(audioInput) {
        writer.add(audioInput)
        audio = (nil, audioInput)
      }
    }

    guard reader.startReading() else {
      throw MediaError.failed("Can't read the video: \(reader.error?.localizedDescription ?? "")")
    }
    guard writer.startWriting() else {
      reader.cancelReading()
      throw MediaError.failed("Can't write the video: \(writer.error?.localizedDescription ?? "")")
    }
    writer.startSession(atSourceTime: start)

    let total = range.duration.seconds
    var lastReported = -1.0
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      let group = DispatchGroup()
      pump(videoOutput, into: videoInput, reader: reader, group: group) { time in
        let value = min(1, max(0, (time.seconds - start.seconds) / total))
        if value - lastReported >= 0.01 {
          lastReported = value
          progress(value)
        }
      }
      if let audio = audio {
        if let output = audio.0 {
          pump(output, into: audio.1, reader: reader, group: group, onSample: nil)
        } else {
          pumpSilence(audio.1, start: start, duration: range.duration, group: group)
        }
      }
      group.notify(queue: .global(qos: .userInitiated)) { continuation.resume() }
    }

    if isCancelled {
      writer.cancelWriting()
      throw cancelledError
    }
    if reader.status == .failed {
      writer.cancelWriting()
      throw MediaError.failed("Reading the video failed: \(reader.error?.localizedDescription ?? "")")
    }
    await writer.finishWriting()
    guard writer.status == .completed else {
      throw MediaError.failed("Writing the video failed: \(writer.error?.localizedDescription ?? "")")
    }
    return [
      "path": output.path,
      "size": try Sources.size(output),
      "width": width,
      "height": height,
      "durationMs": Int((range.duration.seconds * 1000).rounded()),
    ]
  }

  private func makeVideoInput(_ writer: AVAssetWriter, fps: Double) throws -> AVAssetWriterInput {
    func settings(_ codec: AVVideoCodecType) -> [String: Any] {
      var compression: [String: Any] = [
        AVVideoAverageBitRateKey: videoBitrate,
        AVVideoExpectedSourceFrameRateKey: Int(fps.rounded()),
        AVVideoMaxKeyFrameIntervalKey: max(1, Int((fps * 2).rounded())),
      ]
      if codec == .h264 {
        compression[AVVideoProfileLevelKey] = AVVideoProfileLevelH264HighAutoLevel
      }
      return [
        AVVideoCodecKey: codec,
        AVVideoWidthKey: width,
        AVVideoHeightKey: height,
        AVVideoCompressionPropertiesKey: compression,
        AVVideoColorPropertiesKey: [
          AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
          AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
          AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2,
        ],
      ]
    }
    var chosen = settings(codec == "hevc" ? .hevc : .h264)
    if !writer.canApply(outputSettings: chosen, forMediaType: .video) {
      chosen = settings(.h264)  // No HEVC encoder: fall back to H.264.
    }
    guard writer.canApply(outputSettings: chosen, forMediaType: .video) else {
      throw MediaError.unsupported("This device can't encode \(width)x\(height) video.")
    }
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: chosen)
    input.expectsMediaDataInRealTime = false
    guard writer.canAdd(input) else {
      throw MediaError.unsupported("This device can't encode \(width)x\(height) video.")
    }
    return input
  }

  /// Copies samples from [output] to [input] until the reader runs out, fails
  /// or is cancelled.
  private func pump(
    _ output: AVAssetReaderOutput,
    into input: AVAssetWriterInput,
    reader: AVAssetReader,
    group: DispatchGroup,
    onSample: ((CMTime) -> Void)?
  ) {
    group.enter()
    let queue = DispatchQueue(label: "media_compress_kit.\(input.mediaType.rawValue)")
    var finished = false
    input.requestMediaDataWhenReady(on: queue) { [self] in
      guard !finished else { return }
      while input.isReadyForMoreMediaData {
        let buffer = isCancelled || reader.status != .reading ? nil : output.copyNextSampleBuffer()
        guard let buffer = buffer, input.append(buffer) else {
          finished = true
          input.markAsFinished()
          group.leave()
          return
        }
        onSample?(CMSampleBufferGetPresentationTimeStamp(buffer))
      }
    }
  }

  private func silentAudioFormat() -> CMAudioFormatDescription? {
    var stream = AudioStreamBasicDescription(
      mSampleRate: 44100,
      mFormatID: kAudioFormatLinearPCM,
      mFormatFlags: kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
      mBytesPerPacket: 4,
      mFramesPerPacket: 1,
      mBytesPerFrame: 4,
      mChannelsPerFrame: 2,
      mBitsPerChannel: 16,
      mReserved: 0)
    var format: CMAudioFormatDescription?
    let status = CMAudioFormatDescriptionCreate(
      allocator: kCFAllocatorDefault,
      asbd: &stream,
      layoutSize: 0,
      layout: nil,
      magicCookieSize: 0,
      magicCookie: nil,
      extensions: nil,
      formatDescriptionOut: &format)
    return status == noErr ? format : nil
  }

  private func pumpSilence(
    _ input: AVAssetWriterInput,
    start: CMTime,
    duration: CMTime,
    group: DispatchGroup
  ) {
    // Feed real zero-valued PCM samples so AVAssetWriter emits an AAC track.
    guard let format = silentAudioFormat() else {
      input.markAsFinished()
      return
    }
    group.enter()
    let queue = DispatchQueue(label: "media_compress_kit.silent_audio")
    let sampleRate: Int32 = 44100
    let bufferFrames: Int32 = 4410
    let totalFrames = CMTimeConvertScale(duration, timescale: sampleRate, method: .roundTowardZero).value
    var frameOffset: Int64 = 0
    var finished = false
    input.requestMediaDataWhenReady(on: queue) { [self] in
      guard !finished else { return }
      while input.isReadyForMoreMediaData {
        if isCancelled || frameOffset >= totalFrames {
          finished = true
          input.markAsFinished()
          group.leave()
          return
        }
        let frames = Int32(min(Int64(bufferFrames), totalFrames - frameOffset))
        let pts = CMTimeAdd(start, CMTime(value: frameOffset, timescale: sampleRate))
        guard let sample = makeSilentSample(format: format, frames: frames, presentationTime: pts),
              input.append(sample) else {
          finished = true
          input.markAsFinished()
          group.leave()
          return
        }
        frameOffset += Int64(frames)
      }
    }
  }

  private func makeSilentSample(
    format: CMAudioFormatDescription,
    frames: Int32,
    presentationTime: CMTime
  ) -> CMSampleBuffer? {
    let byteCount = Int(frames) * 4
    var block: CMBlockBuffer?
    guard CMBlockBufferCreateWithMemoryBlock(
      allocator: kCFAllocatorDefault,
      memoryBlock: nil,
      blockLength: byteCount,
      blockAllocator: kCFAllocatorDefault,
      customBlockSource: nil,
      offsetToData: 0,
      dataLength: byteCount,
      flags: 0,
      blockBufferOut: &block) == kCMBlockBufferNoErr,
      let block = block,
      CMBlockBufferFillDataBytes(
        with: 0,
        blockBuffer: block,
        offsetIntoDestination: 0,
        dataLength: byteCount) == kCMBlockBufferNoErr
    else { return nil }
    var timing = CMSampleTimingInfo(
      duration: CMTime(value: 1, timescale: 44100),
      presentationTimeStamp: presentationTime,
      decodeTimeStamp: .invalid)
    var sample: CMSampleBuffer?
    guard CMSampleBufferCreateReady(
      allocator: kCFAllocatorDefault,
      dataBuffer: block,
      formatDescription: format,
      sampleCount: Int(frames),
      sampleTimingEntryCount: 1,
      sampleTimingArray: &timing,
      sampleSizeEntryCount: 0,
      sampleSizeArray: nil,
      sampleBufferOut: &sample) == noErr else { return nil }
    return sample
  }

  private var cancelledError: MediaError {
    MediaError(code: "CANCELLED", message: "The compression was cancelled.")
  }
}
