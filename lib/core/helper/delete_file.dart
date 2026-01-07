import 'dart:developer';
import 'dart:io';
import 'package:flutter_media_delete/flutter_media_delete.dart';

class DeleteAudioFile {
  static Future<String> deleteFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        log("File doesn't exist: $path");
        return "File not found";
      }

      String result;

      if (Platform.isAndroid) {
        result = await FlutterMediaDelete.deleteMediaFile(path);
        log("Deleted via MediaStore: $path → $result");
      } else {
        await file.delete();
        result = "File deleted successfully";
        log("Deleted via File API: $path → $result");
      }

      return result;
    } catch (e) {
      log("Error deleting $path → $e");

      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          log("Deleted via fallback File API: $path");
          return "File deleted successfully (fallback)";
        }
      } catch (fallbackError) {
        log("Fallback deletion also failed: $fallbackError");
      }

      return "Delete failed: ${e.toString()}";
    } finally {
      log("Delete attempt finished for $path");
    }
  }
}
