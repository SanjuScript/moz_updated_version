import 'dart:developer';
import 'package:flutter_media_delete/flutter_media_delete.dart';

class DeletAudioFile {
  static Future<String> deleteFile(String path) async {
    try {
      final result = await FlutterMediaDelete.deleteMediaFile(path);
      log("Deleted: $path → $result");
      return result;
    } catch (e) {
      log("Error deleting $path → $e");
      return e.toString();
    } finally {
      log("Delete attempt finished for $path");
    }
  }
}
