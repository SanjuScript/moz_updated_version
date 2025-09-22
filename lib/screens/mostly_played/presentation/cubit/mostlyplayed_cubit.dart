import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/db/mostly_played/repository/mostly_played_ab.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/cubit/library_counts_cubit.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'mostlyplayed_state.dart';

class MostlyPlayedCubit extends Cubit<MostlyplayedState> {
  final MostlyPlayedRepo repository = sl<MostlyPlayedRepo>();
  late final VoidCallback _listener;
  MostlyPlayedCubit() : super(MostlyPlayedLoading()) {
    _listener = () {
      emit(MostlyPlayedLoaded(List.from(repository.mostPlayedItems.value)));
    };
    repository.mostPlayedItems.addListener(_listener);
    load();
  }

  Future<void> load() async {
    try {
      await repository.load();
      final item = repository.mostPlayedItems.value;
      emit(MostlyPlayedLoaded(item));
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
    await repository.clear();
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
