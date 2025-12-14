import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:on_audio_query/on_audio_query.dart';

extension SongModelX on SongModel {
  MediaItem toMediaItem() {
    return MediaItem(
      id: id.toString(),
      title: title,
      album: album,
      artist: artist,
      genre: genre,
      duration: duration != null ? Duration(milliseconds: duration!) : null,
      // artUri: albumId != null
      //     ? Uri.parse("content://media/external/audio/albumart/$albumId")
      //     : null,
      artHeaders: null,
      playable: isMusic ?? true,
      displayTitle: displayNameWOExt,
      displaySubtitle: artist,
      displayDescription: album,
      rating: null,
      isLive: isPodcast ?? false,
      extras: {
        "id": id,
        "uri": uri,
        "data": data,
        "displayName": displayName,
        "displayNameWOExt": displayNameWOExt,
        "size": size,
        "albumId": _safeToInt(getMap["album_id"]),
        "artistId": _safeToInt(getMap["artist_id"]),
        "genreId": _safeToInt(getMap["genre_id"]),
        "bookmark": bookmark,
        "composer": composer,
        "dateAdded": dateAdded,
        "dateModified": dateModified,
        "track": track,
        "fileExtension": fileExtension,
        "isAlarm": isAlarm,
        "isAudioBook": isAudioBook,
        "isMusic": isMusic,
        "isNotification": isNotification,
        "isPodcast": isPodcast,
        "isRingtone": isRingtone,
      },
    );
  }
}

extension OnlineSongToLocalX on OnlineSongModel {
  SongModel toSongModel() {
    final titleValue = song ?? "Unknown Title";
    final artistValue = (artists?.isNotEmpty == true)
        ? artists!.map((e) => e.name).join(", ")
        : (singers ?? "Unknown Artist");
    final albumValue = album ?? "Unknown Album";

    return SongModel({
      "_id": 0, // Saavn PID is NOT numeric – forced safe fallback
      "_uri": mediaUrl ?? "",
      "_data": mediaUrl ?? "",
      "image": image ?? '',
      "_display_name": titleValue,
      "_display_name_wo_ext": titleValue,

      "_size": 0, // unknown

      "album": albumValue,
      "album_id": 0, // unknown local MediaStore ID

      "artist": artistValue,
      "artist_id": 0,

      "genre": language ?? "",
      "genre_id": 0,

      "bookmark": 0,
      "composer": music ?? "",

      "date_added": 0,
      "date_modified": 0,

      // Saavn duration → seconds → convert to milliseconds
      "duration": _safeDurationMs(duration),

      "title": titleValue,
      "track": 0,

      "file_extension": "aac", // JioSaavn stream type

      "is_alarm": false,
      "is_audiobook": false,
      "is_music": true,
      "is_notification": false,
      "is_podcast": false,
      "is_ringtone": false,

      // tagging as online
      "isOnline": true,
      "pid": id,
    });
  }
}

extension MediaItemX on MediaItem {
  SongModel toSongModel() {
    final e = extras ?? {};
    final titleValue = title.isNotEmpty ? title : "Unknown Title";

    final artistValue = (artist != null && artist!.isNotEmpty)
        ? artist!
        : "Unknown Artist";

    final albumValue = album ?? "Unknown Album";

    return SongModel({
      "_id": e["id"] ?? int.tryParse(id) ?? 0,
      "_uri": e["uri"] ?? id,
      "_data": e["data"] ?? "",
      "_display_name": titleValue,
      "_display_name_wo_ext": titleValue,
      "_size": e["size"] ?? 0,
      "album": albumValue,
      "album_id": e["albumId"] ?? album,
      "artist": artistValue,
      "artist_id": e["artistId"],
      "genre": genre,
      "genre_id": e["genreId"],
      "bookmark": e["bookmark"],
      "composer": e["music"] ?? "",
      "date_added": e["dateAdded"],
      "date_modified": e["dateModified"],
      "duration": duration?.inMilliseconds,
      "title": title,
      "track": e["track"],
      "file_extension": e["fileExtension"] ?? "",
      "is_alarm": e["isAlarm"],
      "is_audiobook": e["isAudioBook"],
      "is_music": e["isMusic"],
      "is_notification": e["isNotification"],
      "is_podcast": e["isPodcast"],
      "is_ringtone": e["isRingtone"],
      "isOnline": isOnline(id),
      "pid": id,
    });
  }
}

extension MediaItemListX on List<MediaItem> {
  List<SongModel> toSongModels() => map((e) => e.toSongModel()).toList();
}

extension SongModelListX on List<SongModel> {
  List<MediaItem> toMediaitems() => map((e) => e.toMediaItem()).toList();
}

int? _safeToInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

int? _safeDurationMs(String? secString) {
  if (secString == null) return null;
  final sec = int.tryParse(secString);
  if (sec == null) return null;
  return sec * 1000;
}

bool isOnline(dynamic id) {
  if (id is int) return false;

  if (id is String) {
    return int.tryParse(id) == null;
  }

  return false;
}
