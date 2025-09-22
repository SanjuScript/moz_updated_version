part of 'library_counts_cubit.dart';

class LibraryCountsState {
  final int allSongs;
  final int recentlyPlayed;
  final int mostlyPlayed;
  final int favorites;
  final int playlists;

  const LibraryCountsState({
    this.allSongs = 0,
    this.recentlyPlayed = 0,
    this.mostlyPlayed = 0,
    this.favorites = 0,
    this.playlists = 0,
  });

  LibraryCountsState copyWith({
    int? allSongs,
    int? recentlyPlayed,
    int? mostlyPlayed,
    int? favorites,
    int? playlists,
  }) {
    return LibraryCountsState(
      allSongs: allSongs ?? this.allSongs,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      mostlyPlayed: mostlyPlayed ?? this.mostlyPlayed,
      favorites: favorites ?? this.favorites,
      playlists: playlists ?? this.playlists,
    );
  }
}
