part of 'playlistsongs_cubit.dart';

sealed class OnlinePlaylistsongsState extends Equatable {
  const OnlinePlaylistsongsState();

  @override
  List<Object> get props => [];
}

final class OnlinePlaylistsongsInitial extends OnlinePlaylistsongsState {}

class OnlinePlaylistSongsLoaded extends OnlinePlaylistsongsState {
  final String playlistId;
  final List<String> songIds;
  final List<OnlineSongModel> songs;

  const OnlinePlaylistSongsLoaded(this.playlistId, this.songIds, this.songs);

  @override
  List<Object> get props => [playlistId, songIds, songs];
}

class OnlinePlaylistSongsError extends OnlinePlaylistsongsState {
  final String message;
  const OnlinePlaylistSongsError(this.message);

  @override
  List<Object> get props => [message];
}
