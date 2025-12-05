import 'dart:collection';

import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/playlist/playlist_model.dart';
import 'package:moz_updated_version/data/db/playlist/repository/playlist_ab_repo.dart';

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
  Future<void> deletePlaylist(int key) async {
    await _box.delete(key);
  }

  @override
  Future<void> deleteAllPlaylist() async {
    await _box.clear();
  }

  @override
  Playlist? getPlaylist(int key) {
    return _box.get(key);
  }

  @override
  Future<void> addSongsToPlaylist(int playlistKey, List<int> songIds) async {
    final playlist = _box.get(playlistKey);
    if (playlist != null) {
      final mergedSet = LinkedHashSet<int>.from(playlist.songIds);
      mergedSet.addAll(songIds.where((id) => !mergedSet.contains(id)));
      playlist.songIds = mergedSet.toList();
      await playlist.save();
    }
  }

  @override
  Future<void> addSongToPlaylist(int key, int songId) async {
    final playlist = _box.get(key);
    if (playlist != null) {
      if (!playlist.songIds.contains(songId)) {
        playlist.songIds.add(songId);
        await playlist.save();
      }
    }
  }

  @override
  Future<void> removeSongsFromPlaylist(int key, List<int> songIds) async {
    final playlist = _box.get(key);
    if (playlist == null) return;

    final updated = playlist.songIds
        .where((id) => !songIds.contains(id))
        .toList();
    playlist.songIds = updated;
    await playlist.save();
  }

  @override
  Future<void> editPlaylist(int key, String newName) async {
    final playlist = _box.get(key);
    if (playlist != null) {
      playlist.name = newName;
      await playlist.save();
    }
  }

  @override
  Future<void> removeSongFromPlaylist(int key, int songId) async {
    final playlist = _box.get(key);
    if (playlist != null) {
      playlist.songIds.remove(songId);
      await playlist.save();
    }
  }
}
