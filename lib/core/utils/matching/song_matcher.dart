class SongMatcher {
  static int findBestMatch(
    List<Map<String, dynamic>> saavnSongs,
    String title,
    String artist,
  ) {
    title = title.toLowerCase();
    artist = artist.toLowerCase();

    int bestIndex = -1;
    double bestScore = 0;

    for (int i = 0; i < saavnSongs.length; i++) {
      final sTitle = (saavnSongs[i]['song'] ?? '').toLowerCase();
      final sArtist = (saavnSongs[i]['primary_artists'] ?? '').toLowerCase();

      double score = 0;

      if (sTitle.contains(title) || title.contains(sTitle)) score += 0.6;
      if (sArtist.contains(artist) || artist.contains(sArtist)) score += 0.4;

      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }

    return bestScore >= 0.6 ? bestIndex : -1;
  }
}
