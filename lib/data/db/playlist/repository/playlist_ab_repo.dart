import 'package:moz_updated_version/data/db/playlist/playlist_model.dart';

abstract class PlaylistAbRepo {
  List<Playlist> getPlaylists();
  Future<void> createPlaylist(String name);
  Future<void> deletePlaylist(int index);
  Future<void> addSongToPlaylist(int playlistIndex, int songId);
  Future<void> removeSongFromPlaylist(int playlistIndex, int songId);
}
