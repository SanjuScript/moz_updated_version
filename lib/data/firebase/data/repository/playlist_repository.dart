import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moz_updated_version/data/model/online_models/playlist_model.dart';
import 'package:moz_updated_version/data/model/song_playlist_model/online_song_playlist.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/services/migration/playlist_migration.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class OnlinePlaylistRepository {
  OnlinePlaylistRepository._();
  static final instance = OnlinePlaylistRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PlaylistMigrationService _migrationService = PlaylistMigrationService();

  String? get _uid => sl<UserStorageAbRepo>().userID;

  CollectionReference<Map<String, dynamic>> _playlistRef() {
    final uid = _uid;
    if (uid == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(uid).collection('playlists');
  }

  Future<void> initialize() async {
    await _migrationService.checkAndMigrate();
  }

  /// Create playlist
  Future<String> createPlaylist(String name) async {
    final doc = await _playlistRef().add({
      "name": name,
      "createdAt": FieldValue.serverTimestamp(),
      "songCount": 0,
      "recentThumbnails": [],
    });
    return doc.id;
  }

  /// Delete playlist
  Future<void> deletePlaylist(String playlistId) async {
    final playlistDoc = _playlistRef().doc(playlistId);
    final songsCollection = playlistDoc.collection('songs');

    final songsSnapshot = await songsCollection.get();

    final batch = _firestore.batch();

    for (var doc in songsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(playlistDoc);

    await batch.commit();
  }

  //rename playlist
  Future<void> updatePlaylistName({
    required String playlistId,
    required String newName,
  }) async {
    await _playlistRef().doc(playlistId).update({
      'name': newName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add song to playlist
  Future<void> addSongToPlaylist({
    required String playlistId,
    required String songId,
    required String thumbnailUrl,
  }) async {
    final songsRef = _playlistRef().doc(playlistId).collection('songs');
    final countSnap = await songsRef.count().get();

    await songsRef.doc(songId).set({
      "order": countSnap.count,
      "addedAt": FieldValue.serverTimestamp(),
      "thumbnailUrl": thumbnailUrl,
    });
    _updatePlaylistMetadata(playlistId);
  }

  Future<void> _updatePlaylistMetadata(String playlistId) async {
    final songsRef = _playlistRef().doc(playlistId).collection('songs');

    final countSnap = await songsRef.count().get();
    final songCount = countSnap.count ?? 0;

    final recentSongs = await songsRef
        .orderBy('addedAt', descending: true)
        .limit(4)
        .get();

    final thumbnails = recentSongs.docs
        .map((doc) => doc.data()['thumbnailUrl'] as String?)
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .toList();

    await _playlistRef().doc(playlistId).update({
      'songCount': songCount,
      'recentThumbnails': thumbnails,
      'updatedAt': FieldValue.serverTimestamp(),
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
    _updatePlaylistMetadata(playlistId);
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
