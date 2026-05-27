import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataMigrationService {
  static final _firestore = FirebaseFirestore.instance;

  /// Migrates user data from old Google ID structure to new Firebase UID structure
  ///
  /// This checks if data exists under the old ID and migrates it to the new UID
  static Future<void> migrateUserData({
    required String oldGoogleId,
    required String newFirebaseUid,
  }) async {
    // Skip if IDs are the same (shouldn't happen but safety check)
    if (oldGoogleId == newFirebaseUid) {
      log('IDs are identical, no migration needed');
      return;
    }

    try {
      log('Starting migration from $oldGoogleId to $newFirebaseUid');

      // Check if old user data exists
      final oldUserDoc = await _firestore
          .collection('users')
          .doc(oldGoogleId)
          .get();

      if (!oldUserDoc.exists) {
        log('No old user data found, skipping migration');
        return;
      }

      // Check if new user already has data (to avoid overwriting)
      final newUserDoc = await _firestore
          .collection('users')
          .doc(newFirebaseUid)
          .get();

      if (newUserDoc.exists) {
        log('New user data already exists, checking for migration flag');
        final migrationComplete =
            newUserDoc.data()?['migrationComplete'] ?? false;

        if (migrationComplete) {
          log('Migration already completed previously');
          return;
        }
      }

      // Start batch write for atomic operation
      final batch = _firestore.batch();
      await _migrateStats(
        oldGoogleId: oldGoogleId,
        newFirebaseUid: newFirebaseUid,
        batch: batch,
      );
      // 1. Migrate favorites
      await _migrateFavorites(oldGoogleId, newFirebaseUid, batch);

      // 2. Migrate playlists
      await _migratePlaylists(oldGoogleId, newFirebaseUid, batch);

      // 3. Migrate recently played
      await _migrateRecentlyPlayed(oldGoogleId, newFirebaseUid, batch);

      // 4. Mark migration as complete in new user doc
      final newUserRef = _firestore.collection('users').doc(newFirebaseUid);
      batch.set(newUserRef, {
        'migrationComplete': true,
        'migratedFrom': oldGoogleId,
        'migrationDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 5. Mark old user doc as migrated (but don't delete for safety)
      final oldUserRef = _firestore.collection('users').doc(oldGoogleId);
      batch.update(oldUserRef, {
        'migratedTo': newFirebaseUid,
        'migrationDate': FieldValue.serverTimestamp(),
      });

      // Commit all changes atomically
      await batch.commit();
      // Call this only after verifying migration succeeded
      // await UserDataMigrationService.deleteOldUserData(oldGoogleId);
      log('Migration completed successfully');
    } catch (e, stack) {
      log('Migration failed: $e', stackTrace: stack);
      // Don't rethrow - allow login to continue even if migration fails
    }
  }

  static Future<void> _migrateFavorites(
    String oldId,
    String newId,
    WriteBatch batch,
  ) async {
    try {
      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(oldId)
          .collection('favorites')
          .get();

      if (favoritesSnapshot.docs.isEmpty) {
        log('No favorites to migrate');
        return;
      }

      log('Migrating ${favoritesSnapshot.docs.length} favorites');

      for (final doc in favoritesSnapshot.docs) {
        final newDocRef = _firestore
            .collection('users')
            .doc(newId)
            .collection('favorites')
            .doc(doc.id);

        batch.set(newDocRef, doc.data());
      }
    } catch (e) {
      log('Error migrating favorites: $e');
    }
  }

  static Future<void> _migrateStats({
    required String oldGoogleId,
    required String newFirebaseUid,
    required WriteBatch batch,
  }) async {
    try {
      final oldUserSnap = await _firestore
          .collection('users')
          .doc(oldGoogleId)
          .get();

      if (!oldUserSnap.exists) return;

      final oldData = oldUserSnap.data();
      if (oldData == null || !oldData.containsKey('stats')) {
        log('No stats found to migrate');
        return;
      }

      final stats = oldData['stats'];

      if (stats is Map<String, dynamic>) {
        final newUserRef = _firestore.collection('users').doc(newFirebaseUid);

        batch.set(newUserRef, {'stats': stats}, SetOptions(merge: true));

        log('Stats migrated successfully');
      }
    } catch (e, stack) {
      log('Error migrating stats: $e', stackTrace: stack);
    }
  }

  static Future<void> _migratePlaylists(
    String oldId,
    String newId,
    WriteBatch batch,
  ) async {
    try {
      final playlistsSnapshot = await _firestore
          .collection('users')
          .doc(oldId)
          .collection('playlists')
          .get();

      if (playlistsSnapshot.docs.isEmpty) {
        log('No playlists to migrate');
        return;
      }

      log('Migrating ${playlistsSnapshot.docs.length} playlists');

      for (final playlistDoc in playlistsSnapshot.docs) {
        final newPlaylistRef = _firestore
            .collection('users')
            .doc(newId)
            .collection('playlists')
            .doc(playlistDoc.id);

        // 1️⃣ Copy playlist document
        batch.set(newPlaylistRef, playlistDoc.data());

        // 2️⃣ Copy songs subcollection
        await _migratePlaylistSongs(
          oldId: oldId,
          newId: newId,
          playlistId: playlistDoc.id,
        );
      }
    } catch (e, stack) {
      log('Error migrating playlists: $e', stackTrace: stack);
    }
  }

  static Future<void> _migratePlaylistSongs({
    required String oldId,
    required String newId,
    required String playlistId,
  }) async {
    try {
      final songsSnapshot = await _firestore
          .collection('users')
          .doc(oldId)
          .collection('playlists')
          .doc(playlistId)
          .collection('songs')
          .get();

      if (songsSnapshot.docs.isEmpty) {
        return;
      }

      log(
        'Migrating ${songsSnapshot.docs.length} songs for playlist $playlistId',
      );

      final batch = _firestore.batch();

      for (final songDoc in songsSnapshot.docs) {
        final newSongRef = _firestore
            .collection('users')
            .doc(newId)
            .collection('playlists')
            .doc(playlistId)
            .collection('songs')
            .doc(songDoc.id);

        batch.set(newSongRef, songDoc.data());
      }

      await batch.commit();
    } catch (e, stack) {
      log(
        'Error migrating songs for playlist $playlistId: $e',
        stackTrace: stack,
      );
    }
  }

  static Future<void> _migrateRecentlyPlayed(
    String oldId,
    String newId,
    WriteBatch batch,
  ) async {
    try {
      final recentlyPlayedSnapshot = await _firestore
          .collection('users')
          .doc(oldId)
          .collection('recently_played')
          .get();

      if (recentlyPlayedSnapshot.docs.isEmpty) {
        log('No recently played to migrate');
        return;
      }

      log(
        'Migrating ${recentlyPlayedSnapshot.docs.length} recently played items',
      );

      for (final doc in recentlyPlayedSnapshot.docs) {
        final newDocRef = _firestore
            .collection('users')
            .doc(newId)
            .collection('recently_played')
            .doc(doc.id);

        batch.set(newDocRef, doc.data());
      }
    } catch (e) {
      log('Error migrating recently played: $e');
    }
  }

  /// Optional: Clean up old user data after successful migration
  /// Only call this after confirming migration was successful
  static Future<void> deleteOldUserData(String oldGoogleId) async {
    try {
      log('Deleting old user data for $oldGoogleId');

      // Delete subcollections
      await _deleteCollection('users/$oldGoogleId/favorites');
      await _deleteCollection('users/$oldGoogleId/playlists');
      await _deleteCollection('users/$oldGoogleId/recently_played');

      // Delete user document
      await _firestore.collection('users').doc(oldGoogleId).delete();

      log('Old user data deleted successfully');
    } catch (e) {
      log('Error deleting old user data: $e');
    }
  }

  static Future<void> _deleteCollection(String path) async {
    final snapshot = await _firestore.collection(path).get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
