import 'dart:developer';

import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/core/app_services.dart';

import 'audio_playback_repository.dart';

class AudioPlaybackRepositoryImpl implements AudioPlaybackRepository {
  final MozAudioHandler _audioHandler;

  AudioPlaybackRepositoryImpl(this._audioHandler);

  @override
  Future<void> playOnlineSong(
    List<OnlineSongModel> songs, {
    required int startIndex,
  }) async {
    try {
      log('Playing online playlist from index $startIndex', name: 'AUDIO_REPO');

      await _audioHandler.setOnlinePlaylist(songs, index: startIndex);

      await _audioHandler.play();
    } catch (e, stack) {
      log('$e\n$stack', name: 'AUDIO_REPO');
      rethrow;
    }
  }

  @override
  Future<void> play() => _audioHandler.play();

  @override
  Future<void> pause() => _audioHandler.pause();

  @override
  Future<void> stop() => _audioHandler.stop();
}
