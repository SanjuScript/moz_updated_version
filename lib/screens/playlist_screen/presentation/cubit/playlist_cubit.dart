import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/playlist/playlist_model.dart';
import 'package:moz_updated_version/data/db/playlist/repository/playlist_ab_repo.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/cubit/library_counts_cubit.dart';
import 'package:moz_updated_version/services/service_locator.dart';

part 'playlist_state.dart';

enum PlaylistSortOption {
  dateAdded,
  songCountLargest,
  songCountSmallest,
  dateCreatedNewest,
  dateCreatedOldest,
}

class PlaylistCubit extends Cubit<PlaylistState> {
  final PlaylistAbRepo _playlistRepo = sl<PlaylistAbRepo>();
  final Box _settingsBox = Hive.box('settingsBox');

  PlaylistSortOption _currentSort = PlaylistSortOption.dateAdded;
  PlaylistSortOption get currentSort => _currentSort;

  PlaylistCubit() : super(PlaylistInitial()) {
    _loadSortOption();
  }

  //load sort option
  void _loadSortOption() {
    final savedSort = _settingsBox.get(
      'playlistSortOption',
      defaultValue: 'dateAdded',
    );
    _currentSort = PlaylistSortOption.values.firstWhere(
      (e) => e.name == savedSort,
      orElse: () => PlaylistSortOption.dateAdded,
    );
  }

  // Load all playlists
  Future<void> loadPlaylists() async {
    try {
      emit(PlaylistInitial());
      final playlists = _playlistRepo.getPlaylists();
      final sorted = _sortPlaylists(playlists, _currentSort);
      emit(PlaylistLoaded(sorted));
      if (!isClosed) {
        log("message");
        sl<LibraryCountsCubit>().updatePlaylists(playlists.length);
      }
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  //change sort order
  void changeSort(PlaylistSortOption newSort) {
    _currentSort = newSort;
    _settingsBox.put('playlistSortOption', newSort.name);

    if (state is PlaylistLoaded) {
      final playlists = (state as PlaylistLoaded).playlists;
      final sorted = _sortPlaylists(playlists, newSort);
      emit(PlaylistLoaded(sorted));
    }
  }

  //Sort Playlists
  List<Playlist> _sortPlaylists(
    List<Playlist> playlists,
    PlaylistSortOption sortOption,
  ) {
    final list = List.of(playlists);
    list.sort((a, b) {
      switch (sortOption) {
        case PlaylistSortOption.dateAdded:
          return 0;
        case PlaylistSortOption.songCountLargest:
          return b.songIds.length.compareTo(a.songIds.length);
        case PlaylistSortOption.songCountSmallest:
          return a.songIds.length.compareTo(b.songIds.length);
        case PlaylistSortOption.dateCreatedNewest:
          return b.key.compareTo(a.key);
        case PlaylistSortOption.dateCreatedOldest:
          return a.key.compareTo(b.key);
      }
    });
    return list;
  }

  // Create a new playlist
  Future<void> createPlaylist(String name) async {
    try {
      await _playlistRepo.createPlaylist(name);
      loadPlaylists();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  // Delete playlist
  Future<void> deletePlaylist(int key) async {
    try {
      await _playlistRepo.deletePlaylist(key);
      loadPlaylists();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  // Delete All playlist
  Future<void> deleteAllPlaylist() async {
    try {
      await _playlistRepo.deleteAllPlaylist();
      loadPlaylists();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  // Add song to playlist
  Future<void> addSongToPlaylist(int key, int songId) async {
    try {
      await _playlistRepo.addSongToPlaylist(key, songId);
      loadPlaylists();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  // Add songs to playlist
  Future<void> addSongsToPlaylist(int key, List<int> songIds) async {
    try {
      await _playlistRepo.addSongsToPlaylist(key, songIds);
      loadPlaylists();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  // Remove song from playlist
  Future<void> removeSongFromPlaylist(int key, int songId) async {
    try {
      await _playlistRepo.removeSongFromPlaylist(key, songId);
      loadPlaylists();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  // Remove songs from playlist
  Future<void> removeSongsFromPlaylist(int key, List<int> songIds) async {
    try {
      await _playlistRepo.removeSongsFromPlaylist(key, songIds);
      loadPlaylists();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  //Edit playlist
  Future<void> editPlaylist(int key, String name) async {
    try {
      await _playlistRepo.editPlaylist(key, name);
      loadPlaylists();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  // Enable selection mode
  void enableSelection() {
    if (state is PlaylistLoaded) {
      emit(
        (state as PlaylistLoaded).copyWith(
          isSelecting: true,
          selectedSongIds: {},
        ),
      );
    }
  }

  // Disable selection mode
  void disableSelection() {
    if (state is PlaylistLoaded) {
      emit(
        (state as PlaylistLoaded).copyWith(
          isSelecting: false,
          selectedSongIds: {},
        ),
      );
    }
  }

  void toggleSongSelection(int songId) {
    if (state is PlaylistLoaded) {
      final current = state as PlaylistLoaded;
      final updated = Set<int>.from(current.selectedSongIds);
      if (updated.contains(songId)) {
        updated.remove(songId);
      } else {
        updated.add(songId);
      }
      emit(current.copyWith(selectedSongIds: updated));
    }
  }
}
