import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';

abstract class AudioPlaybackRepository {
  Future<void> playOnlineSong(
    List<OnlineSongModel> songs, {
    required int startIndex,
  });

  Future<void> play();

  Future<void> pause();

  Future<void> stop();
}
