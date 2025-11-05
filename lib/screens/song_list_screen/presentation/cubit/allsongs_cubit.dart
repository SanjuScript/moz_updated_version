import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/core/helper/delete_file.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repo.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/cubit/library_counts_cubit.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/cubit/lyrics_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/ui/all_songs.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'allsongs_state.dart';

enum SongSortOption {
  dateAdded,
  name,
  durationLargest,
  durationSmallest,
  fileSizeLargest,
  fileSizeSmallest,
}

class AllSongsCubit extends Cubit<AllsongsState> {
  final AudioRepository _repository = sl<AudioRepository>();
  final Box _settingsBox = Hive.box('settingsBox');

  SongSortOption _currentSort = SongSortOption.dateAdded;
  SongSortOption get currentSort => _currentSort;
  bool _goBack = true;
  bool get goBack => _goBack;

  AllSongsCubit() : super(AllsongsInitial()) {
    // _loadSortOption();
  }

  // void _loadSortOption() {
  //   final savedSort = _settingsBox.get(
  //     'songSortOption',
  //     defaultValue: 'dateAdded',
  //   );
  //   _currentSort = SongSortOption.values.firstWhere(
  //     (e) => e.name == savedSort,
  //     orElse: () => SongSortOption.dateAdded,
  //   );
  // }

  Future<void> initSetup() async {
    // _loadSortOption();
    await loadSongs();
  }

  Future<void> loadSongs() async {
    try {
      emit(AllSongsLoading());
      final songs = await _repository.loadSongs();
      final sortedSongs = _sortSongs(songs, _currentSort);
      emit(AllSongsLoaded(sortedSongs));
      log(_currentSort.toString());

      final lyricsCubit = sl<LyricsCubit>();
      lyricsCubit.setSongs(sortedSongs);
      await lyricsCubit.loadSavedLyrics();

      if (!isClosed) {
        sl<LibraryCountsCubit>().updateAllSongs(songs.length);
      }
    } catch (e) {
      emit(AllSongsError(e.toString()));
    }
  }

  void changeSort(SongSortOption newSort) {
    _currentSort = newSort;
    // _settingsBox.put('songSortOption', newSort.name);

    if (state is AllSongsLoaded) {
      final songs = (state as AllSongsLoaded).songs;
      final sortedSongs = _sortSongs(songs, newSort);
      emit(AllSongsLoaded(sortedSongs));
    }
  }

  void removeSelectedSongsFromList() {
    if (state is AllSongsLoaded) {
      final current = state as AllSongsLoaded;

      final updatedSongs = current.songs
          .where((song) => !current.selectedSongs.contains(song.data))
          .toList();

      emit(current.copyWith(songs: updatedSongs, selectedSongs: {}));
    }
  }

  void addRemovedSongsBackToSelection(List<SongModel> removedSongs) {
    if (state is AllSongsLoaded) {
      final current = state as AllSongsLoaded;

      final updatedSongs = List<SongModel>.from(current.songs)
        ..addAll(removedSongs);

      final updatedSelected = Set<String>.from(current.selectedSongs)
        ..addAll(removedSongs.map((s) => s.data));

      emit(
        current.copyWith(songs: updatedSongs, selectedSongs: updatedSelected),
      );
    }
  }

  void enableSelectionMode() {
    if (state is AllSongsLoaded) {
      emit((state as AllSongsLoaded).copyWith(isSelecting: true));
      _goBack = false;
    }
    log(goBack.toString());
  }

  void toggleSongSelection(String path) {
    if (state is AllSongsLoaded) {
      final current = state as AllSongsLoaded;
      final selected = Set<String>.from(current.selectedSongs);
      if (selected.contains(path)) {
        selected.remove(path);
      } else {
        selected.add(path);
      }
      emit(current.copyWith(selectedSongs: selected));
    }
  }

  void deleteSelectedSongs() async {
    if (state is AllSongsLoaded) {
      final current = state as AllSongsLoaded;
      final deletedPaths = <String>[];

      for (var path in current.selectedSongs) {
        final result = await DeletAudioFile.deleteFile(path);
        if (result == "Files deleted successfully") {
          deletedPaths.add(path);
        }
      }

      final updatedSongs = current.songs
          .where((s) => !deletedPaths.contains(s.data))
          .toList();

      emit(AllSongsLoaded(updatedSongs));
      disableSelectionMode();
    }
  }

  void disableSelectionMode() {
    if (state is AllSongsLoaded) {
      _goBack = true;
      emit(
        (state as AllSongsLoaded).copyWith(
          isSelecting: false,
          selectedSongs: {},
        ),
      );
    }
  }

  void deleteSong(String path) async {
    try {
      await DeletAudioFile.deleteFile(path);
      if (state is AllSongsLoaded) {
        final currentSongs = (state as AllSongsLoaded).songs;
        final updatedSongs = currentSongs
            .where((song) => song.data != path)
            .toList();
        emit(AllSongsLoaded(updatedSongs));
      }
    } catch (e) {
      emit(AllSongsError("Failed to delete song: $e"));
    }
  }

  List<SongModel> _sortSongs(List<SongModel> songs, SongSortOption sortOption) {
    final list = List.of(songs);
    list.sort((a, b) {
      switch (sortOption) {
        case SongSortOption.dateAdded:
          return b.dateAdded!.compareTo(a.dateAdded!);
        case SongSortOption.name:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SongSortOption.durationLargest:
          return b.duration!.compareTo(a.duration!);
        case SongSortOption.durationSmallest:
          return a.duration!.compareTo(b.duration!);
        case SongSortOption.fileSizeLargest:
          return b.size.compareTo(a.size);
        case SongSortOption.fileSizeSmallest:
          return a.size.compareTo(b.size);
      }
    });
    return list;
  }
}
