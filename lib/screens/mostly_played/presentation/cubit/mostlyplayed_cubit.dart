import 'dart:developer';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/mostly_played/repository/mostly_played_ab.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/cubit/library_counts_cubit.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'mostlyplayed_state.dart';

enum MostlyPlayedSortType { playCount, playedDuration }

class MostlyPlayedCubit extends Cubit<MostlyplayedState> {
  final MostlyPlayedRepo repository = sl<MostlyPlayedRepo>();
  late final VoidCallback _listener;
  final Box settingsBox = Hive.box('settingsBox');
  MostlyPlayedSortType _sortType = MostlyPlayedSortType.playCount;

  MostlyPlayedSortType get sortType => _sortType;

  MostlyPlayedCubit() : super(MostlyPlayedLoading()) {
    _listener = () {
      _emitSorted(repository.mostPlayedItems.value);
    };
    repository.mostPlayedItems.addListener(_listener);
    _loadSortOption();
    load();
    log(sortType.name.toString());
  }

  void _loadSortOption() {
    final savedSort = settingsBox.get(
      "mostlyPlayedSort",
      defaultValue: "playCount",
    );
    _sortType = MostlyPlayedSortType.values.firstWhere(
      (e) => e.name == savedSort,
      orElse: () => MostlyPlayedSortType.playCount,
    );
  }

  void toggleSort() {
    if (_sortType == MostlyPlayedSortType.playCount) {
      _sortType = MostlyPlayedSortType.playedDuration;
    } else {
      _sortType = MostlyPlayedSortType.playCount;
    }
    saveSortType(_sortType);
    _emitSorted(repository.mostPlayedItems.value);
  }

  void _emitSorted(List<SongModel> items) {
    final sorted = List<SongModel>.from(items);
    if (_sortType == MostlyPlayedSortType.playCount) {
      sorted.sort(
        (a, b) =>
            (b.getMap["playCount"] ?? 0).compareTo(a.getMap["playCount"] ?? 0),
      );
    } else {
      sorted.sort(
        (a, b) => (b.getMap["playedDuration"] ?? 0).compareTo(
          a.getMap["playedDuration"] ?? 0,
        ),
      );
    }
    emit(MostlyPlayedLoaded(sorted));
  }

  void saveSortType(MostlyPlayedSortType type) {
    settingsBox.put("mostlyPlayedSort", type.name);
  }

  Future<void> load() async {
    try {
      await repository.load();
      final item = repository.mostPlayedItems.value;
      _emitSorted(item);
      if (!isClosed) {
        sl<LibraryCountsCubit>().updateMostlyPlayed(item.length);
      }
    } catch (e) {
      emit(MostlyPlayedError("Failed to load mostly played"));
    }
  }

  Future<void> add(MediaItem item) async {
    await repository.add(item);
  }

  Future<void> clear() async {
    try {
      await repository.load();
      emit(MostlyPlayedLoaded(repository.mostPlayedItems.value));
    } catch (e) {
      emit(MostlyPlayedError("Failed to load mostly played"));
    }
  }

  Future<void> delete(String id) async {
    await repository.delete(id);
  }

  @override
  Future<void> close() {
    repository.mostPlayedItems.removeListener(_listener);
    return super.close();
  }
}
