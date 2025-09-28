import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/db/favorites/repository/favorite_ab.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/cubit/library_counts_cubit.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'favotite_state.dart';

class FavoritesCubit extends Cubit<FavotiteState> {
  final FavoriteAbRepo repository = sl<FavoriteAbRepo>();
  late final VoidCallback _listener;

  FavoritesCubit() : super(FavoritesLoading()) {
    _listener = () {
      emit(FavoritesLoaded(List.from(repository.favoriteItems.value)));
    };
    repository.favoriteItems.addListener(_listener);

    load();
  }

  Future<void> load() async {
    try {
      await repository.load();
      final items = repository.favoriteItems.value;
      emit(FavoritesLoaded(items));

      if (!isClosed) {
        sl<LibraryCountsCubit>().updateFavorites(items.length);
      }
    } catch (e) {
      emit(FavoritesError("Failed to load favorites"));
    }
  }

  Future<void> clearFavs() async {
    try {
      await repository.clear();
      final items = repository.favoriteItems.value;
      if (!isClosed) {
        sl<LibraryCountsCubit>().updateFavorites(items.length);
      }
      emit(FavoritesLoaded(items));
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
    final items = repository.favoriteItems.value;
    if (!isClosed) {
      sl<LibraryCountsCubit>().updateFavorites(items.length);
    }
  }

  bool isFavorite(String id) => repository.isFavorite(id);

  @override
  Future<void> close() {
    repository.favoriteItems.removeListener(_listener);
    return super.close();
  }
}
