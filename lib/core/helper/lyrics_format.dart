String formatLyrics(String lyrics, bool showTimestamps) {
  if (showTimestamps) return lyrics;
  return lyrics.replaceAll(RegExp(r'\[[\d:\.]+\]\s*'), '');
}
