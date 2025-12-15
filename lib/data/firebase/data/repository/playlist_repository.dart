import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moz_updated_version/data/model/online_models/playlist_model.dart';
import 'package:moz_updated_version/data/model/song_playlist_model/online_song_playlist.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class OnlinePlaylistRepository {
  OnlinePlaylistRepository._();
  static final instance = OnlinePlaylistRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => sl<UserStorageAbRepo>().userID;

  CollectionReference<Map<String, dynamic>> _playlistRef() {
    final uid = _uid;
    if (uid == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(uid).collection('playlists');
  }

  /// Create playlist
  Future<String> createPlaylist(String name) async {
    final doc = await _playlistRef().add({
      "name": name,
      "createdAt": FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Delete playlist
  Future<void> deletePlaylist(String playlistId) async {
    await _playlistRef().doc(playlistId).delete();
  }

  /// Add song to playlist
  Future<void> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    final songsRef = _playlistRef().doc(playlistId).collection('songs');
    final countSnap = await songsRef.count().get();

    await songsRef.doc(songId).set({
      "order": countSnap.count,
      "addedAt": FieldValue.serverTimestamp(),
    });
  }

  /// Remove song
  Future<void> removeSong({
    required String playlistId,
    required String songId,
  }) async {
    await _playlistRef()
        .doc(playlistId)
        .collection('songs')
        .doc(songId)
        .delete();
  }

  /// Stream playlist song IDs
  Stream<List<String>> playlistSongIds(String playlistId) {
    return _playlistRef()
        .doc(playlistId)
        .collection('songs')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  Stream<List<PlaylistModelOnline>> playlistsStream() {
    return _playlistRef()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PlaylistModelOnline.fromDoc).toList());
  }

  Future<int?> getPlaylistCount() async {
    final playlistsRef = _playlistRef();
    final countSnap = await playlistsRef.count().get();
    return countSnap.count ?? 0;
  }
}
