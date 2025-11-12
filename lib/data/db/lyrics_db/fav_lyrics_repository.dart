import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/lyrics_db/fav_lyrics_db.dart';

class FavoriteLyricsRepository implements FavoriteLyricsAbRepo {
  static const String _boxName = 'FavoriteLyricsDB';
  final Box<String> _box = Hive.box<String>(_boxName);

  @override
  ValueNotifier<Map<int, String>> favoriteLyrics = ValueNotifier({});

  @override
  Future<void> init() async {
    _loadFromBox();
  }

  void _loadFromBox() {
    final data = <int, String>{};
    for (var entry in _box.toMap().entries) {
      final songId = int.tryParse(entry.key.toString());
      if (songId != null) data[songId] = entry.value;
    }

    favoriteLyrics.value = data;
    favoriteLyrics.notifyListeners();
  }

  @override
  Future<void> addFavoriteLyric(int songId, String lyrics) async {
    await _ensureInitialized();
    await _box!.put(songId.toString(), lyrics);
    favoriteLyrics.value[songId] = lyrics;
    favoriteLyrics.notifyListeners();
  }

  @override
  Future<void> removeFavoriteLyric(int songId) async {
    await _ensureInitialized();
    await _box!.delete(songId.toString());
    favoriteLyrics.value.remove(songId);
    favoriteLyrics.notifyListeners();
  }

  @override
  bool isFavoriteLyric(int songId) {
    return favoriteLyrics.value.containsKey(songId);
  }

  @override
  Future<void> clear() async {
    await _ensureInitialized();
    await _box!.clear();
    favoriteLyrics.value.clear();
    favoriteLyrics.notifyListeners();
  }

  Future<void> _ensureInitialized() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
  }
}
