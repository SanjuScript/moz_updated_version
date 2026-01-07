part of 'favorites_cubit.dart';

sealed class OnlineFavoritesState extends Equatable {
  const OnlineFavoritesState();

  @override
  List<Object?> get props => [];
}

final class OnlineFavoritesInitial extends OnlineFavoritesState {}

final class OnlineFavoritesIdsLoaded extends OnlineFavoritesState {
  final Set<String> favoriteIds;
  final bool isLoadingSongs;

  const OnlineFavoritesIdsLoaded(
    this.favoriteIds, {
    this.isLoadingSongs = false,
  });

  OnlineFavoritesIdsLoaded copyWith({
    Set<String>? favoriteIds,
    bool? isLoadingSongs,
  }) {
    return OnlineFavoritesIdsLoaded(
      favoriteIds ?? this.favoriteIds,
      isLoadingSongs: isLoadingSongs ?? this.isLoadingSongs,
    );
  }

  @override
  List<Object?> get props => [favoriteIds, isLoadingSongs];
}

final class OnlineFavoriteSongsLoaded extends OnlineFavoritesState {
  final Set<String> favoriteIds;
  final List<OnlineSongModel> songs;

  const OnlineFavoriteSongsLoaded(this.favoriteIds, this.songs);

  @override
  List<Object?> get props => [favoriteIds, songs];
}

final class OnlineFavoriteLoading extends OnlineFavoritesState {}

final class OnlineFavoritesError extends OnlineFavoritesState {
  final Set<String> favoriteIds;
  final String message;

  const OnlineFavoritesError(this.favoriteIds, this.message);

  @override
  List<Object?> get props => [favoriteIds, message];
}
