part of 'collection_cubit.dart';

abstract class CollectionStateForOnline extends Equatable {
  const CollectionStateForOnline();

  @override
  List<Object?> get props => [];
}

class CollectionLoading extends CollectionStateForOnline {}

class AlbumLoaded extends CollectionStateForOnline {
  final AlbumResponse album;

  const AlbumLoaded(this.album);

  @override
  List<Object?> get props => [album];
}

class ArtistLoaded extends CollectionStateForOnline {
  final ArtistModelOnline artist;
  const ArtistLoaded(this.artist);

  @override
  List<Object> get props => [artist];
}

class CollectionError extends CollectionStateForOnline {
  final String message;

  const CollectionError(this.message);

  @override
  List<Object?> get props => [message];
}

class OnlineSongLoaded extends CollectionStateForOnline {
  final OnlineSongModel onlineSongModel;
  OnlineSongLoaded(this.onlineSongModel);
}

class PlaylistLoaded extends CollectionStateForOnline {
  final PlaylistModel playlist;
  const PlaylistLoaded(this.playlist);

  @override
  List<Object?> get props => [playlist];
}
