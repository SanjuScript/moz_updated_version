import 'dart:convert';

import 'package:audio_service/audio_service.dart';

class OnlineSongModel {
  OnlineSongModel({
    this.the320Kbps,
    this.album,
    this.albumUrl,
    this.albumid,
    this.artists,
    this.cacheState,
    this.copyrightText,
    this.duration,
    this.encryptedDrmMediaUrl,
    this.encryptedMediaPath,
    this.encryptedMediaUrl,
    this.explicitContent,
    this.featuredArtists,
    this.featuredArtistsId,
    this.hasLyrics,
    this.id,
    this.image,
    this.isDolbyContent,
    this.isDrm,
    this.label,
    this.labelId,
    this.labelUrl,
    this.language,
    this.lyrics,
    this.lyricsSnippet,
    this.mediaPreviewUrl,
    this.mediaUrl,
    this.music,
    this.musicId,
    this.origin,
    this.permaUrl,
    this.playCount,
    this.primaryArtists,
    this.primaryArtistsId,
    this.releaseDate,
    this.rights,
    this.singers,
    this.song,
    this.starred,
    this.starring,
    this.trillerAvailable,
    this.type,
    this.vcode,
    this.vlink,
    this.webp,
    this.year,
  });

  final String? the320Kbps;
  final String? album;
  final String? albumUrl;
  final String? albumid;
  final List<Artist>? artists;
  final String? cacheState;
  final String? copyrightText;
  final String? duration;
  final String? encryptedDrmMediaUrl;
  final String? encryptedMediaPath;
  final String? encryptedMediaUrl;
  final int? explicitContent;
  final String? featuredArtists;
  final String? featuredArtistsId;
  final String? hasLyrics;
  final String? id;
  final String? image;
  final bool? isDolbyContent;
  final int? isDrm;
  final String? label;
  final String? labelId;
  final String? labelUrl;
  final String? language;
  final dynamic lyrics;
  final String? lyricsSnippet;
  final String? mediaPreviewUrl;
  final String? mediaUrl;
  final String? music;
  final String? musicId;
  final String? origin;
  final String? permaUrl;
  final int? playCount;
  final String? primaryArtists;
  final String? primaryArtistsId;
  final String? releaseDate;
  final Rights? rights;
  final String? singers;
  final String? song;
  final String? starred;
  final String? starring;
  final bool? trillerAvailable;
  final String? type;
  final String? vcode;
  final String? vlink;
  final bool? webp;
  final String? year;

  factory OnlineSongModel.fromJson(Map<String, dynamic> json) {
    final rawArtistMap = json['artistMap'] as Map<String, dynamic>?;

    final artistList = rawArtistMap == null
        ? <Artist>[]
        : rawArtistMap.entries
              .map((e) => Artist(name: e.key, id: e.value.toString()))
              .toList();

    return OnlineSongModel(
      the320Kbps: json["320kbps"],
      album: json["album"],
      albumUrl: json["album_url"],
      albumid: json["albumid"],
      artists: artistList,
      cacheState: json["cache_state"],
      copyrightText: json["copyright_text"],
      duration: json["duration"],
      encryptedDrmMediaUrl: json["encrypted_drm_media_url"],
      encryptedMediaPath: json["encrypted_media_path"],
      encryptedMediaUrl: json["encrypted_media_url"],
      explicitContent: _toInt(json["explicit_content"]),
      featuredArtists: json["featured_artists"],
      featuredArtistsId: json["featured_artists_id"],
      hasLyrics: json["has_lyrics"],
      id: json["id"],
      image: json["image"],
      isDolbyContent: json["is_dolby_content"],
      isDrm: _toInt(json["is_drm"]),
      label: json["label"],
      labelId: json["label_id"],
      labelUrl: json["label_url"],
      language: json["language"],
      lyrics: json["lyrics"],
      lyricsSnippet: json["lyrics_snippet"],
      mediaPreviewUrl: json["media_preview_url"],
      mediaUrl: json["media_url"],
      music: json["music"],
      musicId: json["music_id"],
      origin: json["origin"],
      permaUrl: json["perma_url"],
      playCount: _toInt(json["play_count"]),
      primaryArtists: json["primary_artists"],
      primaryArtistsId: json["primary_artists_id"],
      releaseDate: json["release_date"],
      rights: json["rights"] == null ? null : Rights.fromJson(json["rights"]),
      singers: json["singers"],
      song: json["song"],
      starred: json["starred"],
      starring: json["starring"],
      trillerAvailable: json["triller_available"],
      type: json["type"],
      vcode: json["vcode"],
      vlink: json["vlink"],
      webp: json["webp"],
      year: json["year"],
    );
  }

