import 'package:moz_updated_version/data/data_source/saavn_remote_datasource.dart';

class SaavnRepository {
  final _ds = SaavnRemoteDatasource();

  Future<Map<String, dynamic>> searchAll(String q) => _ds.searchAll(q);

  Future<List<Map<String, dynamic>>> getSongsByIds(List<String> ids) =>
      _ds.getSongsByIds(ids);

  Future<Map<String, dynamic>> searchAlbums(
    String q, {
    int page = 1,
    int limit = 15,
  }) => _ds.searchAlbums(q, page: page, limit: limit);

  Future<Map<String, dynamic>> songDetails(String id) => _ds.songDetails(id);

  Future<Map<String, dynamic>> artistDetails(String id) =>
      _ds.artistDetails(id);

  Future<Map<String, dynamic>> albumDetails(String id) => _ds.albumDetails(id);

  Future<Map<String, dynamic>> playlistDetails(String id) =>
      _ds.playlistDetails(id);

  Future<Map<String, dynamic>> home() => _ds.home();

  Future<List> topSearches() => _ds.topSearches();

  Future<Map<String, dynamic>> autocomplete(String q) => _ds.autocomplete(q);
}
