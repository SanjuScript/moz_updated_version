import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repo.dart';
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

  AllSongsCubit() : super(AllsongsInitial()) {
    _loadSortOption();
  }

  void _loadSortOption() {
    final savedSort = _settingsBox.get('songSortOption', defaultValue: 'dateAdded');
    _currentSort = SongSortOption.values.firstWhere(
      (e) => e.name == savedSort,
      orElse: () => SongSortOption.dateAdded,
    );
  }

  Future<void> loadSongs() async {
    try {
      emit(AllSongsLoading());
      final songs = await _repository.loadSongs();
      final sortedSongs = _sortSongs(songs, _currentSort);
      emit(AllSongsLoaded(sortedSongs));
    } catch (e) {
      emit(AllSongsError(e.toString()));
    }
  }

  void changeSort(SongSortOption newSort) {
    _currentSort = newSort;
    _settingsBox.put('songSortOption', newSort.name);

    if (state is AllSongsLoaded) {
      final songs = (state as AllSongsLoaded).songs;
      final sortedSongs = _sortSongs(songs, newSort);
      emit(AllSongsLoaded(sortedSongs));
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