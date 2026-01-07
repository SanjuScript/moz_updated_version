import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/services/migration/migration_tracker.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class PlaylistMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => sl<UserStorageAbRepo>().userID;

  CollectionReference<Map<String, dynamic>> _playlistRef() {
    final uid = _uid;
    if (uid == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(uid).collection('playlists');
  }

  Future<void> checkAndMigrate() async {
    if (_uid == null) {
      log('User not logged in, skipping migration');
      return;
    }

    final isCompleted = MigrationTrackerService.isCompleted(
      MigrationIds.playlistMetadata,
    );

    if (!isCompleted) {
      log('Starting playlist metadata migration...');
      await _migrateAllPlaylists();
      await MigrationTrackerService.markCompleted(
        MigrationIds.playlistMetadata,
      );
      log('Playlist metadata migration completed');
    } else {
      log('Playlist metadata already migrated');
    }
  }

  Future<void> _migrateAllPlaylists() async {
    try {
      final playlistsSnapshot = await _playlistRef().get();
      final totalPlaylists = playlistsSnapshot.docs.length;

      if (totalPlaylists == 0) {
        log('No playlists to migrate');
        return;
      }

      log('Found $totalPlaylists playlists to migrate');

      int migrated = 0;
      for (var playlistDoc in playlistsSnapshot.docs) {
        await _migratePlaylist(playlistDoc.id);
        migrated++;
        log('Progress: $migrated/$totalPlaylists');
      }

      log('Successfully migrated $migrated playlists');
    } catch (e) {
      log('Migration error: $e');
      rethrow;
    }
  }

  Future<void> _migratePlaylist(String playlistId) async {
    try {
      final playlistRef = _playlistRef().doc(playlistId);
      final playlistDoc = await playlistRef.get();
      final playlistData = playlistDoc.data();

      if (playlistData?['songCount'] != null) {
        log('Playlist $playlistId already migrated, skipping');
        return;
      }

      final songsRef = playlistRef.collection('songs');

      final countSnap = await songsRef.count().get();
      final songCount = countSnap.count ?? 0;

      final recentSongs = await songsRef
          .orderBy('addedAt', descending: true)
          .limit(4)
          .get();

      final thumbnails = <String>[];
      for (var songDoc in recentSongs.docs) {
        final thumbnailUrl = songDoc.data()['thumbnailUrl'] as String?;
        if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
          thumbnails.add(thumbnailUrl);
        }
      }

      await playlistRef.update({
        'songCount': songCount,
        'recentThumbnails': thumbnails,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      log(
        'Migrated playlist: $playlistId ($songCount songs, ${thumbnails.length} thumbnails)',
      );
    } catch (e) {
      log('Error migrating playlist $playlistId: $e');
    }
  }

  Future<void> forceMigration() async {
    await MigrationTrackerService.reset(MigrationIds.playlistMetadata);
    await checkAndMigrate();
  }
}
