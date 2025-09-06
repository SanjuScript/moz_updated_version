import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/db/favorites/repository/favorite_ab.dart';
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
      emit(FavoritesLoaded(repository.favoriteItems.value));
    } catch (e) {
      emit(FavoritesError("Failed to load favorites"));
    }
  }

  Future<void> toggleFavorite(SongModel song) async {
    if (repository.isFavorite(song.id.toString())) {
      await repository.remove(song.id.toString());
    } else {
      await repository.add(song);
    }
  }

  bool isFavorite(String id) => repository.isFavorite(id);

  @override
  Future<void> close() {
    repository.favoriteItems.removeListener(_listener);
    return super.close();
  }
}
