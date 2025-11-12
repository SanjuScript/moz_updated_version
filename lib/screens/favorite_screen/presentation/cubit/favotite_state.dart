part of 'favotite_cubit.dart';

sealed class FavotiteState extends Equatable {
  const FavotiteState();

  @override
  List<Object> get props => [];
}

final class FavotiteInitial extends FavotiteState {}

class FavoritesLoading extends FavotiteState {}

class FavoritesLoaded extends FavotiteState {
  final List<SongModel> items;
  final Map<int, String> lyrics;
  const FavoritesLoaded(this.items, this.lyrics);

  @override
  List<Object> get props => [items, lyrics];
}

class FavoritesError extends FavotiteState {
  final String message;
  const FavoritesError(this.message);

  @override
  List<Object> get props => [message];
}
