import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/lyrics_db/lyrics_db_ab.dart';

class LyricsLocalRepository implements LyricsDbAb {
  static const String _boxName = 'LyricsDB';
  Box<String>? _box;

  @override
  ValueNotifier<Map<int, String>> cachedLyrics = ValueNotifier({});

  @override
  int getKey(int songId) => songId;

  @override
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<String>(_boxName);
    }
    _loadFromBox();
  }

  void _loadFromBox() {
    if (_box == null || !_box!.isOpen) return;

    final Map<int, String> loadedData = {};
    for (var entry in _box!.toMap().entries) {
      final songId = int.tryParse(entry.key.toString());
      if (songId != null) {
        loadedData[songId] = entry.value;
      }
    }

    cachedLyrics.value = loadedData;
    cachedLyrics.notifyListeners();
  }

  @override
  Future<String?> getLyrics(int id) async {
    await _ensureInitialized();
    final key = getKey(id);
    return _box!.get(key);
  }

  @override
  Future<void> saveLyrics(int id, String lyrics) async {
    await _ensureInitialized();
    final key = getKey(id);
    await _box!.put(key, lyrics);
    cachedLyrics.value[key] = lyrics;
    cachedLyrics.notifyListeners();
  }

  /// Temporary manual insertion function
  // Future<void> insertManualLyricsForce({
  //   required int songId,
  //   required String lyrics,
  // }) async {
  //   await _ensureInitialized();

  //   // Force overwrite / insert
  //   await _box!.put(songId, lyrics);

  //   // Reload to refresh ValueNotifier properly
  //   _loadFromBox();
  // }

  @override
  Future<void> deleteLyrics(int id) async {
    await _ensureInitialized();
    final key = getKey(id);
    await _box!.delete(key);
    cachedLyrics.value.remove(key);
    cachedLyrics.notifyListeners();
  }

  @override
  Future<void> clear() async {
    await _ensureInitialized();
    await _box!.clear();
    cachedLyrics.value.clear();
    cachedLyrics.notifyListeners();
  }

  Future<void> _ensureInitialized() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
  }
}
