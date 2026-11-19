import Flutter
import UIKit

/// A failure reported to Dart with one of the codes MediaCompressException knows.
struct MediaError: Error {
  let code: String
  let message: String

  static func failed(_ message: String) -> MediaError {
    MediaError(code: "FAILED", message: message)
  }

  static func unsupported(_ message: String) -> MediaError {
    MediaError(code: "UNSUPPORTED", message: message)
  }

  var flutterError: FlutterError {
    FlutterError(code: code, message: message, details: nil)
  }
}

public class MediaCompressKitPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var sink: FlutterEventSink?
  private var videos: [Int: VideoCompressor] = [:]
  private var picker: Picker?

  // Image jobs by id, set to true when cancelled. Read from background tasks.
  private let imagesLock = NSLock()
  private var images: [Int: Bool] = [:]

  private func imageCancelled(_ id: Int) -> Bool {
    imagesLock.lock()
    defer { imagesLock.unlock() }
    return images[id] == true
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = MediaCompressKitPlugin()
    let methods = FlutterMethodChannel(
      name: "media_compress_kit", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: methods)
    let events = FlutterEventChannel(
      name: "media_compress_kit/progress", binaryMessenger: registrar.messenger())
    events.setStreamHandler(instance)
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    sink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "getInfo":
      background(result) { try await MediaInfoReader.read(args["path"] as! String) }
    case "compressImage":
      compressImage(args, result)
    case "estimateImage":
      background(result) { try ImageCompressor.estimate(args) }
    case "pick":
      pick(args, result)
    case "thumbnail":
      background(result) { try await Thumbnails.create(args) }
    case "compressVideo":
      compressVideo(args, result)
    case "cancel":
      let id = args["id"] as! Int
      videos[id]?.cancel()
      imagesLock.lock()
      if images[id] != nil { images[id] = true }
      imagesLock.unlock()
      result(nil)
    case "cacheDirectory":
      let dir = Sources.cacheDirectory
      try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
      result(dir.path)
    case "clearCache":
      background(result) {
        let dir = Sources.cacheDirectory
        if FileManager.default.fileExists(atPath: dir.path) {
          try FileManager.default.removeItem(at: dir)
        }
        return nil
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func compressImage(_ args: [String: Any], _ result: @escaping FlutterResult) {
    let id = args["id"] as! Int
    imagesLock.lock()
    images[id] = false
    imagesLock.unlock()
    let job = ImageCompressor.Job(
      progress: { [weak self] progress in
        DispatchQueue.main.async { self?.sink?(["id": id, "progress": progress]) }
      },
      isCancelled: { [weak self] in self?.imageCancelled(id) ?? false })
    background(result) { [weak self] in
      defer {
        self?.imagesLock.lock()
        self?.images.removeValue(forKey: id)
        self?.imagesLock.unlock()
      }
      return try ImageCompressor.compress(args, job: job)
    }
  }

  private func pick(_ args: [String: Any], _ result: @escaping FlutterResult) {
    guard picker == nil else {
      result(MediaError.failed("The picker is already open.").flutterError)
      return
    }
    let picker = Picker { [weak self] paths in
      self?.picker = nil
      result(paths)
    }
    do {
      try picker.present(
        type: args["type"] as! String,
        multiple: args["multiple"] as! Bool,
        maxItems: (args["maxItems"] as? NSNumber)?.intValue)
      self.picker = picker
    } catch let error as MediaError {
      result(error.flutterError)
    } catch {
      result(MediaError.failed("\(error)").flutterError)
    }
  }

  private func compressVideo(_ args: [String: Any], _ result: @escaping FlutterResult) {
    let id = args["id"] as! Int
    let compressor: VideoCompressor
    do {
      compressor = try VideoCompressor(args)
    } catch let error as MediaError {
      result(error.flutterError)
      return
    } catch {
      result(MediaError.failed(error.localizedDescription).flutterError)
      return
    }
    videos[id] = compressor
    compressor.start(
      progress: { [weak self] progress in
        DispatchQueue.main.async {
          self?.sink?(["id": id, "progress": progress])
        }
      },
      done: { [weak self] map, error in
        DispatchQueue.main.async {
          self?.videos.removeValue(forKey: id)
          if let error = error {
            result(error.flutterError)
          } else {
            result(map)
          }
        }
      })
  }

  private func background(_ result: @escaping FlutterResult, _ work: @escaping () async throws -> Any?) {
    Task.detached(priority: .userInitiated) {
      do {
        let value = try await work()
        DispatchQueue.main.async { result(value) }
      } catch let error as MediaError {
        DispatchQueue.main.async { result(error.flutterError) }
      } catch {
        DispatchQueue.main.async { result(MediaError.failed("\(error)").flutterError) }
      }
    }
  }
}

/// Paths and files.
enum Sources {
  static func url(_ path: String) -> URL {
    if path.hasPrefix("file://"), let url = URL(string: path) { return url }
    return URL(fileURLWithPath: path)
  }

  /// The file's size in bytes. Throws FILE_NOT_FOUND when there's no file.
  static func size(_ url: URL) throws -> Int64 {
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
      !isDirectory.boolValue
    else {
      throw MediaError(code: "FILE_NOT_FOUND", message: "No file at \(url.path)")
    }
    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
    return (attributes[.size] as? NSNumber)?.int64Value ?? 0
  }

  /// The folder in the app's caches that holds the files this plugin writes.
  static var cacheDirectory: URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("media_compress_kit", isDirectory: true)
  }

  /// [outputPath], or a new file named with [prefix] and [ext] in [cacheDirectory].
  static func outputFile(_ outputPath: String?, prefix: String, ext: String) throws -> URL {
    let url: URL
    if let outputPath = outputPath {
      url = Sources.url(outputPath)
    } else {
      url = cacheDirectory.appendingPathComponent(
        "\(prefix)_\(Int(Date().timeIntervalSince1970 * 1000))_\(Int.random(in: 1000...9999)).\(ext)")
    }
    try FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    if FileManager.default.fileExists(atPath: url.path) {
      try FileManager.default.removeItem(at: url)
    }
    return url
  }
}
