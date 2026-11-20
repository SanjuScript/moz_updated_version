import AppIntents
import Foundation
import Intents
import UIKit

enum MozSiriActionBridge {
  private static let pendingActionKey = "moz.pending_siri_action"
  static var deliver: (([String: Any]) -> Void)?
  private static var mediaRequest: (
    id: String,
    completion: (INPlayMediaIntentResponse) -> Void
  )?

  static func submit(_ action: [String: Any]) {
    var durableAction = action
    if durableAction["siriActionID"] == nil {
      durableAction["siriActionID"] = UUID().uuidString
    }
    UserDefaults.standard.set(durableAction, forKey: pendingActionKey)

    guard let deliver else { return }
    DispatchQueue.main.async {
      deliver(durableAction)
    }
  }

  static func acknowledgeAction(id: String) {
    guard
      let pending = UserDefaults.standard.dictionary(forKey: pendingActionKey),
      pending["siriActionID"] as? String == id
    else { return }
    UserDefaults.standard.removeObject(forKey: pendingActionKey)
  }

  static func takePendingAction() -> [String: Any]? {
    defer { UserDefaults.standard.removeObject(forKey: pendingActionKey) }
    return UserDefaults.standard.dictionary(forKey: pendingActionKey)
  }

  static func submitMediaAction(
    _ action: [String: Any],
    completion: @escaping (INPlayMediaIntentResponse) -> Void
  ) {
    let requestID = UUID().uuidString
    mediaRequest = (requestID, completion)
    var actionWithRequestID = action
    actionWithRequestID["mediaRequestID"] = requestID
    actionWithRequestID["siriActionID"] = requestID
    submit(actionWithRequestID)

    // Siri client timeout is ~5 seconds. If Flutter hasn't finished buffering,
    // respond with success/handleInApp within 4 seconds so Siri confirms playback
    // and does not report a failure or timeout to the user.
    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
      if mediaRequest?.id == requestID {
        completeMediaRequest(id: requestID, success: true)
      }
    }
  }

  static func completeMediaRequest(id: String, success: Bool) {
    guard let request = mediaRequest, request.id == id else { return }
    mediaRequest = nil
    acknowledgeAction(id: id)
    let code: INPlayMediaIntentResponseCode = success ? .success : .handleInApp
    request.completion(INPlayMediaIntentResponse(code: code, userActivity: nil))
  }
}

final class MozPlayMediaIntentHandler: NSObject, INPlayMediaIntentHandling {
  func handle(intent: INPlayMediaIntent, completion: @escaping (INPlayMediaIntentResponse) -> Void) {
    // Ensure the Flutter engine is booting or running in the background
    DispatchQueue.main.async {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        appDelegate.ensureFlutterEngine()
      }
    }

    let containerTitle = intent.mediaContainer?.title ?? ""
    let searchName = intent.mediaSearch?.mediaName ?? ""
    let itemName = intent.mediaItems?.first?.title ?? ""
    let requestName = !containerTitle.isEmpty ? containerTitle : (!searchName.isEmpty ? searchName : itemName)
    let normalizedName = requestName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

    var action: [String: Any] = [:]

    let isFavoriteRequest = normalizedName.contains("favorite") ||
      normalizedName.contains("favourite") ||
      normalizedName.contains("liked") ||
      normalizedName.contains("like") ||
      normalizedName.contains("loved") ||
      normalizedName.contains("love")

    let isPlaylistRequest = intent.mediaContainer?.type == .playlist ||
      intent.mediaSearch?.mediaType == .playlist ||
      normalizedName.contains("playlist")

    if isFavoriteRequest {
      action = ["action": "playFavorites"]
    } else if isPlaylistRequest {
      let playlistName = requestName
        .replacingOccurrences(
          of: #"(?i)\b(my|the|a|playlist|playlists)\b"#,
          with: "",
          options: .regularExpression
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
      action = ["action": "playPlaylist", "playlistName": playlistName]
    } else if !requestName.isEmpty &&
      normalizedName != "music" &&
      normalizedName != "songs" &&
      normalizedName != "song" &&
      normalizedName != "some music" {
      action = ["action": "playSearch", "query": requestName]
    } else {
      action = ["action": "playMusic"]
    }

    MozSiriActionBridge.submitMediaAction(action, completion: completion)
  }
}

@available(iOS 16.0, *)
struct PlayMozMusicIntent: AppIntent {
  static var title: LocalizedStringResource = "Play music on Moz Music"

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        appDelegate.ensureFlutterEngine()
      }
      MozSiriActionBridge.submit(["action": "playMusic"])
    }
    return .result()
  }
}

