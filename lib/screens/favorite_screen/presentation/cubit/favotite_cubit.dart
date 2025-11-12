import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/db/favorites/repository/favorite_ab.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/cubit/library_counts_cubit.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/widgets/lyric_line_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../../../services/core/app_services.dart';

part 'favotite_state.dart';

class FavoritesCubit extends Cubit<FavotiteState> {
  final FavoriteAbRepo repository = sl<FavoriteAbRepo>();
  final FavoriteLyricsAbRepo lyricsRepo = sl<FavoriteLyricsAbRepo>();

  late final VoidCallback _listener;
  late final VoidCallback _lyricsListener;

  FavoritesCubit() : super(FavoritesLoading()) {
    _listener = () {
      _emitCombinedState();
    };
    _lyricsListener = () {
      _emitCombinedState();
    };

    repository.favoriteItems.addListener(_listener);
    lyricsRepo.favoriteLyrics.addListener(_lyricsListener);
    load();
  }

  void _emitCombinedState() {
    final songs = List<SongModel>.from(repository.favoriteItems.value);
    final lyrics = Map<int, String>.from(lyricsRepo.favoriteLyrics.value);
    emit(FavoritesLoaded(songs, lyrics));
  }

  Future<void> toggleFavoriteLyric(int songId, String lyrics) async {
    if (lyricsRepo.isFavoriteLyric(songId)) {
      await lyricsRepo.removeFavoriteLyric(songId);
    } else {
      await lyricsRepo.addFavoriteLyric(songId, lyrics);
    }
    _emitCombinedState();
  }

  bool isFavoriteSong(String id) => repository.isFavorite(id);
  bool isFavoriteLyric(int songId) => lyricsRepo.isFavoriteLyric(songId);

  Future<void> load() async {
    try {
      await repository.load();
      await lyricsRepo.init();

      _emitCombinedState();

      if (!isClosed) {
        sl<LibraryCountsCubit>().updateFavorites(
          repository.favoriteItems.value.length,
        );
      }
    } catch (e) {
      emit(FavoritesError("Failed to load favorites: $e"));
    }
  }

  Future<void> clearFavs() async {
    // try {
    //   await repository.clear();
    //   final items = repository.favoriteItems.value;
    //   if (!isClosed) {
    //     sl<LibraryCountsCubit>().updateFavorites(items.length);
    //   }
    //   emit(FavoritesLoaded(items));
    // } catch (e) {
    //   emit(FavoritesError(e.toString()));
    // }
  }

  Future<void> clearAll() async {
    try {
      await repository.clear();
      await lyricsRepo.clear();
      _emitCombinedState();
      if (!isClosed) {
        sl<LibraryCountsCubit>().updateFavorites(0);
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> toggleFavorite(SongModel song) async {
    if (repository.isFavorite(song.id.toString())) {
      await repository.remove(song.id.toString());
    } else {
      await repository.add(song);
    }
    _emitCombinedState();
    if (!isClosed) {
      sl<LibraryCountsCubit>().updateFavorites(
        repository.favoriteItems.value.length,
      );
    }
  }

  bool isFavorite(String id) => repository.isFavorite(id);

  @override
  Future<void> close() {
    repository.favoriteItems.removeListener(_listener);
    return super.close();
  }
}
