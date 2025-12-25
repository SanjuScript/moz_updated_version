import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:moz_updated_version/data/db/language_db/respository/language_repo.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class SaavnHttpClient {
  static final _uas = [
    "Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) "
        "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1",
  ];

  static Future<String> get(String url, {List<String>? dlanguages}) async {
    final LanguageRepository languageRepo = sl<LanguageRepository>();

    final selectedLanguages = await languageRepo.getSelectedLanguages();

    final languageKey = selectedLanguages.join(",");
    final languages = selectedLanguages.isNotEmpty
        ? selectedLanguages.map((e) => e.toLowerCase()).toList()
        : null;

    final langs = (languages ?? ['english', 'hindi', 'tamil', 'malayalam'])
        .map((e) => e.toLowerCase())
        .join(',');

    final headers = {
      "User-Agent": _uas[Random().nextInt(_uas.length)],
      "Accept": "*/*",
      "Referer": "https://www.jiosaavn.com/",
      "Origin": "https://www.jiosaavn.com",
      "Cookie": "L=$langs",
    };

    final res = await http.get(Uri.parse(url), headers: headers);
    if (res.statusCode != 200) {
      throw Exception("Saavn HTTP ${res.statusCode}");
    }
    return res.body;
  }
}
