// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'playlist_cubit.dart';

sealed class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object> get props => [];
}

final class PlaylistInitial extends PlaylistState {}

class PlaylistLoaded extends PlaylistState {
  final List<Playlist> playlists;
  final bool isSelecting;
  final Set<int> selectedSongIds;
  const PlaylistLoaded(
    this.playlists, {
    this.isSelecting = false,
    this.selectedSongIds = const {},
  });

  @override
  List<Object> get props => [playlists, isSelecting, selectedSongIds];

  PlaylistLoaded copyWith({
    List<Playlist>? playlists,
    bool? isSelecting,
    Set<int>? selectedSongIds,
  }) {
    return PlaylistLoaded(
      playlists ?? this.playlists,
      isSelecting: isSelecting ?? this.isSelecting,
      selectedSongIds: selectedSongIds ?? this.selectedSongIds,
    );
  }
}

class PlaylistError extends PlaylistState {
  final String message;

  const PlaylistError(this.message);

  @override
  List<Object> get props => [message];
}
