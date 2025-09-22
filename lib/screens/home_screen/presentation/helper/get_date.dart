import 'dart:io';

Future<String> getTimeAgoFromPath(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) {
      final modified = await file.lastModified();
      final now = DateTime.now();
      final difference = now.difference(modified);

      if (difference.inDays >= 365) {
        final years = (difference.inDays / 365).floor();
        return "${years}y";
      } else if (difference.inDays >= 30) {
        final months = (difference.inDays / 30).floor();
        return "${months}mo";
      } else if (difference.inDays >= 7) {
        final weeks = (difference.inDays / 7).floor();
        return "${weeks}w";
      } else if (difference.inDays >= 1) {
        return "${difference.inDays}d";
      } else if (difference.inHours >= 1) {
        return "${difference.inHours}h";
      } else if (difference.inMinutes >= 1) {
        return "${difference.inMinutes}m";
      } else {
        return "now";
      }
    }
  } catch (e) {
    return "Unknown";
  }
  return "Unknown";
}
