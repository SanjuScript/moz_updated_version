import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/firebase/data/repository/recently_played_repository.dart';

part 'online_recently_played_state.dart';

class OnlineRecentlyPlayedCubit extends Cubit<OnlineRecentlyPlayedState> {
  StreamSubscription<List<String>>? _sub;
  final OnlineRecentlyPlayedRepository _repo = OnlineRecentlyPlayedRepository();

  OnlineRecentlyPlayedCubit() : super(OnlineRecentlyPlayedInitial());

  void init() {
    _sub?.cancel();
    emit(OnlineRecentlyPlayedLoading());

    _sub = _repo.watchSongIds().listen(
      (ids) {
        emit(OnlineRecentlyPlayedLoaded(ids));
      },
      onError: (e) {
        emit(OnlineRecentlyPlayedError(e.toString()));
      },
    );
  }

  Future<void> refresh() async {
    try {
      emit(OnlineRecentlyPlayedLoading());
      final ids = await _repo.fetchSongIds();
      emit(OnlineRecentlyPlayedLoaded(ids));
    } catch (e) {
      emit(OnlineRecentlyPlayedError(e.toString()));
    }
  }

  Future<void> add(String songId) async {
    try {
      await _repo.add(songId);
    } catch (e) {
      emit(OnlineRecentlyPlayedError(e.toString()));
    }
  }

  Future<void> clear() async {
    try {
      await _repo.clear();
      emit(const OnlineRecentlyPlayedLoaded([]));
    } catch (e) {
      emit(OnlineRecentlyPlayedError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
