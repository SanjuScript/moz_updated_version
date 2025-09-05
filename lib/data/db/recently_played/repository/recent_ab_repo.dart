import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

abstract class RecentAbRepo {
  ValueNotifier<List<SongModel>> get recentItems;

  Future<void> init();
  Future<void> add(SongModel item);
  Future<void> load();
  Future<void> clear();
  Future<void> delete(String id); 
}
