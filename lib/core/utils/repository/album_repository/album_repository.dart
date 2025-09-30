import 'package:on_audio_query/on_audio_query.dart';

abstract class AlbumRepository {
  Future<List<AlbumModel>> loadAlbums();
  Future<AlbumModel?> getAlbumById(int id);
  Future<List<SongModel>> getSongsFromAlbum(int albumId);
}
