import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/data/model/online_models/album_model.dart';
import 'package:moz_updated_version/data/model/online_models/artist_model.dart';
import 'package:moz_updated_version/data/model/online_models/media_collection.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/data/model/online_models/playlist_model.dart';

extension MediaItemHandler on MediaItem {
  Future<void> addToQueue(BaseAudioHandler handler) async {
    await handler.updateQueue([this]);
  }

  Future<void> setNowPlaying(BaseAudioHandler handler) async {
    handler.mediaItem.add(this);
  }
}

extension AlbumToUI on AlbumResponse {
  MediaCollectionUI get toUI => MediaCollectionUI(
    id: albumId ?? '',
    title: title ?? name ?? '',
    image: image ?? '',
    songCount: songs!.length,
    primaryArtist: primaryArtists,
  );
}

extension ArtistToUI on ArtistModelOnline {
  MediaCollectionUI get toUI => MediaCollectionUI(
    id: id ?? '',
    title: name ?? name ?? '',
    image: image ?? '',
    songCount: songs.length,
    primaryArtist: '',
  );
}

extension OnlineSongToUI on OnlineSongModel {
  MediaCollectionUI get toUI => MediaCollectionUI(
    id: id ?? '',
    title: song ?? song ?? '',
    image: image ?? '',
    songCount: 1,
    primaryArtist: artists![0].toString(),
  );
}

extension PlaylistToUI on PlaylistModel {
  MediaCollectionUI get toUI => MediaCollectionUI(
    id: id ?? '',
    title: name ?? '',
    image: image ?? '',
    songCount: songs.length,
  );
}
