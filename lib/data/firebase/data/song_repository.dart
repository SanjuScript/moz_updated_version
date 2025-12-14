import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:moz_updated_version/core/constants/api.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';

class SongsRepository {
  Future<List<OnlineSongModel>> fetchSongsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final res = await http.post(
      Uri.parse("$api/song/get/bulk"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"ids": ids}),
    );

    // log(res.body.toString());
    if (res.statusCode != 200) {
      throw Exception("Failed to load songs");
    }

    final data = jsonDecode(res.body)["data"] as List;
    log(data.toString());
    return data.map((e) => OnlineSongModel.fromJson(e)).toList();
  }
}
