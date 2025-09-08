import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repo.dart';
import 'package:moz_updated_version/main.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioRepositoryImpl implements AudioRepository {
  final OnAudioQuery audioQuery = OnAudioQuery();
  List<SongModel> _currentPlaylist = [];

  @override
  List<SongModel> get currentPlaylist => _currentPlaylist;

  @override
  Future<List<SongModel>> loadSongs() async {
    // Always check & request
    bool permissionStatus = await audioQuery.permissionsStatus();
    if (!permissionStatus) {
      permissionStatus = await audioQuery.permissionsRequest();
    }

    if (!permissionStatus) {
      throw Exception("Permission denied to access audio files");
    }

    // Now query safely
    final allSongs = await audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
    );

    final filtered = allSongs.where((song) {
      final name = song.displayName.toLowerCase();
      return !name.contains(".opus") &&
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

  @override
  Future<void> playExternal(String path) async {
    final uri = Uri.file(path);
    await audioHandler.setExternalSource(uri);
    await audioHandler.play();
  }

  @override
  Future<void> playSong(SongModel song) async {
    MediaItem? media;
    try {
      media = audioHandler.queue.value.firstWhere(
        (item) => item.id == song.id.toString(),
      );
    } catch (_) {
      media = song.toMediaItem();
    }

    final uri = song.uri ?? media.extras?['uri'] ?? '';
    if (uri.isEmpty) throw Exception("Song URI missing");

    await audioHandler.playSong(uri, media);
  }

  @override
  Future<void> setPlaylist(List<SongModel> songs, {int startIndex = 0}) async {
    _currentPlaylist = songs;
    await audioHandler.setPlaylist(songs);
    await audioHandler.playFromIndex(startIndex);
  }

  @override
  Future<void> play() => audioHandler.play();

  @override
  Future<void> pause() => audioHandler.pause();

  @override
  Future<void> stop() => audioHandler.stop();

  @override
  Future<void> next() => audioHandler.skipToNext();

  @override
  Future<void> previous() => audioHandler.skipToPrevious();

  @override
  Future<void> seek(Duration position) => audioHandler.seek(position);
}
