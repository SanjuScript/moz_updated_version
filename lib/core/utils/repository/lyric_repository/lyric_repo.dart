abstract class LyricsRepository {
  Future<String?> fetchLyrics(String artist, String title);
}