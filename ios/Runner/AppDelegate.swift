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
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "OwlSonicStorage") {
      OwlSonicStorageChannel.register(with: registrar.messenger())
    }
  }
}

/// `owlsonic/storage`: free space of the volume holding a path, so offline
/// downloads never fill the device.
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
