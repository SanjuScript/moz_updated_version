import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moz_updated_version/core/utils/repository/lyric_repository/lyric_repo.dart';

class LyricsRepositoryImpl implements LyricsRepository {
  @override
  Future<String?> fetchLyrics(String artist, String title) async {
    final url = Uri.parse("https://api.lyrics.ovh/v1/$artist/$title");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["lyrics"] as String?;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }
}
