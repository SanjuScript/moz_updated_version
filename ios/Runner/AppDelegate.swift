import AVFoundation
import Flutter
import Intents
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  var initialAudioPath: String?
  var externalAudioChannel: FlutterMethodChannel?
  var backgroundEngine: FlutterEngine?

  @discardableResult
  func ensureFlutterEngine() -> FlutterEngine {
    if let engine = backgroundEngine {
      return engine
    }

    let engine = FlutterEngine(
      name: "MozFlutterEngine",
      project: FlutterDartProject(),
      allowHeadlessExecution: true,
      restorationEnabled: true
    )
    let ran = engine.run()
    if ran {
      GeneratedPluginRegistrant.register(with: engine)
      setupExternalAudioChannel(messenger: engine.binaryMessenger)
    }
    backgroundEngine = engine
    return engine
  }

  @objc func takeLaunchEngine() -> FlutterEngine? {
    return backgroundEngine
  }

  override func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
    if intent is INPlayMediaIntent {
      ensureFlutterEngine()
      return MozPlayMediaIntentHandler()
    }
    return nil
  }

  override func application(
    _ application: UIApplication,
    handle intent: INIntent,
    completionHandler: @escaping (INIntentResponse) -> Void
  ) {
    if let playMediaIntent = intent as? INPlayMediaIntent {
      ensureFlutterEngine()
      MozPlayMediaIntentHandler().handle(intent: playMediaIntent) { response in
        completionHandler(response)
      }
    } else {
      super.application(application, handle: intent, completionHandler: completionHandler)
    }
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Pre-warm and activate AVAudioSession to eliminate initial playback delay on iOS
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
      try audioSession.setActive(true)
    } catch {
      print("Failed to pre-warm AVAudioSession: \(error)")
    }

    if let url = launchOptions?[.url] as? URL, url.isFileURL {
      initialAudioPath = resolveAndCacheUrl(url)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    if backgroundEngine == nil {
      GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
      setupExternalAudioChannel(messenger: engineBridge.applicationRegistrar.messenger())
    }
  }

  func setupExternalAudioChannel(messenger: FlutterBinaryMessenger) {
    externalAudioChannel = FlutterMethodChannel(
      name: "com.mozmusic.app/external_audio_handler",
      binaryMessenger: messenger
    )
    externalAudioChannel?.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getInitialAudio" {
        let path = self?.initialAudioPath
        self?.initialAudioPath = nil
        result(path)
      } else if call.method == "getPendingSiriAction" {
        result(MozSiriActionBridge.takePendingAction())
      } else if call.method == "completeSiriMedia" {
        let arguments = call.arguments as? [String: Any]
        if let requestID = arguments?["requestId"] as? String {
          MozSiriActionBridge.completeMediaRequest(
            id: requestID,
            success: arguments?["success"] as? Bool ?? false
          )
        }
        result(nil)
      } else if call.method == "acknowledgeSiriAction" {
        if let arguments = call.arguments as? [String: Any],
          let actionID = arguments["siriActionID"] as? String
        {
          MozSiriActionBridge.acknowledgeAction(id: actionID)
        }
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    MozSiriActionBridge.deliver = { [weak self] action in
      self?.externalAudioChannel?.invokeMethod("onSiriAction", arguments: action)
    }
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    if url.isFileURL {
      handleExternalAudio(url)
      return true
    }
    return super.application(app, open: url, options: options)
  }

  func handleExternalAudio(_ url: URL) {
    guard let resolvedPath = resolveAndCacheUrl(url) else { return }
    if externalAudioChannel != nil {
      externalAudioChannel?.invokeMethod("onAudioOpened", arguments: resolvedPath)
    } else {
      initialAudioPath = resolvedPath
    }
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
