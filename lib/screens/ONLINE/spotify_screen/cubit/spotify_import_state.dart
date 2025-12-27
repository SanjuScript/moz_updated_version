part of 'spotify_import_cubit.dart';

abstract class SpotifyImportState extends Equatable {
  const SpotifyImportState();

  @override
  List<Object?> get props => [];
}

class SpotifyImportInitial extends SpotifyImportState {}

class SpotifyImportLoading extends SpotifyImportState {}

/// Logged in + profile + playlists
class SpotifyConnected extends SpotifyImportState {
  final SpotifyUser user;
  final List<SpotifyPlaylist> playlists;

  const SpotifyConnected({required this.user, required this.playlists});

  @override
  List<Object?> get props => [user, playlists];
}

class SpotifyImportingPlaylist extends SpotifyImportState {
  final String playlistName;
  final int totalTracks;
  final int importedTracks;

  const SpotifyImportingPlaylist({
    required this.playlistName,
    required this.totalTracks,
    required this.importedTracks,
  });

  @override
  List<Object?> get props => [playlistName, totalTracks, importedTracks];
}

class SpotifyPlaylistImported extends SpotifyImportState {
  final String playlistName;
  final int importedCount;
  final int totalCount;

  const SpotifyPlaylistImported({
    required this.playlistName,
    required this.importedCount,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [playlistName, importedCount, totalCount];
}

class SpotifyImportError extends SpotifyImportState {
  final String message;

  const SpotifyImportError(this.message);

  @override
  List<Object?> get props => [message];
}
