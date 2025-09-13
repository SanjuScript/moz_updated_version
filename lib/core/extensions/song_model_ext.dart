import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

extension SongModelX on SongModel {
  MediaItem toMediaItem() {
    return MediaItem(
      id: uri ?? id.toString(),
      title: title,
      album: album,
      artist: artist,
      genre: genre,
      duration: duration != null ? Duration(milliseconds: duration!) : null,
      artUri: albumId != null
          ? Uri.parse("content://media/external/audio/albumart/$albumId")
          : null,
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
        "albumId": albumId,
        "artistId": artistId,
        "genreId": genreId,
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

extension MediaItemX on MediaItem {
  SongModel toSongModel() {
    final e = extras ?? {};
    return SongModel({
      "_id": e["id"] ?? int.tryParse(id) ?? 0,
      "_uri": e["uri"] ?? id,
      "_data": e["data"] ?? "",
      "_display_name": e["displayName"] ?? title,
      "_display_name_wo_ext": e["displayNameWOExt"] ?? displayTitle ?? title,
      "_size": e["size"] ?? 0,
      "album": album,
      "album_id": e["albumId"] ?? album,
      "artist": artist,
      "artist_id": e["artistId"],
      "genre": genre,
      "genre_id": e["genreId"],
      "bookmark": e["bookmark"],
      "composer": e["composer"],
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
    });
  }
}
extension MediaItemListX on List<MediaItem> {
  List<SongModel> toSongModels() => map((e) => e.toSongModel()).toList();
}
