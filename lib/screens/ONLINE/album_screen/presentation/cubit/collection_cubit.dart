import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/core/constants/api.dart';
import 'package:moz_updated_version/data/model/online_models/album_model.dart';
import 'package:moz_updated_version/data/model/online_models/artist_model.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/data/model/online_models/playlist_model.dart';

part 'collection_state.dart';

class CollectionCubitForOnline extends Cubit<CollectionStateForOnline> {
  CollectionCubitForOnline() : super(CollectionLoading());

  Future<void> loadAlbum(String albumId, String type) async {
    emit(CollectionLoading());

    try {
      final url = Uri.parse('$api/resolve?type=$type&query=$albumId');
      log('Fetching album: $url', name: 'ALBUM');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        emit(const CollectionError('Failed to load album'));
        return;
      }

      final json = jsonDecode(response.body);

      if (json is! Map<String, dynamic>) {
        emit(const CollectionError('Invalid album format'));
        return;
      }
      log(json.toString());

      switch (type) {
        case 'album':
          emit(AlbumLoaded(AlbumResponse.fromJson(json)));
          break;

        case 'playlist':
          emit(PlaylistLoaded(PlaylistModel.fromJson(json)));
          break;
        case "song":
          final data = OnlineSongModel.fromJson(json);
          log(data.toString());
          emit(OnlineSongLoaded(data));
          break;

        default:
          emit(const CollectionError('Unsupported content type'));
      }

      // final album = AlbumResponse.fromJson(json);
      // emit(AlbumLoaded(album));
    } catch (e, stack) {
      log('$e\n$stack', name: 'ALBUM');
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
      var url = '$api/resolve?type=artist&query=$artistId';
      final uri = Uri.parse(url);
      log('Fetching artist: $uri', name: 'ARTIST');

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        emit(const CollectionError('Failed to load artist'));
        return;
      }

      final json = jsonDecode(response.body);

      if (json is! Map<String, dynamic>) {
        emit(const CollectionError('Invalid artist format'));
        return;
      }

      final artist = ArtistModelOnline.fromJson(json);
      log(artist.toString());
      emit(ArtistLoaded(artist));
    } catch (e, stack) {
      log('$e\n$stack', name: 'ARTIST');
      emit(CollectionError(e.toString()));
    }
  }
}
