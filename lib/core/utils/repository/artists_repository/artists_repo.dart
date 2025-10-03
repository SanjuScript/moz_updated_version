import 'package:on_audio_query/on_audio_query.dart';

abstract class ArtistRepository {
  Future<List<ArtistModel>> loadArtists();
  Future<ArtistModel?> getArtistById(int id);
  Future<List<SongModel>> getSongsFromArtist(int artistId);
}
