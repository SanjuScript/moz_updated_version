import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/mostly_played/repository/mostly_played_ab.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';

class MostlyPlayedRepository implements MostlyPlayedRepo {
  final Box<Map> _box = Hive.box<Map>('MostlyPlayedDB');

  @override
  ValueNotifier<List<SongModel>> mostPlayedItems = ValueNotifier([]);

  @override
  Future<void> init() async {
    await load();
  }

  @override
  Future<void> add(MediaItem item) async {
    final song = item.toSongModel();
    final songId = song.id.toString();

    final existing = _box.get(songId);

    Map<String, dynamic> songMap;
    if (existing != null) {
      songMap = Map<String, dynamic>.from(existing);
      songMap["playCount"] = (songMap["playCount"] ?? 0) + 1;
    } else {
      songMap = Map<String, dynamic>.from(song.getMap);
      songMap["playCount"] = 1;

      if (item.extras != null && item.extras!["uri"] != null) {
        songMap["_uri"] = item.extras!["uri"];
      }
    }
    songMap["addedAt"] = DateTime.now().millisecondsSinceEpoch;

    if (_box.length >= 100) {
      final leastPlayedEntry = _box.values.reduce((a, b) {
        final countA = a["playCount"] as int? ?? 0;
        final countB = b["playCount"] as int? ?? 0;

        if (countA == countB) {
          final addedAtA = a["addedAt"] as int? ?? 0;
          final addedAtB = b["addedAt"] as int? ?? 0;
          return addedAtA < addedAtB ? a : b;
        }
        return countA < countB ? a : b;
      });

      final leastPlayedId = leastPlayedEntry["_id"]?.toString();
      if (leastPlayedId != null) {
        await _box.delete(leastPlayedId);
      }
    }

    await _box.put(songId, songMap);

    await load();
  }

  @override
  Future<void> load() async {
    final items = _box.values.toList();

    items.sort(
      (a, b) => (b["playCount"] as int).compareTo(a["playCount"] as int),
    );

    mostPlayedItems.value = items.map((map) => SongModel(map)).toList();
  }

  @override
  Future<void> clear() async {
    await _box.clear();
    mostPlayedItems.value.clear();
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
    mostPlayedItems.value.removeWhere((item) => item.id.toString() == id);
    mostPlayedItems.notifyListeners();
  }
}
