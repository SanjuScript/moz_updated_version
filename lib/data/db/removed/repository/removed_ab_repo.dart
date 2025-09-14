import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

abstract class RemovedAbRepo {
  ValueNotifier<List<SongModel>> get removedItems;

  Future<void> init();
  Future<void> add(SongModel song);
  Future<void> remove(String id);
  Future<void> load();
  Future<void> clear();
  bool isRemoved(String id);
}
