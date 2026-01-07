import 'package:moz_updated_version/data/repository/saavn_repository.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class SongsRepository {
  final SaavnRepository _saavnRepository = sl<SaavnRepository>();

  Future<List<OnlineSongModel>> fetchSongsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final songMaps = await _saavnRepository.getSongsByIds(ids);

    return songMaps.map((e) => OnlineSongModel.fromJson(e)).toList();
  }
}
