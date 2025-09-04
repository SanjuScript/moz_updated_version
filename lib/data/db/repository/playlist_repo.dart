import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/playlist_model.dart';
import 'package:moz_updated_version/data/db/repository/playlist_ab_repo.dart';

class PlaylistRepository implements PlaylistAbRepo {
  final Box<Playlist> _box = Hive.box<Playlist>('playlists');
  

  @override
  List<Playlist> getPlaylists() => _box.values.toList();

  @override
  Future<void> createPlaylist(String name) async {
    final playlist = Playlist(name: name, songIds: []);
    await _box.add(playlist);
  }

  @override
  Future<void> deletePlaylist(int index) async {
    await _box.deleteAt(index);
  }

  @override
  Future<void> addSongToPlaylist(int playlistIndex, int songId) async {
    final playlist = _box.getAt(playlistIndex);
    if (playlist != null) {
      playlist.songIds.add(songId);
      await playlist.save();
    }
  }

  @override
  Future<void> removeSongFromPlaylist(int playlistIndex, int songId) async {
    final playlist = _box.getAt(playlistIndex);
    if (playlist != null) {
      playlist.songIds.remove(songId);
      await playlist.save();
    }
  }
}
