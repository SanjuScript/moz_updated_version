import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  var initialAudioPath: String?
  var externalAudioChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    externalAudioChannel = FlutterMethodChannel(name: "com.mozmusic.app/external_audio_handler", binaryMessenger: controller.binaryMessenger)
    externalAudioChannel?.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getInitialAudio" {
        let path = self?.initialAudioPath
        self?.initialAudioPath = nil
        result(path)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    if let url = launchOptions?[.url] as? URL {
      if url.isFileURL {
        self.initialAudioPath = self.resolveAndCacheUrl(url)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    if url.isFileURL {
      if let resolvedPath = self.resolveAndCacheUrl(url) {
        if self.externalAudioChannel != nil {
          self.externalAudioChannel?.invokeMethod("onAudioOpened", arguments: resolvedPath)
        } else {
          self.initialAudioPath = resolvedPath
        }
      }
      return true
    }
    return super.application(app, open: url, options: options)
  }

  private func resolveAndCacheUrl(_ url: URL) -> String? {
    let fileManager = FileManager.default
    let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let externalAudioDir = cacheDirectory.appendingPathComponent("external_audio")

    if !fileManager.fileExists(atPath: externalAudioDir.path) {
      do {
        try fileManager.createDirectory(at: externalAudioDir, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print("Failed to create external audio cache directory: \(error)")
        return nil
      }
    } else {
      do {
        let fileURLs = try fileManager.contentsOfDirectory(at: externalAudioDir, includingPropertiesForKeys: nil)
        for fileURL in fileURLs {
          try fileManager.removeItem(at: fileURL)
        }
      } catch {
        print("Failed to clean external audio cache directory: \(error)")
      }
    }

    let destinationUrl = externalAudioDir.appendingPathComponent(url.lastPathComponent)

    do {
      if fileManager.fileExists(atPath: destinationUrl.path) {
        try fileManager.removeItem(at: destinationUrl)
      }
      try fileManager.copyItem(at: url, to: destinationUrl)
      return destinationUrl.path
    } catch {
      print("Failed to copy external audio file to cache: \(error)")
      return nil
    }
  }
}
