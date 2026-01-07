// import 'package:flutter/services.dart';
// import 'package:moz_updated_version/core/utils/downloads/download_model.dart';

// class MetadataWriter {
//   static const _channel = MethodChannel('moz_music/metadata');

//   static Future<void> write({
//     required String filePath,
//     required DownloadSong song,
//   }) async {
//     await _channel.invokeMethod('writeMetadata', {
//       'filePath': filePath,
//       'title': song.title,
//       'artist': song.artist,
//       'album': song.album,
//       'artworkUrl': song.artworkUrl,
//     });
//   }
// }
