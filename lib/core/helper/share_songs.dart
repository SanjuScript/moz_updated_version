import 'package:share_plus/share_plus.dart';

class ShareHelper {
  static Future<void> shareSong({
    required String filePath,
    String? title,
  }) async {
    final xFile = XFile(filePath);
    await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        text: title != null ? "Check out this song: $title" : null,
      ),
    );
  }

  static Future<void> shareSongs({
    required List<String> filePaths,
    String? title,
  }) async {
    final xFiles = filePaths.map((path) => XFile(path)).toList();
    await SharePlus.instance.share(
      ShareParams(
        files: xFiles,
        text: title != null ? "Check out these songs: $title" : null,
      ),
    );
  }

  static Future<void> shareLyrics({
    required String lyrics,
    required String title,
    required String artist,
  }) async {
    final shareText =
        '''
$title - $artist

$lyrics
''';

    await SharePlus.instance.share(ShareParams(text: shareText));
  }
}
