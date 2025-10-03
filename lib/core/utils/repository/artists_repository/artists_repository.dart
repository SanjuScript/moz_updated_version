import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/core/utils/repository/artists_repository/artists_repo.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  Future<List<ArtistModel>> loadArtists() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      permissionStatus = await _audioQuery.permissionsRequest();
    }
    if (!permissionStatus) {
      throw Exception("Permission denied to access audio files");
    }

    final allArtists = await _audioQuery.queryArtists(
      sortType: ArtistSortType.ARTIST,
      orderType: OrderType.ASC_OR_SMALLER,
    );

    return allArtists.where((artist) {
      final artistName = artist.artist.toLowerCase();
      return !artistName.contains("unknown") &&
             !artistName.contains("recording") &&
             !artistName.contains("whatsapp");
    }).toList();
  }

  @override
  Future<ArtistModel?> getArtistById(int id) async {
    final artists = await loadArtists();
    try {
      return artists.firstWhere((artist) => artist.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SongModel>> getSongsFromArtist(int artistId) async {
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
      AudiosFromType.ARTIST_ID,
      artistId,
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
