import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:moz_updated_version/core/utils/repository/lyric_repository/lyric_repo.dart';

class LyricsRepositoryImpl implements LyricsRepository {
  final String baseUrl = "https://lyric-backend-90k5.onrender.com";

  @override
  Future<String?> fetchLyrics(String title, {String? artist}) async {
    log("TITLE = $title", name: "LYRICS_FETCH");

    String? firstArtist;
    String? secondArtist;

    if (artist != null && artist.trim().isNotEmpty) {
      log("RAW_ARTIST = $artist", name: "LYRICS_FETCH");

      final parts = artist
          .split(RegExp(r'[,\/]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (parts.isNotEmpty) firstArtist = parts[0];
      if (parts.length > 1) secondArtist = parts[1];

      log(
        "firstArtist = $firstArtist  secondArtist = $secondArtist",
        name: "LYRICS_FETCH",
      );
    }

    final q1 = firstArtist != null ? "$title $firstArtist" : title;

    log("TRY#1 QUERY = $q1", name: "LYRICS_FETCH");
    final result1 = await _search(q1);

    if (result1 != null && result1.isNotEmpty) {
      log("SUCCESS#1", name: "LYRICS_FETCH");
      return result1;
    }

    log("FAIL#1  (no result) ", name: "LYRICS_FETCH");

    if (secondArtist != null) {
      final q2 = "$title $secondArtist";
      log("TRY#2 QUERY = $q2", name: "LYRICS_FETCH");
      final result2 = await _search(q2);

      if (result2 != null && result2.isNotEmpty) {
        log("SUCCESS#2", name: "LYRICS_FETCH");
        return result2;
      }

      log("FAIL#2  (no result) ", name: "LYRICS_FETCH");
    }

    log("NO LYRICS FOUND AT ALL", name: "LYRICS_FETCH");
    return null;
  }

  Future<String?> _search(String queryRaw) async {
    final query = Uri.encodeComponent(queryRaw);
    final url = Uri.parse("$baseUrl/lyrics?query=$query");

    log("REQUEST => $url", name: "LYRICS_FETCH");

    try {
      final response = await http.get(url);
      log("STATUS = ${response.statusCode}", name: "LYRICS_FETCH");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // log("RESPONSE = ${data.toString()}", name: "LYRICS_FETCH");
        return data["lyrics"] as String?;
      } else {
        log("BAD_STATUS", name: "LYRICS_FETCH");
        return null;
      }
    } catch (e) {
      log("EXCEPTION = $e", name: "LYRICS_FETCH");
      return null;
    }
  }

  @override
  Future<String?> transliterate(
    String text, {
    required String sourceLang,
  }) async {
    try {
      final lines = text.split('\n');
      final List<String> processedLines = [];

      const batchSize = 3;

      for (int i = 0; i < lines.length; i += batchSize) {
        final batch = lines.skip(i).take(batchSize).toList();

        final futures = batch.map((line) => _processLine(line, sourceLang));
        final batchResults = await Future.wait(futures);
        processedLines.addAll(batchResults);

        if (i + batchSize < lines.length) {
          await Future.delayed(const Duration(milliseconds: 20));
        }
      }

      log("Transliteration completed in ${lines.length} lines");
      log(processedLines.toString());
      return processedLines.join('\n');
    } catch (e) {
      log("Error transliterating text: $e");
      return null;
    }
  }

  Future<String> _processLine(String line, String sourceLang) async {
    final trimmedLine = line.trim();
    if (trimmedLine.isEmpty) return '';

    final timestampRegex = RegExp(r'^\[[\d:\.]+\]\s*');
    final match = timestampRegex.firstMatch(trimmedLine);

    if (match != null) {
      final timestamp = match.group(0)!;
      final lyricText = trimmedLine.substring(match.end);

      if (lyricText.isEmpty) {
        return timestamp;
      } else {
        final transliterated = await _transliterateSingleLine(
          lyricText,
          sourceLang,
        );
        return '$timestamp${transliterated ?? lyricText}';
      }
    } else {
      final transliterated = await _transliterateSingleLine(
        trimmedLine,
        sourceLang,
      );
      return transliterated ?? trimmedLine;
    }
  }

  Future<String?> _transliterateSingleLine(
    String text,
    String sourceLang,
  ) async {
    try {
      final encoded = Uri.encodeComponent(text);
      final url = Uri.parse(
        "https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLang&tl=en&dt=rm&q=$encoded",
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        log("API returned status: ${response.statusCode}");
        return null;
      }

      final data = jsonDecode(response.body);

      if (data != null && data is List && data.isNotEmpty) {
        if (data[0] != null && data[0] is List) {
          for (var item in data[0]) {
            if (item is List && item.length > 3 && item[3] != null) {
              return item[3] as String;
            }
          }
        }
      }

      return await _fallbackTransliterate(text, sourceLang);
    } catch (e) {
      log("Error transliterating line: $e");
      return await _fallbackTransliterate(text, sourceLang);
    }
  }

  Future<String?> _fallbackTransliterate(String text, String sourceLang) async {
    try {
      final encoded = Uri.encodeComponent(text);
      final url = Uri.parse(
        "https://inputtools.google.com/request?text=$encoded&itc=$sourceLang-t-i0-und&num=1&cp=0&cs=1&ie=utf-8&oe=utf-8&app=demopage",
      );

      final response = await http.get(url);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);

      if (data[0] == "SUCCESS" && data[1] != null) {
        if (data[1][0] != null && data[1][0][1] != null) {
          final suggestions = data[1][0][1] as List;
          if (suggestions.isNotEmpty) {
            return suggestions[0] as String;
          }
        }
      }

      return null;
    } catch (e) {
      log("Fallback transliteration error: $e");
      return null;
    }
  }
}
