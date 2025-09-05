import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/recently_played/repository/recent_ab_repo.dart';
import 'package:on_audio_query/on_audio_query.dart';

class RecentlyPlayedRepository implements RecentAbRepo {
  final Box<Map> _box = Hive.box<Map>('RecentDB');

  @override
  ValueNotifier<List<SongModel>> recentItems = ValueNotifier([]);

  @override
  Future<void> init() async {
    
    await load();
  }

  @override
  Future<void> add(SongModel song) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final songMap = Map<String, dynamic>.from(song.getMap);
    songMap["playedAt"] = timestamp;

    await _box.put(song.id, songMap);

    final current = List<SongModel>.from(recentItems.value);
    current.removeWhere((i) => i.id == song.id);
    current.insert(0, SongModel(songMap));

    if (current.length > 100) {
      current.removeRange(100, current.length);
    }

    recentItems.value = current;
    recentItems.notifyListeners();
  }

  @override
  Future<void> load() async {
    
    final items = _box.values.toList();
    items.sort(
      (a, b) => (b["playedAt"] as int).compareTo(a["playedAt"] as int),
    );

    recentItems.value = items.map((map) {
      return SongModel(map);
    }).toList();
  }

  @override
  Future<void> clear() async {
    await _box.clear();
    recentItems.value.clear();
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
    recentItems.value.removeWhere((item) => item.id == id);
    recentItems.notifyListeners();
  }
}
