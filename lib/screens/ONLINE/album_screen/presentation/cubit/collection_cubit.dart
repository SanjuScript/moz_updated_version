import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:moz_updated_version/data/model/online_models/album_model.dart';
import 'package:moz_updated_version/data/model/online_models/artist_model.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/data/model/online_models/playlist_model.dart';
import 'package:moz_updated_version/data/repository/saavn_repository.dart';
import 'package:moz_updated_version/services/service_locator.dart';

part 'collection_state.dart';

class CollectionCubitForOnline extends Cubit<CollectionStateForOnline> {
  final SaavnRepository _saavnRepo = sl<SaavnRepository>();

  CollectionCubitForOnline() : super(CollectionLoading());

  Future<void> loadAlbum(String id, String type) async {
    emit(CollectionLoading());

    try {
      Map<String, dynamic> raw;

      switch (type) {
        case 'album':
          raw = await _saavnRepo.albumDetails(id);
          emit(AlbumLoaded(AlbumResponse.fromJson(raw)));
          break;

        case 'playlist':
          raw = await _saavnRepo.playlistDetails(id);
          log(raw.toString());
          emit(PlaylistLoaded(PlaylistModel.fromJson(raw)));
          break;

        case 'song':
          raw = await _saavnRepo.songDetails(id);
          emit(OnlineSongLoaded(OnlineSongModel.fromJson(raw)));
          break;

        default:
          emit(const CollectionError('Unsupported content type'));
      }
    } catch (e, stack) {
      log('$e\n$stack', name: 'COLLECTION');
      emit(CollectionError(e.toString()));
    }
  }

  Future<void> loadArtist(
    String artistId, {
    bool allSongs = false,
    int limit = 50,
  }) async {
    emit(CollectionLoading());

    try {
      final raw = await _saavnRepo.artistDetails(artistId);

      final artist = ArtistModelOnline.fromJson(raw);
      emit(ArtistLoaded(artist));
    } catch (e, stack) {
      log('$e\n$stack', name: 'ARTIST');
      emit(CollectionError(e.toString()));
    }
  }
}
