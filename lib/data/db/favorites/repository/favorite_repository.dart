import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/favorites/repository/favorite_ab.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavoriteRepository implements FavoriteAbRepo {
  final Box<Map> _box = Hive.box<Map>('FavoriteDB');

  @override
  ValueNotifier<List<SongModel>> favoriteItems = ValueNotifier([]);

  @override
  Future<void> init() async {
    await load();
  }

  @override
  Future<void> add(SongModel song) async {
    final songMap = Map<String, dynamic>.from(song.getMap);
    await _box.put(song.id.toString(), songMap);

    final current = List<SongModel>.from(favoriteItems.value);
    current.removeWhere((i) => i.id == song.id);
    current.insert(0, SongModel(songMap));

    favoriteItems.value = current;
    favoriteItems.notifyListeners();
  }

  @override
  Future<void> remove(String id) async {
    await _box.delete(id);
    favoriteItems.value.removeWhere((s) => s.id.toString() == id);
    favoriteItems.notifyListeners();
  }

  @override
  Future<void> load() async {
    final items = _box.values.toList();
    favoriteItems.value = items.map((map) => SongModel(map)).toList();
  }

  @override
  Future<void> clear() async {
    await _box.clear();
    favoriteItems.value.clear();
  }

  @override
  bool isFavorite(String id) {
    return favoriteItems.value.any((s) => s.id.toString() == id);
  }
}
