import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/data/db/recently_played/repository/recent_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'recently_played_state.dart';

class RecentlyPlayedCubit extends Cubit<RecentlyPlayedState> {
  final RecentlyPlayedRepository repository;
  late final VoidCallback _listener;
  RecentlyPlayedCubit(this.repository) : super(RecentlyPlayedLoading()) {
    _listener = () {
      emit(RecentlyPlayedLoaded(List.from(repository.recentItems.value)));
    };
    repository.recentItems.addListener(_listener);

    load();
  }

  Future<void> load() async {
    try {
      await repository.load();
      emit(RecentlyPlayedLoaded(repository.recentItems.value));
    } catch (e) {
      emit(RecentlyPlayedError("Failed to load recently played"));
    }
  }

  Future<void> add(SongModel item) async {
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
