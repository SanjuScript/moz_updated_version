import 'package:flutter/material.dart';

abstract class LyricsDbAb {
  ValueNotifier<Map<int, String>> get cachedLyrics;

  Future<void> init();
  int getKey(int songId);
  Future<String?> getLyrics(int id);
  Future<void> saveLyrics(int id, String lyrics);
  Future<void> deleteLyrics(int id);
  Future<void> clear();
}
