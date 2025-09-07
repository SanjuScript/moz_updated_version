part of 'playlist_cubit.dart';

sealed class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object> get props => [];
}

final class PlaylistInitial extends PlaylistState {}

class PlaylistLoaded extends PlaylistState {
  final List<Playlist> playlists;

  const PlaylistLoaded(this.playlists);

  @override
  List<Object> get props => [playlists];
}

class PlaylistError extends PlaylistState {
  final String message;

  const PlaylistError(this.message);

  @override
  List<Object> get props => [message];
}
