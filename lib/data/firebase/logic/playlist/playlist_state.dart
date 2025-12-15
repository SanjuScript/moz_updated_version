part of 'playlist_cubit.dart';

sealed class OnlinePlaylistState extends Equatable {
  const OnlinePlaylistState();
  @override
  List<Object?> get props => [];
}

class OnlinePlaylistInitial extends OnlinePlaylistState {}

class OnlinePlaylistError extends OnlinePlaylistState {
  final String message;
  const OnlinePlaylistError(this.message);

  @override
  List<Object?> get props => [message];
}

class OnlinePlaylistsLoaded extends OnlinePlaylistState {
  final List<PlaylistModelOnline> playlists;

  const OnlinePlaylistsLoaded(this.playlists);

  @override
  List<Object?> get props => [playlists];
}
