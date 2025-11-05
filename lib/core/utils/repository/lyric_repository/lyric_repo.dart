abstract class LyricsRepository {
  Future<String?> fetchLyrics(String title, {String? artist});
  Future<String?> transliterate(String text, {required String sourceLang});
}
