import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    OwlSonicStorageChannel.register(
      with: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }
}

/// `owlsonic/storage`: free space of the volume holding a path, so offline
/// downloads never fill the disk.
enum OwlSonicStorageChannel {
  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "owlsonic/storage", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "freeBytes",
            let path = (call.arguments as? [String: Any])?["path"] as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      let url = URL(fileURLWithPath: path)
      do {
        let values = try url.resourceValues(forKeys: [
          .volumeAvailableCapacityForImportantUsageKey,
          .volumeAvailableCapacityKey,
        ])
        if let important = values.volumeAvailableCapacityForImportantUsage {
          result(NSNumber(value: important))
        } else if let available = values.volumeAvailableCapacity {
          result(NSNumber(value: available))
        } else {
          result(nil)
        }
      } catch {
        result(nil)
      }
    }
  }
}
