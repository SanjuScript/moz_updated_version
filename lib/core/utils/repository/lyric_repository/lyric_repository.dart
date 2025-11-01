import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moz_updated_version/core/utils/repository/lyric_repository/lyric_repo.dart';

class LyricsRepositoryImpl implements LyricsRepository {
  final String baseUrl = "https://lyric-backend-90k5.onrender.com";

  @override
  Future<String?> fetchLyrics(String title) async {
    final query = Uri.encodeComponent(title);
    final url = Uri.parse("$baseUrl/lyrics?query=$query");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["lyrics"] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching lyrics: $e");
      return null;
    }
  }
}
