import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/db/removed/repository/removed_ab_repo.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'removed_state.dart';

class RemovedCubit extends Cubit<RemovedState> {
  final RemovedAbRepo repository = sl<RemovedAbRepo>();
  late final VoidCallback _listener;

  RemovedCubit() : super(RemovedLoading()) {
    _listener = () {
      emit(RemovedLoaded(List.from(repository.removedItems.value)));
    };
    repository.removedItems.addListener(_listener);

    load();
  }

  Future<void> load() async {
    try {
      await repository.load();
      emit(RemovedLoaded(repository.removedItems.value));
    } catch (e) {
      emit(RemovedError("Failed to load removed songs"));
    }
  }

  Future<void> toggleRemoved(SongModel song) async {
    if (repository.isRemoved(song.id.toString())) {
      await repository.remove(song.id.toString());
    } else {
      await repository.add(song);
    }
  }

  bool isRemoved(String id) => repository.isRemoved(id);

  @override
  Future<void> close() {
    repository.removedItems.removeListener(_listener);
    return super.close();
  }
}
