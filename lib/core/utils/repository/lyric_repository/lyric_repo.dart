abstract class LyricsRepository {
  Future<String?> fetchLyrics(
    String title, {
    String? artist,
    bool syncedOnly = false,
    bool plainOnly = false,
    String? lang,
    bool enhanced = false,
  });
  Future<String?> transliterate(String text, {required String sourceLang});
}
