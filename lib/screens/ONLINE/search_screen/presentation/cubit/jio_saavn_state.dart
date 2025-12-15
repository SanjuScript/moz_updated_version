part of 'jio_saavn_cubit.dart';

abstract class JioSaavnState extends Equatable {
  const JioSaavnState();

  @override
  List<Object?> get props => [];
}

class JioSaavnInitial extends JioSaavnState {}

class JioSaavnSearchLoading extends JioSaavnState {}

class JioSaavnSearchSuccess extends JioSaavnState {
  final List<OnlineSongModel> songs;

  const JioSaavnSearchSuccess(this.songs);

  @override
  List<Object?> get props => [songs];
}

class JioSaavnSearchError extends JioSaavnState {
  final String message;

  const JioSaavnSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class JioSaavnSongLoading extends JioSaavnState {}

class JioSaavnSongSuccess extends JioSaavnState {
  final OnlineSongModel song;

  const JioSaavnSongSuccess(this.song);

  @override
  List<Object?> get props => [song];
}

class JioSaavnSongError extends JioSaavnState {
  final String message;

  const JioSaavnSongError(this.message);

  @override
  List<Object?> get props => [message];
}

//TRENDING SEARCHE STATE
class JioSaavnTrendingLoading extends JioSaavnState {}

class JioSaavnTrendingSuccess extends JioSaavnState {
  final List<TrendingItemModel> items;

  const JioSaavnTrendingSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class JioSaavnTrendingError extends JioSaavnState {
  final String message;

  const JioSaavnTrendingError(this.message);

  @override
  List<Object?> get props => [message];
}