@available(iOS 16.0, *)
struct PlayMozFavoritesIntent: AppIntent {
  static var title: LocalizedStringResource = "Play favorite songs on Moz Music"

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        appDelegate.ensureFlutterEngine()
      }
      MozSiriActionBridge.submit(["action": "playFavorites"])
    }
    return .result()
  }
}

@available(iOS 16.0, *)
struct MozPlaylistEntity: AppEntity {
  var id: String
  var name: String

  static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Playlist")
  static var defaultQuery = MozPlaylistQuery()

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(name)")
  }

  init(name: String) {
    self.id = name
    self.name = name
  }
}

@available(iOS 16.0, *)
struct MozPlaylistQuery: EntityStringQuery {
  func entities(for identifiers: [String]) async throws -> [MozPlaylistEntity] {
    identifiers.map { MozPlaylistEntity(name: $0) }
  }

  func entities(matching string: String) async throws -> [MozPlaylistEntity] {
    let name = string.trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? [] : [MozPlaylistEntity(name: name)]
  }
}

@available(iOS 16.0, *)
struct PlayMozPlaylistIntent: AppIntent {
  static var title: LocalizedStringResource = "Play a playlist on Moz Music"

  @Parameter(title: "Playlist name")
  var playlist: MozPlaylistEntity

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        appDelegate.ensureFlutterEngine()
      }
      MozSiriActionBridge.submit([
        "action": "playPlaylist",
        "playlistName": playlist.name,
      ])
    }
    return .result()
  }
}

@available(iOS 16.0, *)
struct PauseMozMusicIntent: AppIntent {
  static var title: LocalizedStringResource = "Pause music on Moz Music"

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      MozSiriActionBridge.submit(["action": "pause"])
    }
    return .result()
  }
}

@available(iOS 16.0, *)
struct NextMozMusicIntent: AppIntent {
  static var title: LocalizedStringResource = "Play the next song on Moz Music"

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      MozSiriActionBridge.submit(["action": "next"])
    }
    return .result()
  }
}

@available(iOS 16.0, *)
struct MozMusicShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: PlayMozMusicIntent(),
      phrases: [
        "Play music on \(.applicationName)",
        "Play music in \(.applicationName)",
        "Play songs on \(.applicationName)",
        "Play some music on \(.applicationName)",
      ],
      shortTitle: "Play music",
      systemImageName: "play.fill"
    )
    AppShortcut(
      intent: PlayMozFavoritesIntent(),
      phrases: [
        "Play my favorite songs on \(.applicationName)",
        "Play favorite songs on \(.applicationName)",
        "Play my favorites on \(.applicationName)",
        "Play favorites on \(.applicationName)",
        "Play liked songs on \(.applicationName)",
        "Play my liked songs on \(.applicationName)",
        "Play my likes on \(.applicationName)",
        "Play liked music on \(.applicationName)",
      ],
      shortTitle: "Play favorites",
      systemImageName: "heart.fill"
    )
    AppShortcut(
      intent: PlayMozPlaylistIntent(),
      phrases: [
        "Play my \(\.$playlist) playlist on \(.applicationName)",
        "Play \(\.$playlist) playlist on \(.applicationName)",
        "Play playlist \(\.$playlist) on \(.applicationName)",
      ],
      shortTitle: "Play a playlist",
      systemImageName: "music.note.list"
    )
    AppShortcut(
      intent: PauseMozMusicIntent(),
      phrases: [
        "Pause music on \(.applicationName)",
        "Pause playback on \(.applicationName)",
      ],
      shortTitle: "Pause music",
      systemImageName: "pause.fill"
    )
    AppShortcut(
      intent: NextMozMusicIntent(),
      phrases: [
        "Skip this song on \(.applicationName)",
        "Play the next song on \(.applicationName)",
        "Next song on \(.applicationName)",
      ],
      shortTitle: "Next song",
      systemImageName: "forward.end.fill"
    )
  }
}

@available(iOS 17.0, *)
extension PlayMozMusicIntent: AudioPlaybackIntent {
  @available(iOS 26.0, *)
  static var supportedModes: IntentModes { .background }
}

@available(iOS 17.0, *)
extension PlayMozFavoritesIntent: AudioPlaybackIntent {
  @available(iOS 26.0, *)
  static var supportedModes: IntentModes { .background }
}

@available(iOS 17.0, *)
extension PlayMozPlaylistIntent: AudioPlaybackIntent {
  @available(iOS 26.0, *)
  static var supportedModes: IntentModes { .background }
}

@available(iOS 26.0, *)
extension PauseMozMusicIntent {
  static var supportedModes: IntentModes { .background }
}

@available(iOS 26.0, *)
extension NextMozMusicIntent {
  static var supportedModes: IntentModes { .background }
}
