part of 'album_cubit.dart';

sealed class AlbumState extends Equatable {
  const AlbumState();

  @override
  List<Object> get props => [];
}

final class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

class AlbumLoaded extends AlbumState {
  final List<AlbumModel> albums;
  final List<SongModel> songs;
  final bool isSelecting;
  final Set<int> selectedAlbumIds;

  const AlbumLoaded(
    this.albums, {
    this.songs = const [],
    this.isSelecting = false,
    this.selectedAlbumIds = const {},
  });

  AlbumLoaded copyWith({
    List<AlbumModel>? albums,
    List<SongModel>? songs,
    bool? isSelecting,
    Set<int>? selectedAlbumIds,
  }) {
    return AlbumLoaded(
      albums ?? this.albums,
      songs: songs ?? this.songs,
      isSelecting: isSelecting ?? this.isSelecting,
      selectedAlbumIds: selectedAlbumIds ?? this.selectedAlbumIds,
    );
  }

  @override
  List<Object> get props => [albums, isSelecting, selectedAlbumIds,songs];
}

class AlbumError extends AlbumState {
  final String message;
  const AlbumError(this.message);

  @override
  List<Object> get props => [message];
}
