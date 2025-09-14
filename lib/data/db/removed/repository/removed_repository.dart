import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/removed/repository/removed_ab_repo.dart';
import 'package:on_audio_query/on_audio_query.dart';

class RemovedRepository implements RemovedAbRepo {
  final Box<Map> _box = Hive.box<Map>('RemovedDB');

  @override
  ValueNotifier<List<SongModel>> removedItems = ValueNotifier([]);

  @override
  Future<void> init() async {
    await load();
  }

  @override
  Future<void> add(SongModel song) async {
    final songMap = Map<String, dynamic>.from(song.getMap);
    await _box.put(song.id.toString(), songMap);

    final current = List<SongModel>.from(removedItems.value);
    current.removeWhere((i) => i.id == song.id);
    current.insert(0, SongModel(songMap));

    removedItems.value = current;
    removedItems.notifyListeners();
  }

  @override
  Future<void> remove(String id) async {
    await _box.delete(id);
    removedItems.value.removeWhere((s) => s.id.toString() == id);
    removedItems.notifyListeners();
  }

  @override
  Future<void> load() async {
    final items = _box.values.toList();
    removedItems.value = items.map((map) => SongModel(map)).toList();
  }

  @override
  Future<void> clear() async {
    await _box.clear();
    removedItems.value.clear();
  }

  @override
  bool isRemoved(String id) {
    return removedItems.value.any((s) => s.id.toString() == id);
  }
}
