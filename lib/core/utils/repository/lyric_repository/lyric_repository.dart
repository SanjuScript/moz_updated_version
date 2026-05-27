import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:moz_updated_version/core/extensions/capitalize.dart';
import 'package:moz_updated_version/core/utils/repository/lyric_repository/lyric_repo.dart';

class LyricsRepositoryImpl implements LyricsRepository {
  final String baseUrl = "https://darkmesh.tail6e7dd0.ts.net";
  // API key will be loaded from .env at runtime

  @override
  Future<String?> fetchLyrics(
    String title, {
    String? artist,
    bool syncedOnly = false,
    bool plainOnly = false,
    String? lang,
    bool enhanced = false,
  }) async {
    final cleanTitle = title.cleanTitle;

    String? firstArtist;
    String? secondArtist;

    if (artist != null && artist.trim().isNotEmpty) {
      final parts = artist
          .split(RegExp(r'[,/\\]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) firstArtist = parts[0];
      if (parts.length > 1) secondArtist = parts[1];
    }

    final queries = <String>[
      if (firstArtist != null) "$cleanTitle $firstArtist",
      if (secondArtist != null) "$cleanTitle $secondArtist",
      cleanTitle,
    ];

    if (queries.isEmpty) return null;

    // Launch all searches in parallel
    final List<Future<String?>> futures = queries.map((q) => _search(
          q,
          syncedOnly: syncedOnly,
          plainOnly: plainOnly,
          lang: lang,
          enhanced: enhanced,
        )).toList();

    final completer = Completer<String?>();
    int completed = 0;
    final total = futures.length;
    final List<String?> results = List.filled(total, null);
    final List<bool> finished = List.filled(total, false);

    for (int i = 0; i < total; i++) {
      futures[i].then((res) {
        if (completer.isCompleted) return;
        finished[i] = true;
        results[i] = res;
        if (res != null && res.isNotEmpty) {
          if (i == 0) {
            completer.complete(res);
            return;
          }
          bool higherFailed = true;
          for (int j = 0; j < i; j++) {
            if (!finished[j] || (results[j] != null && results[j]!.isNotEmpty)) {
              higherFailed = false;
              break;
            }
          }
          if (higherFailed) {
            completer.complete(res);
            return;
          }
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (!completer.isCompleted) {
              for (int j = 0; j < i; j++) {
                if (results[j] != null && results[j]!.isNotEmpty) {
                  completer.complete(results[j]);
                  return;
                }
              }
              completer.complete(res);
            }
          });
        } else {
          completed++;
          if (completed == total && !completer.isCompleted) {
            String? finalRes;
            for (final r in results) {
              if (r != null && r.isNotEmpty) {
                finalRes = r;
                break;
              }
            }
            completer.complete(finalRes);
          }
        }
      }).catchError((e) {
        if (completer.isCompleted) return;
        finished[i] = true;
        completed++;
        if (completed == total && !completer.isCompleted) {
          completer.complete(null);
        }
      });
    }

    return completer.future;
  }

  Future<String?> _search(
    String queryRaw, {
    bool syncedOnly = false,
    bool plainOnly = false,
    String? lang,
    bool enhanced = false,
  }) async {
    final queryParams = <String, String>{
      'query': queryRaw,
      'synced_only': syncedOnly.toString(),
      'plain_only': plainOnly.toString(),
      'enhanced': enhanced.toString(),
      if (lang != null && lang.isNotEmpty) 'lang': lang,
    };

    final baseUri = Uri.parse("$baseUrl/lyrics/");
    final url = baseUri.replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        url,
        headers: {"x-api-key": dotenv.get('LYRIC_API_KEY')},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["lyrics"] as String?;
      }
      return null;
    } catch (e) {
      log("Lyrics fetch error: $e", name: "LYRICS_FETCH");
      return null;
    }
  }

  @override
  Future<String?> transliterate(
    String text, {
    required String sourceLang,
  }) async {
    try {
      final lines = text.split('\\n');
      final List<String> processed = [];
      const batchSize = 3;
      for (int i = 0; i < lines.length; i += batchSize) {
        final batch = lines.skip(i).take(batchSize).toList();
        final futures = batch.map((l) => _processLine(l, sourceLang));
        processed.addAll(await Future.wait(futures));
        if (i + batchSize < lines.length) {
          await Future.delayed(const Duration(milliseconds: 20));
        }
      }
      log("Transliteration completed in ${lines.length} lines");
      return processed.join('\\n');
    } catch (e) {
      log("Error transliterating text: $e");
      return null;
    }
  }

  Future<String> _processLine(String line, String sourceLang) async {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return '';
    final timestampRegex = RegExp(r'^\\[[\\d:\\.]+\\]\\s*');
    final match = timestampRegex.firstMatch(trimmed);
    if (match != null) {
      final timestamp = match.group(0)!;
      final lyric = trimmed.substring(match.end);
      if (lyric.isEmpty) return timestamp;
      final trans = await _transliterateSingleLine(lyric, sourceLang);
      return '$timestamp${trans ?? lyric}';
    } else {
      final trans = await _transliterateSingleLine(trimmed, sourceLang);
      return trans ?? trimmed;
    }
  }

  Future<String?> _transliterateSingleLine(String text, String sourceLang) async {
    try {
      final encoded = Uri.encodeComponent(text);
      final url = Uri.parse(
          "https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLang&tl=en&dt=rm&q=$encoded");
      final response = await http.get(url);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      if (data != null && data is List && data.isNotEmpty && data[0] is List) {
        for (var item in data[0]) {
          if (item is List && item.length > 3 && item[3] != null) return item[3] as String;
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
          "https://inputtools.google.com/request?text=$encoded&itc=$sourceLang-t-i0-und&num=1&cp=0&cs=1&ie=utf-8&oe=utf-8&app=demopage");
      final response = await http.get(url);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      if (data[0] == "SUCCESS" && data[1] != null) {
        final suggestions = data[1][0][1] as List?;
        if (suggestions != null && suggestions.isNotEmpty) return suggestions[0] as String;
      }
      return null;
    } catch (e) {
      log("Fallback transliteration error: $e");
      return null;
    }
  }
}
