import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:moz_updated_version/core/utils/repository/album_repository/album_repository.dart';

part 'album_state.dart';

enum AlbumSortOption { name, numberOfSongsLargest, numberOfSongsSmallest }

class AlbumCubit extends Cubit<AlbumState> {
  final AlbumRepository _repository = sl<AlbumRepository>();
  final Box _settingsBox = Hive.box('settingsBox');

  AlbumSortOption _currentSort = AlbumSortOption.name;
  AlbumSortOption get currentSort => _currentSort;

  AlbumCubit() : super(AlbumInitial());

  Future<void> loadAlbums() async {
    try {
      emit(AlbumLoading());
      final albums = await _repository.loadAlbums();
      final sorted = _sortAlbums(albums, _currentSort);
      emit(AlbumLoaded(sorted));
      if (!isClosed) {
        // sl<LibraryCountsCubit>().updateAlbums(albums.lengh);
      }
    } catch (e) {
      emit(AlbumError(e.toString()));
    }
  }

  Future<void> loadAlbumSongs(int albumId) async {
    if (state is! AlbumLoaded) return;
    try {
      final songs = await _repository.getSongsFromAlbum(albumId);
      final current = state as AlbumLoaded;
      emit(current.copyWith(songs: songs));
    } catch (e) {
      emit(AlbumError("Failed to load songs: $e"));
    }
  }

  void changeSort(AlbumSortOption newSort) {
    _currentSort = newSort;
    if (state is AlbumLoaded) {
      final albums = (state as AlbumLoaded).albums;
      final sorted = _sortAlbums(albums, newSort);
      emit((state as AlbumLoaded).copyWith(albums: sorted));
    }
  }
  void enableSelectionMode() {
    if (state is AlbumLoaded) {
      emit((state as AlbumLoaded).copyWith(isSelecting: true));
    }
  }

  void disableSelectionMode() {
    if (state is AlbumLoaded) {
      emit(
        (state as AlbumLoaded).copyWith(
          isSelecting: false,
          selectedAlbumIds: {},
        ),
      );
    }
  }

  void toggleAlbumSelection(int albumId) {
    if (state is AlbumLoaded) {
      final current = state as AlbumLoaded;
      final updated = Set<int>.from(current.selectedAlbumIds);
      if (updated.contains(albumId)) {
        updated.remove(albumId);
      } else {
        updated.add(albumId);
      }
      emit(current.copyWith(selectedAlbumIds: updated));
    }
  }

  List<AlbumModel> _sortAlbums(
    List<AlbumModel> albums,
    AlbumSortOption sortOption,
  ) {
    final list = List.of(albums);
    list.sort((a, b) {
      switch (sortOption) {
        case AlbumSortOption.name:
          return a.album.toLowerCase().compareTo(b.album.toLowerCase());
        case AlbumSortOption.numberOfSongsLargest:
          return b.numOfSongs.compareTo(a.numOfSongs);
        case AlbumSortOption.numberOfSongsSmallest:
          return a.numOfSongs.compareTo(b.numOfSongs);
      }
    });
    return list;
  }
}