  Map<String, dynamic> toJson() => {
    "320kbps": the320Kbps,
    "album": album,
    "album_url": albumUrl,
    "albumid": albumid,
    "artistMap": artists!.map((e) => e.toMap()),
    "cache_state": cacheState,
    "copyright_text": copyrightText,
    "duration": duration,
    "encrypted_drm_media_url": encryptedDrmMediaUrl,
    "encrypted_media_path": encryptedMediaPath,
    "encrypted_media_url": encryptedMediaUrl,
    "explicit_content": explicitContent,
    "featured_artists": featuredArtists,
    "featured_artists_id": featuredArtistsId,
    "has_lyrics": hasLyrics,
    "id": id,
    "image": image,
    "is_dolby_content": isDolbyContent,
    "is_drm": isDrm,
    "label": label,
    "label_id": labelId,
    "label_url": labelUrl,
    "language": language,
    "lyrics": lyrics,
    "lyrics_snippet": lyricsSnippet,
    "media_preview_url": mediaPreviewUrl,
    "media_url": mediaUrl,
    "music": music,
    "music_id": musicId,
    "origin": origin,
    "perma_url": permaUrl,
    "play_count": playCount,
    "primary_artists": primaryArtists,
    "primary_artists_id": primaryArtistsId,
    "release_date": releaseDate,
    "rights": rights?.toJson(),
    "singers": singers,
    "song": song,
    "starred": starred,
    "starring": starring,
    "triller_available": trillerAvailable,
    "type": type,
    "vcode": vcode,
    "vlink": vlink,
    "webp": webp,
    "year": year,
  };

  MediaItem toMediaItem() {
    final artistNames = artists?.map((e) => e.name).join(", ");
    return MediaItem(
      id: id ?? "",
      title: song ?? "",
      album: album,
      artist: (artistNames?.isNotEmpty == true)
          ? artistNames
          : (singers?.isNotEmpty == true)
          ? singers
          : (primaryArtists?.isNotEmpty == true)
          ? primaryArtists
          : "Unknown Artist",
      artUri: image != null ? Uri.parse(image!) : null,
      duration: duration != null
          ? Duration(milliseconds: int.parse(duration!) * 1000)
          : null,

      extras: {
        "isOnline": true,
        "mediaUrl": mediaUrl,
        "image": image,
        "isHD": the320Kbps?.toLowerCase() == "true",
        "album": album,
        "has_lyrics": hasLyrics?.toLowerCase() == "true",
        "release_date": releaseDate,
        "artists": artists?.map((e) => e.toMap()).toList(),
        "language": language ?? '',
      },
    );
  }

  @override
  String toString() {
    return "$the320Kbps, $album, $albumUrl, $albumid, $artists, $cacheState, $copyrightText, $duration, $encryptedDrmMediaUrl, $encryptedMediaPath, $encryptedMediaUrl, $explicitContent, $featuredArtists, $featuredArtistsId, $hasLyrics, $id, $image, $isDolbyContent, $isDrm, $label, $labelId, $labelUrl, $language, $lyrics, $lyricsSnippet, $mediaPreviewUrl, $mediaUrl, $music, $musicId, $origin, $permaUrl, $playCount, $primaryArtists, $primaryArtistsId, $releaseDate, $rights, $singers, $song, $starred, $starring, $trillerAvailable, $type, $vcode, $vlink, $webp, $year, ";
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

class Artist {
  final String name;
  final String id;

  Artist({required this.name, required this.id});

  Map<String, dynamic> toMap() {
    return {'name': name, 'id': id};
  }

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(name: map['name'] ?? '', id: map['id'] ?? '');
  }
}

class Rights {
  Rights({
    required this.cacheable,
    required this.code,
    required this.deleteCachedObject,
    required this.reason,
  });

  final bool? cacheable;
  final int? code;
  final bool? deleteCachedObject;
  final String? reason;

  factory Rights.fromJson(Map<String, dynamic> json) {
    return Rights(
      cacheable: json["cacheable"],
      code: json["code"],
      deleteCachedObject: json["delete_cached_object"],
      reason: json["reason"],
    );
  }

  Map<String, dynamic> toJson() => {
    "cacheable": cacheable,
    "code": code,
    "delete_cached_object": deleteCachedObject,
    "reason": reason,
  };

  @override
  String toString() {
    return "$cacheable, $code, $deleteCachedObject, $reason, ";
  }
}
