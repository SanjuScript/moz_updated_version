import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/firebase/data/repository/favorites_repository.dart';
import 'package:moz_updated_version/data/firebase/data/song_repository.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';

part 'favorites_state.dart';

class OnlineFavoritesCubit extends Cubit<OnlineFavoritesState> {
  final FavoritesRepository _repo = FavoritesRepository.instance;
  final SongsRepository _songsRepo = SongsRepository();
  StreamSubscription? _sub;

  OnlineFavoritesCubit() : super(OnlineFavoritesInitial()) {
    _listenToFavorites();
  }

  void _listenToFavorites() {
    _sub = _repo.favoritesStream().listen(
      (ids) {
        final currentState = state;

        // If we're already showing songs and IDs haven't changed, keep showing songs
        if (currentState is OnlineFavoriteSongsLoaded) {
          if (currentState.favoriteIds.length == ids.length &&
              currentState.favoriteIds.containsAll(ids)) {
            return; // No change needed
          }
        }

        emit(OnlineFavoritesIdsLoaded(ids));
      },
      onError: (e) {
        final currentState = state;
        final currentIds = _getCurrentIds(currentState);
        emit(OnlineFavoritesError(currentIds, e.toString()));
      },
    );
  }

  Set<String> _getCurrentIds(OnlineFavoritesState state) {
    if (state is OnlineFavoritesIdsLoaded) {
      return state.favoriteIds;
    } else if (state is OnlineFavoriteSongsLoaded) {
      return state.favoriteIds;
    } else if (state is OnlineFavoritesError) {
      return state.favoriteIds;
    }
    return {};
  }

  bool isFavorite(String songId) {
    final currentState = state;

    if (currentState is OnlineFavoritesIdsLoaded) {
      return currentState.favoriteIds.contains(songId);
    } else if (currentState is OnlineFavoriteSongsLoaded) {
      return currentState.favoriteIds.contains(songId);
    } else if (currentState is OnlineFavoritesError) {
      return currentState.favoriteIds.contains(songId);
    }

    return false;
  }

  Future<void> toggleFavorite(String songId) async {
    try {
      if (isFavorite(songId)) {
        await _repo.removeFavorite(songId: songId);
      } else {
        await _repo.addFavorite(songId: songId);
      }
    } catch (e) {
      final currentIds = _getCurrentIds(state);
      emit(OnlineFavoritesError(currentIds, e.toString()));
    }
  }

  Future<void> loadFavoriteSongs() async {
    final currentState = state;
    Set<String> ids;

    if (currentState is OnlineFavoritesIdsLoaded) {
      ids = currentState.favoriteIds;
      // Show loading indicator while keeping IDs available
      emit(currentState.copyWith(isLoadingSongs: true));
    } else if (currentState is OnlineFavoriteSongsLoaded) {
      ids = currentState.favoriteIds;
    } else if (currentState is OnlineFavoritesError) {
      ids = currentState.favoriteIds;
    } else {
      return; // Can't load without IDs
    }

    if (ids.isEmpty) {
      emit(OnlineFavoriteSongsLoaded(ids, []));
      return;
    }

    try {
      final songs = await _songsRepo.fetchSongsByIds(ids.toList());
      emit(OnlineFavoriteSongsLoaded(ids, songs));
    } catch (e) {
      emit(OnlineFavoritesError(ids, e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
