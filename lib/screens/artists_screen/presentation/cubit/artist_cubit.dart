import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/core/utils/repository/artists_repository/artists_repo.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'artist_state.dart';

enum ArtistSortOption { name, numberOfAlbums, numberOfTracks }

class ArtistCubit extends Cubit<ArtistState> {
  final ArtistRepository _repository = sl<ArtistRepository>();
  final Box _settingsBox = Hive.box('settingsBox');

  ArtistSortOption _currentSort = ArtistSortOption.name;
  ArtistSortOption get currentSort => _currentSort;

  ArtistCubit() : super(ArtistInitial());

  Future<void> loadArtists() async {
    try {
      emit(ArtistLoading());
      final artists = await _repository.loadArtists();
      final sorted = _sortArtists(artists, _currentSort);
      emit(ArtistLoaded(sorted));
      if (!isClosed) {
        // sl<LibraryCountsCubit>().updateArtists(artists.length);
      }
    } catch (e) {
      emit(ArtistError(e.toString()));
    }
  }

  Future<void> loadArtistSongs(int artistId) async {
    if (state is! ArtistLoaded) return;
    try {
      final songs = await _repository.getSongsFromArtist(artistId);
      final current = state as ArtistLoaded;
      emit(current.copyWith(songs: songs));
    } catch (e) {
      emit(ArtistError("Failed to load songs: $e"));
    }
  }

  void changeSort(ArtistSortOption newSort) {
    _currentSort = newSort;
    if (state is ArtistLoaded) {
      final artists = (state as ArtistLoaded).artists;
      final sorted = _sortArtists(artists, newSort);
      emit((state as ArtistLoaded).copyWith(artists: sorted));
    }
  }

  void enableSelectionMode() {
    if (state is ArtistLoaded) {
      emit((state as ArtistLoaded).copyWith(isSelecting: true));
    }
  }

  void disableSelectionMode() {
    if (state is ArtistLoaded) {
      emit(
        (state as ArtistLoaded).copyWith(
          isSelecting: false,
          selectedArtistIds: {},
        ),
      );
    }
  }

  void toggleArtistSelection(int artistId) {
    if (state is ArtistLoaded) {
      final current = state as ArtistLoaded;
      final updated = Set<int>.from(current.selectedArtistIds);
      if (updated.contains(artistId)) {
        updated.remove(artistId);
      } else {
        updated.add(artistId);
      }
      emit(current.copyWith(selectedArtistIds: updated));
    }
  }

  List<ArtistModel> _sortArtists(
    List<ArtistModel> artists,
    ArtistSortOption sortOption,
  ) {
    final list = List.of(artists);
    list.sort((a, b) {
      switch (sortOption) {
        case ArtistSortOption.name:
          return a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
        case ArtistSortOption.numberOfAlbums:
          return b.numberOfAlbums!.compareTo(a.numberOfAlbums!);
        case ArtistSortOption.numberOfTracks:
          return b.numberOfTracks!.compareTo(a.numberOfTracks!);
      }
    });
    return list;
  }
}
