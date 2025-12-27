import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/model/download_song/download_song_model.dart';

class DownloadSongRepository {
  static const String _boxName = 'songDownloads';
  static final Box<DownloadedSongModel> _box = Hive.box<DownloadedSongModel>(
    'songDownloads',
  );

  static Future<void> addSong(DownloadedSongModel song) async {
    if (song.pid != null) {
      final alreadyExists = _box.values.any((e) => e.pid == song.pid);
      if (alreadyExists) {
        return;
      }
    }
    await _box.put(song.id, song);
  }

  static List<DownloadedSongModel> getAllSongs() {
    return _box.values.toList()
      ..sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
  }

  static DownloadedSongModel? getSong(int id) {
    return _box.get(id);
  }

  static bool isDownloaded(int id) {
    return _box.containsKey(id);
  }

  static Future<void> deleteSong(int id) async {
    await _box.delete(id);
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }

  static int get count => _box.length;
}
