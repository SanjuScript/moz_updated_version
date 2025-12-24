import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:moz_updated_version/core/constants/api.dart';
import 'package:moz_updated_version/data/db/language_db/respository/language_repo.dart';
import 'package:moz_updated_version/data/model/online_models/home_item_model.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/ui/home_page.dart';

import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:moz_updated_version/services/service_locator.dart';

part 'jio_saavn_home_state.dart';

class JioSaavnHomeCubit extends Cubit<JioSaavnHomeState> {
  final LanguageRepository _languageRepo = sl<LanguageRepository>();

  JioSaavnHomeCubit() : super(JioSaavnHomeLoading());

  Future<void> loadHomeData({bool forceRefresh = false}) async {
    // final selectedLanguages = await _languageRepo.getSelectedLanguages();
    final selectedLanguages = [];

    if (selectedLanguages.isEmpty) {
      log(
        "No languages selected. Using backend defaults.",
        name: "JIOSAAVN_HOME",
      );
    }
    final languageKey = selectedLanguages.join(",");

    final query = selectedLanguages.isNotEmpty ? "?languages=$languageKey" : "";
    log(name: "HEADER QUERY HOME PAGE", query.toLowerCase());
    log(name: "HEADER QUERY HOME KEY", languageKey.toLowerCase());

    if (!forceRefresh && state is JioSaavnHomeSuccess) {
      log("Home data already loaded. Skipping refresh.", name: "JIOSAAVN_HOME");
      return;
    }

    emit(JioSaavnHomeLoading());

    try {
      final url = Uri.parse("$api/home/$query");
      log("Fetching Home Data: $url", name: "JIOSAAVN_HOME");

      final response = await http
          .get(url, headers: {"Accept": "application/json"})
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception("Home request timeout"),
          );

      if (response.statusCode == 200) {
        final rawJson = response.body;
        final data = jsonDecode(rawJson);
        // log("Home Response Loaded", name: "JIOSAAVN_HOME");
        // log(data.keys.toString(), name: "JIOSAAVN_HOME_RAW");

        for (final key in data.keys) {
          log(key, name: "JIOSAAVN_KEY");
        }
        // Clipboard.setData(ClipboardData(text: rawJson));
        // log(data.toString(), name: "HOME DATA");

        final modules = data['modules'];

        final decoded = json.decode(rawJson);
        if (decoded is Map<String, dynamic>) {
          final home = JioSaavnHomeResponse.fromJson(decoded);
          emit(JioSaavnHomeSuccess(home, languageKey: languageKey));
        } else {
          emit(const JioSaavnHomeError("Invalid format received"));
        }
      } else {
        emit(JioSaavnHomeError("Home fetch failed: ${response.statusCode}"));
      }
    } catch (e, stack) {
      log("Home Exception: $e\n$stack", name: "JIOSAAVN_HOME");
      emit(JioSaavnHomeError(e.toString()));
    }
  }
}
