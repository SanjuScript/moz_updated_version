import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:moz_updated_version/data/db/language_db/respository/language_repo.dart';
import 'package:moz_updated_version/data/model/online_models/home_item_model.dart';
import 'package:moz_updated_version/services/service_locator.dart';

import 'package:moz_updated_version/data/repository/saavn_repository.dart';

part 'jio_saavn_home_state.dart';

class JioSaavnHomeCubit extends Cubit<JioSaavnHomeState> {
  final LanguageRepository _languageRepo = sl<LanguageRepository>();
  final SaavnRepository _saavnRepo = sl<SaavnRepository>();

  JioSaavnHomeCubit() : super(JioSaavnHomeLoading());

  Future<void> loadHomeData({bool forceRefresh = false}) async {
    // final selectedLanguages = await _languageRepo.getSelectedLanguages();

    // final languageKey = selectedLanguages.join(",");
    // final languages = selectedLanguages.isNotEmpty
    //     ? selectedLanguages.map((e) => e.toLowerCase()).toList()
    //     : null;

    // log("Home Languages: $languages", name: "JIOSAAVN_HOME");

    if (!forceRefresh && state is JioSaavnHomeSuccess) {
      log("Home already loaded. Skipping.", name: "JIOSAAVN_HOME");
      return;
    }

    emit(JioSaavnHomeLoading());

    try {
      final raw = await _saavnRepo.home();

      final home = JioSaavnHomeResponse.fromJson(raw);
      emit(JioSaavnHomeSuccess(home, languageKey: 'languageKey'));
    } catch (e, stack) {
      log("Home Exception: $e\n$stack", name: "JIOSAAVN_HOME");
      emit(JioSaavnHomeError(e.toString()));
    }
  }
}
