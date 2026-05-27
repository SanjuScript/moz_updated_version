import 'dart:async';
import 'dart:developer';
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
  bool _hasLoadedSongs = false;

  OnlineFavoritesCubit() : super(OnlineFavoritesInitial());

  void init() {
    _sub?.cancel();
    _hasLoadedSongs = false;
    _listenToFavorites();
  }

  void _listenToFavorites() {
    _sub = _repo.favoritesStream().listen(
      (ids) async {
        final currentState = state;

        if (currentState is OnlineFavoriteSongsLoaded) {
          final removedIds = currentState.favoriteIds.difference(ids);
          final addedIds = ids.difference(currentState.favoriteIds);

          final updatedSongs = currentState.songs
              .where((s) => ids.contains(s.id))
              .toList();

          emit(OnlineFavoriteSongsLoaded(ids, updatedSongs));

          if (addedIds.isNotEmpty) {
            await _fetchAndAppendNewSongs(ids, addedIds);
          }
          return;
        }

        emit(OnlineFavoritesIdsLoaded(ids));
      },
      onError: (e) {
        log('Favorites stream error: $e');
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

  Future<void> _fetchAndAppendNewSongs(
    Set<String> allIds,
    Set<String> newIds,
  ) async {
    if (newIds.isEmpty) return;

    try {
      final newSongs = await _songsRepo.fetchSongsByIds(newIds.toList());

      final currentState = state;
      if (currentState is OnlineFavoriteSongsLoaded) {
        final combinedSongs = [...currentState.songs, ...newSongs];
        emit(OnlineFavoriteSongsLoaded(allIds, combinedSongs));
      }
    } catch (e) {
      log('Error fetching new favorite songs: $e');
    }
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

    final isCurrentlyFavorite = currentIds.contains(songId);
    final updatedIds = Set<String>.from(currentIds);

    if (isCurrentlyFavorite) {
      updatedIds.remove(songId);
    } else {
      updatedIds.add(songId);
    }

    if (currentState is OnlineFavoriteSongsLoaded) {
      if (isCurrentlyFavorite) {
        final updatedSongs = currentState.songs
            .where((s) => s.id != songId)
            .toList();
        emit(OnlineFavoriteSongsLoaded(updatedIds, updatedSongs));
      } else {
        emit(OnlineFavoriteSongsLoaded(updatedIds, currentState.songs));

        try {
          final newSongs = await _songsRepo.fetchSongsByIds([songId]);
          final latestState = state;
          if (latestState is OnlineFavoriteSongsLoaded && newSongs.isNotEmpty) {
            emit(
              OnlineFavoriteSongsLoaded(latestState.favoriteIds, [
                ...latestState.songs,
                ...newSongs,
              ]),
            );
          }
        } catch (e) {
          log('Error fetching newly favorited song: $e');
        }
      }
    } else {
      emit(OnlineFavoritesIdsLoaded(updatedIds));
    }

    try {
      if (isCurrentlyFavorite) {
        await _repo.removeFavorite(songId: songId);
      } else {
        await _repo.addFavorite(songId: songId);
      }
    } catch (e) {
      log('Error toggling favorite: $e');
      if (currentState is OnlineFavoriteSongsLoaded) {
        emit(OnlineFavoriteSongsLoaded(currentIds, currentState.songs));
      } else {
        emit(OnlineFavoritesIdsLoaded(currentIds));
      }
      emit(OnlineFavoritesError(currentIds, e.toString()));
    }
  }

  Future<void> loadFavoriteSongs() async {
    final currentState = state;
    final ids = _getCurrentIds(currentState);

    if (_hasLoadedSongs && currentState is OnlineFavoriteSongsLoaded) {
      return;
    }

    emit(OnlineFavoriteLoading());

    if (ids.isEmpty) {
      emit(OnlineFavoriteSongsLoaded(ids, []));
      _hasLoadedSongs = true;
      return;
    }

    try {
      final songs = await _songsRepo.fetchSongsByIds(ids.toList());
      emit(OnlineFavoriteSongsLoaded(ids, songs));
      _hasLoadedSongs = true;
    } catch (e, stack) {
      log('Error loading favorite songs: $e', stackTrace: stack);
      emit(OnlineFavoritesError(ids, e.toString()));
    }
  }

  Future<void> refreshFavoriteSongs() async {
    final ids = _getCurrentIds(state);

    emit(OnlineFavoriteLoading());

    if (ids.isEmpty) {
      emit(OnlineFavoriteSongsLoaded(ids, []));
      return;
    }

    try {
      final songs = await _songsRepo.fetchSongsByIds(ids.toList());
      emit(OnlineFavoriteSongsLoaded(ids, songs));
    } catch (e) {
      log('Error refreshing favorite songs: $e');
      emit(OnlineFavoritesError(ids, e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();

    return super.close();
  }
}
