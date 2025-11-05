class SavedLyricItem {
  final int songId;
  final String title;
  final String artist;
  final String lyrics;

  SavedLyricItem({
    required this.songId,
    required this.title,
    required this.artist,
    required this.lyrics,
  });

  SavedLyricItem copyWith({
    int? songId,
    String? title,
    String? artist,
    String? lyrics,
  }) {
    return SavedLyricItem(
      songId: songId ?? this.songId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      lyrics: lyrics ?? this.lyrics,
    );
  }
}
