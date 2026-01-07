import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:moz_updated_version/data/repository/saavn_repository.dart'
    show SaavnRepository;
import 'package:moz_updated_version/services/service_locator.dart';

part 'autocomplete_state.dart';

class AutocompleteCubit extends Cubit<AutocompleteState> {
  final SaavnRepository _saavnRepository = sl<SaavnRepository>();

  AutocompleteCubit() : super(AutocompleteInitial());

  Future<void> fetchSuggestions(String query) async {
    if (query.trim().isEmpty) {
      emit(AutocompleteInitial());
      return;
    }

    emit(AutocompleteLoading());

    try {
      final data = await _saavnRepository.autocomplete(query);

      final List<String> suggestions = [];

      // Songs
      if (data['songs']?['data'] is List) {
        for (final song in data['songs']['data']) {
          final title = song['title']?.toString();
          if (title != null && title.isNotEmpty) {
            suggestions.add(title);
          }
        }
      }

      // Albums
      if (data['albums']?['data'] is List) {
        for (final album in data['albums']['data']) {
          final title = album['title']?.toString();
          if (title != null && title.isNotEmpty) {
            suggestions.add(title);
          }
        }
      }

      // Artists
      if (data['artists']?['data'] is List) {
        for (final artist in data['artists']['data']) {
          final name = artist['name']?.toString();
          if (name != null && name.isNotEmpty) {
            suggestions.add(name);
          }
        }
      }

      final unique = suggestions.toSet().take(8).toList();

      emit(AutocompleteSuccess(unique));
    } catch (e, stack) {
      log('Autocomplete error: $e\n$stack', name: 'AUTOCOMPLETE_CUBIT');
      emit(AutocompleteError(e.toString()));
    }
  }

  void clearSuggestions() {
    emit(AutocompleteInitial());
  }
}
