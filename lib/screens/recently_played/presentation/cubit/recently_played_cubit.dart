import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/recently_played/repository/recent_ab_repo.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'recently_played_state.dart';

enum RecentlySortOption { lastPlayedDesc, lastPlayedAsc }

class RecentlyPlayedCubit extends Cubit<RecentlyPlayedState> {
  final RecentAbRepo repository = sl<RecentAbRepo>();
  final Box _settingsBox = Hive.box('settingsBox');
  late final VoidCallback _listener;

  RecentlySortOption _currentSort = RecentlySortOption.lastPlayedDesc;
  RecentlySortOption get currentSort => _currentSort;

  RecentlyPlayedCubit() : super(RecentlyPlayedLoading()) {
    _listener = () {
      emit(
        RecentlyPlayedLoaded(
          _applySort(List.from(repository.recentItems.value)),
        ),
      );
    };
    repository.recentItems.addListener(_listener);

    _loadSortOption();
    load();
  }

  void _loadSortOption() {
    final savedSort = _settingsBox.get(
      'recentlySortOption',
      defaultValue: 'lastPlayedDesc',
    );
    _currentSort = RecentlySortOption.values.firstWhere(
      (e) => e.name == savedSort,
      orElse: () => RecentlySortOption.lastPlayedDesc,
    );
  }

  Future<void> load() async {
    try {
      await repository.load();
      emit(RecentlyPlayedLoaded(_applySort(repository.recentItems.value)));
    } catch (e) {
      emit(RecentlyPlayedError("Failed to load recently played"));
    }
  }

  void toggleSort() {
    _currentSort = _currentSort == RecentlySortOption.lastPlayedDesc
        ? RecentlySortOption.lastPlayedAsc
        : RecentlySortOption.lastPlayedDesc;

    _settingsBox.put('recentlySortOption', _currentSort.name);

    if (state is RecentlyPlayedLoaded) {
      final current = (state as RecentlyPlayedLoaded).items;
      emit(RecentlyPlayedLoaded(_applySort(List.from(current))));
    }
  }

  List<SongModel> _applySort(List<SongModel> items) {
    items.sort((a, b) {
      final aTime = a.getMap["playedAt"] ?? 0;
      final bTime = b.getMap["playedAt"] ?? 0;
      if (_currentSort == RecentlySortOption.lastPlayedDesc) {
        return bTime.compareTo(aTime);
      } else {
        return aTime.compareTo(bTime);
      }
    });
    return items;
  }

  Future<void> add(MediaItem item) async {
    await repository.add(item);
  }

  Future<void> clear() async {
    await repository.clear();
  }

  Future<void> delete(String id) async {
    await repository.delete(id);
  }

  @override
  Future<void> close() {
    repository.recentItems.removeListener(_listener);
    return super.close();
  }
}
