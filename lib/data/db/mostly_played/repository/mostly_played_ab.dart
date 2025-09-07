import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

abstract class MostlyPlayedRepo {
  ValueNotifier<List<SongModel>> get mostPlayedItems;

  Future<void> init();
  Future<void> add(MediaItem item);
  Future<void> load();
  Future<void> clear();
  Future<void> delete(String id);
}
