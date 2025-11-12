import 'package:flutter/material.dart';

abstract class FavoriteLyricsAbRepo {
  ValueNotifier<Map<int, String>> get favoriteLyrics;

  Future<void> init();
  Future<void> addFavoriteLyric(int songId, String lyrics);
  Future<void> removeFavoriteLyric(int songId);
  bool isFavoriteLyric(int songId);
  Future<void> clear();
}
