import PhotosUI
import UIKit
import UniformTypeIdentifiers

/// The system's photo and video picker. It needs no photo library
/// permission: the app only sees what the user picks. Picked files are
/// copied, unchanged, into the plugin's cache.
final class Picker: NSObject, PHPickerViewControllerDelegate {
  private let completion: ([String]) -> Void

  init(completion: @escaping ([String]) -> Void) {
    self.completion = completion
  }

  func present(type: String, multiple: Bool, maxItems: Int?) throws {
    var configuration = PHPickerConfiguration()
    switch type {
    case "image": configuration.filter = .images
    case "video": configuration.filter = .videos
    default: configuration.filter = .any(of: [.images, .videos])
    }
    // 0 means no limit.
    configuration.selectionLimit = multiple ? (maxItems ?? 0) : 1
    // The original file, not one converted to a more compatible format.
    configuration.preferredAssetRepresentationMode = .current
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = self
    guard let top = Picker.topViewController() else {
      throw MediaError.failed("There is no screen to show the picker on.")
    }
    top.present(picker, animated: true)
  }

  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    let group = DispatchGroup()
    let lock = NSLock()
    var paths = [String?](repeating: nil, count: results.count)
    for (index, result) in results.enumerated() {
      let provider = result.itemProvider
      let type =
        provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier)
        ? UTType.movie.identifier : UTType.image.identifier
      group.enter()
      // The file only exists during the callback, so it is copied there.
      provider.loadFileRepresentation(forTypeIdentifier: type) { url, _ in
        defer { group.leave() }
        guard let url = url, let copy = try? Picker.copy(url) else { return }
        lock.lock()
        paths[index] = copy
        lock.unlock()
      }
    }
    group.notify(queue: .main) { [completion] in
      completion(paths.compactMap { $0 })
    }
  }

  /// Copies [url] into the cache, keeping its name, and returns the path.
  private static func copy(_ url: URL) throws -> String {
    // A folder per file keeps the original names without clashes.
    let folder = Sources.cacheDirectory
      .appendingPathComponent("picked", isDirectory: true)
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    let destination = folder.appendingPathComponent(url.lastPathComponent)
    try FileManager.default.copyItem(at: url, to: destination)
    return destination.path
  }

  private static func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let windows = scenes.flatMap { $0.windows }
    var top = (windows.first { $0.isKeyWindow } ?? windows.first)?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}
