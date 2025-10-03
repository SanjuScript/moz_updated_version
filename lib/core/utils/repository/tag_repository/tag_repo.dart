// import 'package:flutter/services.dart';

// class AudioMetadataRepository {
//   static const MethodChannel _channel = MethodChannel('com.mozmusic.metadata');

//   Future<Map<String, dynamic>?> getMetadata(String filePath) async {
//     final result = await _channel.invokeMethod('getMetadata', {'path': filePath});
//     return Map<String, dynamic>.from(result ?? {});
//   }

//   Future<bool> setMetadata({
//     required String filePath,
//     String? title,
//     String? artist,
//     String? album,
//     String? year,
//     String? genre,
//     String? artworkPath,
//   }) async {
//     final result = await _channel.invokeMethod('setMetadata', {
//       'path': filePath,
//       'title': title,
//       'artist': artist,
//       'album': album,
//       'year': year,
//       'genre': genre,
//       'artworkPath': artworkPath,
//     });
//     return result == true;
//   }
// }
