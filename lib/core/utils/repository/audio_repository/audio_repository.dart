import 'dart:developer';

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
    bool permissionStatus = await audioQuery.permissionsStatus();
    if (!permissionStatus) {
      permissionStatus = await audioQuery.permissionsRequest();
    }

    if (!permissionStatus) {
      throw Exception("Permission denied to access audio files");
    }

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
  Future<void> addToQueue(SongModel song) async {
    final mediaItem = song.toMediaItem();
    await audioHandler.addQueueItem(mediaItem);
  }

  @override
  Future<void> removeFromQueue(SongModel song) async {
    try {
      final mediaItem = audioHandler.queue.value.firstWhere(
        (item) => item.id == song.id.toString(),
      );
      await audioHandler.removeQueueItem(mediaItem);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Future<void> playNext(SongModel song) async {
    final mediaItem = song.toMediaItem();
    await audioHandler.playNext(mediaItem);
  }

  @override
  Future<void> setPlaylist(List<SongModel> songs, {int startIndex = 0}) async {
    _currentPlaylist = songs;
    await audioHandler.setPlaylist(songs, index: startIndex);
    await audioHandler.skipToQueueItem(startIndex);
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

  @override
  Future<void> setRepeat(AudioServiceRepeatMode repeatMode) =>
      audioHandler.setRepeatMode(repeatMode);

  @override
  Future<void> setShuffle(AudioServiceShuffleMode shuffleMode) =>
      audioHandler.setShuffleMode(shuffleMode);
  @override
  Future<void> setSpeed(double speed) => audioHandler.setSpeed(speed);

  @override
  Future<void> setVolume(double volume) => audioHandler.setVolume(volume);
}
