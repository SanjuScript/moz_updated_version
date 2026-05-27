import 'dart:convert';
import 'dart:developer';
import 'package:moz_updated_version/core/utils/saavn_format.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';

import '../../core/network/saavn_http_client.dart';
import '../../core/network/saavn_endpoints.dart';

class SaavnRemoteDatasource {
  Future<Map<String, dynamic>> autocomplete(
    String q, {
    List<String>? languages,
  }) async {
    final raw = await SaavnHttpClient.get(SaavnEndpoints.autocomplete(q));
    return json.decode(raw);
  }

  Future<Map<String, dynamic>> searchAll(
    String q, {
    int page = 1,
    int limit = 20,
    List<String>? languages,
  }) async {
    final raw = await SaavnHttpClient.get(
      SaavnEndpoints.searchAll(q, page, limit),
    );

    final data = json.decode(raw);
    final items = data['results'] as List;

    final songIds = items
        .where((e) => e['type'] == 'song' && e['id'] != null)
        .map((e) => e['id'].toString())
        .toList();

    return {
      "ids": songIds,
      "page": page,
      "total": data['total'],
      "has_more": (page * limit) < data['total'],
    };
  }

  Future<List<Map<String, dynamic>>> getSongsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final raw = await SaavnHttpClient.get(
      SaavnEndpoints.songDetails(ids.join(',')),
    );

    final decoded = json.decode(raw) as Map<String, dynamic>;

    return decoded.values.map((e) => SaavnFormatter.formatSong(e)).toList();
  }

  Future<Map<String, dynamic>> songDetails(
    String ids, {
    List<String>? languages,
  }) async {
    final raw = await SaavnHttpClient.get(SaavnEndpoints.songDetails(ids));

    final decoded = json.decode(raw) as Map<String, dynamic>;
    final song = decoded[ids] as Map<String, dynamic>;

    return SaavnFormatter.formatSong(song);
  }

  Future<Map<String, dynamic>> albumDetails(
    String id, {
    List<String>? languages,
  }) async {
    final raw = await SaavnHttpClient.get(SaavnEndpoints.albumDetails(id));

    final data = json.decode(raw);
    final songs = data['songs'] as List;

    data['songs'] = songs.map((e) => SaavnFormatter.formatSong(e)).toList();

    return data;
  }

  Future<Map<String, dynamic>> searchAlbums(
    String q, {
    int page = 1,
    int limit = 10,
    List<String>? languages,
  }) async {
    final raw = await SaavnHttpClient.get(
      SaavnEndpoints.searchAlbums(q, page, limit),
    );

    final data = json.decode(raw);
    final items = data['results'] as List;

    return {
      "results": items,
      "has_more": ((page * limit) < (data['total'] ?? 0)),
    };
  }

  Future<Map<String, dynamic>> playlistDetails(
    String id, {
    List<String>? languages,
  }) async {
    final raw = await SaavnHttpClient.get(SaavnEndpoints.playlistDetails(id));
    final data = json.decode(raw);

    if (data['songs'] != null && data['songs'] is List) {
      final songs = (data['songs'] as List);
      data['songs'] = songs
          .map((e) => SaavnFormatter.formatSong(e as Map<String, dynamic>))
          .toList();
    }

    log(data.toString(), name: "PLAYLIST DATA");
    return data;
  }

  Future<Map<String, dynamic>> lyrics(String id) async {
    final raw = await SaavnHttpClient.get(SaavnEndpoints.lyrics(id));
    return json.decode(raw);
  }

  Future<Map<String, dynamic>> home() async {
    final raw = await SaavnHttpClient.get(SaavnEndpoints.home());
    return json.decode(raw);
  }

  Future<List> topSearches({List<String>? languages}) async {
    final raw = await SaavnHttpClient.get(SaavnEndpoints.topSearches());
    return json.decode(raw);
  }

  Future<List> recoSong(String pid, {List<String>? languages}) async {
    final raw = await SaavnHttpClient.get(SaavnEndpoints.recoSong(pid));
    return json.decode(raw);
  }

  Future<List> recoAlbum(String id, {List<String>? languages}) async {
    final raw = await SaavnHttpClient.get(SaavnEndpoints.recoAlbum(id));
    return json.decode(raw);
  }

  Future<Map<String, dynamic>> artistDetails(String id) async {
    final raw = await SaavnHttpClient.get(SaavnEndpoints.artistDetails(id));

    final data = json.decode(raw) as Map<String, dynamic>;

    final topSongs = data['topSongs'];

    if (topSongs is List) {
      data['songs'] = topSongs
          .map<Map<String, dynamic>?>((e) {
            if (e is! Map<String, dynamic>) return null;

            final moreInfo = e['more_info'];

            final merged = {
              ...e,
              if (moreInfo is Map<String, dynamic>) ...moreInfo,
            };
            merged['song'] ??= merged['title'];

            final am = merged['artistMap'];
            if (am is Map<String, dynamic>) {
              final Map<String, String> flat = {};

              final primary = am['primary_artists'];
              if (primary is List) {
                for (final a in primary) {
                  if (a is Map<String, dynamic>) {
                    final name = a['name']?.toString();
                    final id = a['id']?.toString();
                    if (name != null && id != null) {
                      flat[name] = id;
                    }
                  }
                }
              }

              merged['artistMap'] = flat;
            }

            return SaavnFormatter.formatSong(merged);
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    } else {
      data['songs'] = <Map<String, dynamic>>[];
    }
    log(const JsonEncoder.withIndent('  ').convert(data), name: 'ARTISTS DATA');

    return data;
  }

  Future<List> artistOtherTopSongs(
    String id, {
    int page = 1,
    int limit = 20,
    List<String>? languages,
  }) async {
    final raw = await SaavnHttpClient.get(
      SaavnEndpoints.artistOtherTopSongs(id, page, limit),
    );
    final data = json.decode(raw);

    if (data['songs'] != null && data['songs'] is List) {
      final songs = (data['songs'] as List);
      data['songs'] = songs
          .map((e) => SaavnFormatter.formatSong(e as Map<String, dynamic>))
          .toList();
    }
    return data;
  }
}
