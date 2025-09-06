import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

abstract class FavoriteAbRepo {
  ValueNotifier<List<SongModel>> get favoriteItems;

  Future<void> init();
  Future<void> add(SongModel song);
  Future<void> remove(String id);
  Future<void> load();
  Future<void> clear();
  bool isFavorite(String id);
}
