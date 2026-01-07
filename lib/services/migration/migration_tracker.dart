import 'package:hive/hive.dart';

class MigrationTrackerService {
  static const String _boxName = 'migration_tracker';
  static Box? _box;

  static Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  static bool isCompleted(String migrationId) {
    return _box?.get(migrationId, defaultValue: false) ?? false;
  }

  static Future<void> markCompleted(String migrationId) async {
    await _box?.put(migrationId, true);
  }

  static Future<void> reset(String migrationId) async {
    await _box?.delete(migrationId);
  }

  static Future<void> resetAll() async {
    await _box?.clear();
  }

  static List<String> getAllCompletedMigrations() {
    if (_box == null) return [];
    return _box!.keys.cast<String>().toList();
  }
}

// ==================== MIGRATION IDS ====================
class MigrationIds {
  static const String playlistMetadata = 'playlist_metadata_v1';
  static const String songThumbnails = 'song_thumbnails_v1';
  // Add future migrations here...
}
