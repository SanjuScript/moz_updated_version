import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

class ArtworkHelper {
  static final _audioQuery = OnAudioQuery();

  static Future<Uri?> getArtworkUri(int songId) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/art_$songId.jpg');

      if (await file.exists()) {
        return Uri.file(file.path);
      }

      final artwork = await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        format: ArtworkFormat.PNG,
        size: 250,
        quality: 100,
      );

      if (artwork != null) {
        await file.writeAsBytes(artwork);
        return Uri.file(file.path);
      }
    } catch (e) {
      debugPrint("ArtworkHelper error: $e");
    }

    return null;
  }
}
