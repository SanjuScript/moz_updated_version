import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/firebase/data/repository/favorites_repository.dart';
import 'package:moz_updated_version/data/firebase/data/song_repository.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';

part 'favorites_state.dart';

enum OnlineFavoriteSortType { lastAdded, title, artist }

class OnlineFavoritesCubit extends Cubit<OnlineFavoritesState> {
  final FavoritesRepository _repo = FavoritesRepository.instance;
  final SongsRepository _songsRepo = SongsRepository();
  StreamSubscription? _sub;
  bool _hasLoadedSongs = false;
  
  OnlineFavoriteSortType _currentSort = OnlineFavoriteSortType.lastAdded;
  OnlineFavoriteSortType get currentSort => _currentSort;

  OnlineFavoritesCubit() : super(OnlineFavoritesInitial());

  void init() {
    _sub?.cancel();
    _hasLoadedSongs = false;
    _listenToFavorites();
  }
  
  void setSortType(OnlineFavoriteSortType type) {
    _currentSort = type;
    final currentState = state;
    if (currentState is OnlineFavoriteSongsLoaded) {
      _emitSortedSongs(currentState.favoriteIds, currentState.songs);
    }
  }
  
  void _emitSortedSongs(Set<String> ids, List<OnlineSongModel> songs) {
    final sorted = List<OnlineSongModel>.from(songs);
    if (_currentSort == OnlineFavoriteSortType.title) {
      sorted.sort((a, b) => (a.song ?? '').toLowerCase().compareTo((b.song ?? '').toLowerCase()));
    } else if (_currentSort == OnlineFavoriteSortType.artist) {
      sorted.sort((a, b) => (a.primaryArtists ?? '').toLowerCase().compareTo((b.primaryArtists ?? '').toLowerCase()));
    } else {
      // In lastAdded, we usually depend on the order of IDs from the repository.
      // Firestore returns timestamps or arrays? We assume the incoming array is already ordered or reverse it.
      // Actually, if we just keep the order from the stream, it's correct.
      // We will sort them by ID order from the `ids` set (which preserves order from stream/repo).
      final idList = ids.toList(); // This is insertion ordered assuming LinkedHashSet.
      sorted.sort((a, b) => idList.indexOf(a.id ?? '').compareTo(idList.indexOf(b.id ?? '')));
    }
    emit(OnlineFavoriteSongsLoaded(ids, sorted));
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

          _emitSortedSongs(ids, updatedSongs);

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
        _emitSortedSongs(allIds, combinedSongs);
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
        _emitSortedSongs(updatedIds, updatedSongs);
      } else {
        _emitSortedSongs(updatedIds, currentState.songs);

        try {
          final newSongs = await _songsRepo.fetchSongsByIds([songId]);
          final latestState = state;
          if (latestState is OnlineFavoriteSongsLoaded && newSongs.isNotEmpty) {
            _emitSortedSongs(latestState.favoriteIds, [
              ...latestState.songs,
              ...newSongs,
            ]);
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
        _emitSortedSongs(currentIds, currentState.songs);
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
      _emitSortedSongs(ids, []);
      _hasLoadedSongs = true;
      return;
    }

    try {
      final songs = await _songsRepo.fetchSongsByIds(ids.toList());
      _emitSortedSongs(ids, songs);
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
      _emitSortedSongs(ids, []);
      return;
    }

    try {
      final songs = await _songsRepo.fetchSongsByIds(ids.toList());
      _emitSortedSongs(ids, songs);
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
