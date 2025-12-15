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

        if (currentState is OnlineFavoriteSongsLoaded) {
          final removedIds = currentState.favoriteIds.difference(ids);
          final addedIds = ids.difference(currentState.favoriteIds);
          final updatedSongs = currentState.songs
              .where((s) => ids.contains(s.id))
              .toList();
          emit(OnlineFavoriteSongsLoaded(ids, updatedSongs));

          if (addedIds.isNotEmpty) {
            _fetchAndAppendNewSongs(addedIds);
          }
          return;
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

  Future<void> _fetchAndAppendNewSongs(Set<String> newIds) async {
    if (newIds.isEmpty) return;

    try {
      final newSongs = await _songsRepo.fetchSongsByIds(newIds.toList());

      final currentState = state;
      if (currentState is OnlineFavoriteSongsLoaded) {
        emit(
          OnlineFavoriteSongsLoaded(currentState.favoriteIds, [
            ...currentState.songs,
            ...newSongs,
          ]),
        );
      }
    } catch (_) {}
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
    final currentState = state;
    final currentIds = _getCurrentIds(currentState);

    // Optimistic update
    final updatedIds = Set<String>.from(currentIds);
    if (updatedIds.contains(songId)) {
      updatedIds.remove(songId);
    } else {
      updatedIds.add(songId);
    }

    if (currentState is OnlineFavoriteSongsLoaded) {
      final updatedSongs = currentState.songs
          .where((s) => updatedIds.contains(s.id))
          .toList();

      emit(OnlineFavoriteSongsLoaded(updatedIds, updatedSongs));
    } else {
      emit(OnlineFavoritesIdsLoaded(updatedIds));
    }

    try {
      if (currentIds.contains(songId)) {
        await _repo.removeFavorite(songId: songId);
      } else {
        await _repo.addFavorite(songId: songId);
      }
    } catch (e) {
      emit(OnlineFavoritesError(currentIds, e.toString()));
    }
  }

  Future<void> loadFavoriteSongs() async {
    final currentState = state;
    Set<String> ids;

    if (currentState is OnlineFavoritesIdsLoaded) {
      ids = currentState.favoriteIds;
      emit(currentState.copyWith(isLoadingSongs: true));
    } else if (currentState is OnlineFavoriteSongsLoaded) {
      ids = currentState.favoriteIds;
    } else if (currentState is OnlineFavoritesError) {
      ids = currentState.favoriteIds;
    } else {
      return;
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
