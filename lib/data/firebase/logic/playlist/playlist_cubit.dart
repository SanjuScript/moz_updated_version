import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/firebase/data/repository/playlist_repository.dart';
import 'package:moz_updated_version/data/firebase/data/song_repository.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/data/model/song_playlist_model/online_song_playlist.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';

part 'playlist_state.dart';

class OnlinePlaylistCubit extends Cubit<OnlinePlaylistState> {
  final OnlinePlaylistRepository _repo = OnlinePlaylistRepository.instance;

  StreamSubscription? _playlistSub;

  OnlinePlaylistCubit() : super(OnlinePlaylistInitial());

  void loadPlaylists() {
    _playlistSub?.cancel();
    _playlistSub = _repo.playlistsStream().listen(
      (playlists) {
        emit(OnlinePlaylistsLoaded(playlists));
      },
      onError: (e) {
        emit(OnlinePlaylistError(e.toString()));
      },
    );
  }

  Future<void> createPlaylist(String name) async {
    await _repo.createPlaylist(name);
  }

  Future<int?> getPlaylistCount() {
    return _repo.getPlaylistCount();
  }

  Future<void> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    await _repo.addSongToPlaylist(playlistId: playlistId, songId: songId);
  }

  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    await _repo.removeSong(playlistId: playlistId, songId: songId);
  }

  Future<void> deletePlaylist(String playlistId) async {
    if (state is! OnlinePlaylistsLoaded) return;

    final currentState = state as OnlinePlaylistsLoaded;
    final previousPlaylists = List.of(currentState.playlists);

    final updatedPlaylists = previousPlaylists
        .where((p) => p.id != playlistId)
        .toList();

    emit(OnlinePlaylistsLoaded(updatedPlaylists));

    try {
      await _repo.deletePlaylist(playlistId);
    } catch (e) {
      emit(OnlinePlaylistsLoaded(previousPlaylists));
    }
  }

  @override
  Future<void> close() {
    _playlistSub?.cancel();
    return super.close();
  }
}
