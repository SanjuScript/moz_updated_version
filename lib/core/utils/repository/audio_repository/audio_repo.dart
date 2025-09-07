import 'package:on_audio_query/on_audio_query.dart';

abstract class AudioRepository {

  List<SongModel> get currentPlaylist;
  
  /// Load all songs from device
  Future<List<SongModel>> loadSongs();

  /// Play a single song
  Future<void> playSong(SongModel song);

  /// Set and play a playlist
  Future<void> setPlaylist(List<SongModel> songs, {int startIndex = 0});

  /// Playback controls
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> next();
  Future<void> previous();
  Future<void> seek(Duration position);
  Future<void> playExternal(String path);
}
