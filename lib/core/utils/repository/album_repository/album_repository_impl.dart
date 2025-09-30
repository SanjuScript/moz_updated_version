import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'album_repository.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  Future<List<AlbumModel>> loadAlbums() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      permissionStatus = await _audioQuery.permissionsRequest();
    }
    if (!permissionStatus) {
      throw Exception("Permission denied to access audio files");
    }

    final allAlbums = await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
    );

    return allAlbums.where((album) {
      final albumName = album.album.toLowerCase();
      return !albumName.contains("whatsapp") &&
          !albumName.contains("telegram") &&
          !albumName.contains("recording") &&
          !RegExp(r'^\d+$').hasMatch(albumName);
    }).toList();
  }

  @override
  Future<AlbumModel?> getAlbumById(int id) async {
    final albums = await loadAlbums();
    try {
      return albums.firstWhere((album) => album.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SongModel>> getSongsFromAlbum(int albumId) async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      permissionStatus = await _audioQuery.permissionsRequest();
    }
    if (!permissionStatus) {
      throw Exception("Permission denied to access audio files");
    }

    final removedBox = Hive.box<Map>('RemovedDB');
    final removedSongIds = removedBox.keys.map((k) => k.toString()).toSet();
    final settingsBox = Hive.box('settingsBox');
    final excludedFolders =
        (settingsBox.get('selected_folders', defaultValue: <String>[]) as List)
            .cast<String>();
    final minDuration =
        settingsBox.get('min_audio_duration', defaultValue: 5.0) as double;

    final allSongs = await _audioQuery.queryAudiosFrom(
      AudiosFromType.ALBUM_ID,
      albumId,
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.ASC_OR_SMALLER,
    );

    final filtered = allSongs.where((song) {
      final name = song.displayName.toLowerCase();
      final songPath = song.data.toLowerCase();

      final isInExcludedFolder = excludedFolders.any(
        (folder) => songPath.startsWith(folder.toLowerCase()),
      );

      final isTooShort = (song.duration ?? 0) < (minDuration * 1000);

      return !removedSongIds.contains(song.id.toString()) &&
          !isInExcludedFolder &&
          !isTooShort &&
          !name.contains(".opus") &&
          !name.contains("aud") &&
          !name.contains("recordings") &&
          !name.contains("recording") &&
          !name.contains("midi") &&
          !name.contains("pxl") &&
          !name.contains("record") &&
          !name.contains("vid") &&
          !name.contains("whatsapp");
    }).toList();

    return filtered;
  }
}
