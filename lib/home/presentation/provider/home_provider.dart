import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class SongProvider with ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = [];

  List<SongModel> get songs => _songs;

  Future<void> loadSongs() async {
    final status = await Permission.audio.request();
    if (!status.isGranted) return;

    List<SongModel> allSongs = await _audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
    );
    _songs = allSongs.where((song) {
      final name = song.displayName.toLowerCase();
      return !name.contains(".opus") &&
          !name.contains("aud") &&
          !name.contains("recordings") &&
          !name.contains("recording") &&
          !name.contains("midi") &&
          !name.contains("pxl") &&
          !name.contains("record") &&
          !name.contains("vid") &&
          !name.contains("whatsapp");
    }).toList();
    notifyListeners();
  }
}
