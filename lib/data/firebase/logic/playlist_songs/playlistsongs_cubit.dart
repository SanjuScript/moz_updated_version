import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/firebase/data/repository/playlist_repository.dart';
import 'package:moz_updated_version/data/firebase/data/song_repository.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/screens/ONLINE/favorite_screen/presentation/ui/playlist_song_view.dart';

part 'playlistsongs_state.dart';

class PlaylistsongsCubit extends Cubit<OnlinePlaylistsongsState> {
  final OnlinePlaylistRepository _repo = OnlinePlaylistRepository.instance;
  final SongsRepository _songsRepo = SongsRepository();
  StreamSubscription? _songsSub;

  PlaylistsongsCubit() : super(OnlinePlaylistsongsInitial());

  void loadPlaylistSongs(String playlistId) {
    _songsSub?.cancel();

    _songsSub = _repo.playlistSongIds(playlistId).listen((ids) async {
      if (ids.isEmpty) {
        emit(OnlinePlaylistSongsLoaded(playlistId, ids, []));
        return;
      }

      try {
        final songs = await _songsRepo.fetchSongsByIds(ids);
        emit(OnlinePlaylistSongsLoaded(playlistId, ids, songs));
      } catch (e) {
        emit(OnlinePlaylistSongsError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _songsSub?.cancel();

    return super.close();
  }
}
