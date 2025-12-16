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
  final int currentPage;
  final bool hasMore;
  final int total;

  const JioSaavnSearchSuccess({
    required this.songs,
    required this.currentPage,
    required this.hasMore,
    required this.total,
  });

  JioSaavnSearchSuccess copyWith({
    List<OnlineSongModel>? songs,
    int? currentPage,
    bool? hasMore,
    int? total,
  }) {
    return JioSaavnSearchSuccess(
      songs: songs ?? this.songs,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
    );
  }
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

class JioSaavnSearchLoadingMore extends JioSaavnState {
  final List<OnlineSongModel> currentSongs;
  const JioSaavnSearchLoadingMore(this.currentSongs);
}

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

//Auto complete

class JioSaavnAutocompleteLoading extends JioSaavnState {}

class JioSaavnAutocompleteSuccess extends JioSaavnState {
  final List<String> suggestions;
  const JioSaavnAutocompleteSuccess(this.suggestions);
  @override
  List<Object?> get props => [suggestions];
}

class JioSaavnAutocompleteError extends JioSaavnState {
  final String message;
  const JioSaavnAutocompleteError(this.message);
  @override
  List<Object?> get props => [message];
}
