part of 'artist_cubit.dart';

sealed class ArtistState extends Equatable {
  const ArtistState();

  @override
  List<Object> get props => [];
}

final class ArtistInitial extends ArtistState {}

class ArtistLoading extends ArtistState {}

class ArtistLoaded extends ArtistState {
  final List<ArtistModel> artists;
  final List<SongModel> songs;
  final bool isSelecting;
  final Set<int> selectedArtistIds;

  const ArtistLoaded(
    this.artists, {
    this.songs = const [],
    this.isSelecting = false,
    this.selectedArtistIds = const {},
  });

  ArtistLoaded copyWith({
    List<ArtistModel>? artists,
    List<SongModel>? songs,
    bool? isSelecting,
    Set<int>? selectedArtistIds,
  }) {
    return ArtistLoaded(
      artists ?? this.artists,
      songs: songs ?? this.songs,
      isSelecting: isSelecting ?? this.isSelecting,
      selectedArtistIds: selectedArtistIds ?? this.selectedArtistIds,
    );
  }

  @override
  List<Object> get props => [artists, songs, isSelecting, selectedArtistIds];
}

class ArtistError extends ArtistState {
  final String message;
  const ArtistError(this.message);

  @override
  List<Object> get props => [message];
}
