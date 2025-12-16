import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/core/constants/api.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

part 'autocomplete_state.dart';

class AutocompleteCubit extends Cubit<AutocompleteState> {
  final http.Client? httpClient;

  AutocompleteCubit({this.httpClient}) : super(AutocompleteInitial());

  http.Client get _client => httpClient ?? http.Client();

  Future<void> fetchSuggestions(String query) async {
    if (query.trim().isEmpty) {
      emit(AutocompleteInitial());
      return;
    }

    emit(AutocompleteLoading());

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = '$api/autocomplete/?query=$encodedQuery';

      final response = await _client
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<String> suggestions = [];

        // Extract suggestions from songs
        if (data['songs'] != null && data['songs']['data'] != null) {
          for (var song in data['songs']['data']) {
            final title = song['title']?.toString() ?? '';
            if (title.isNotEmpty && !suggestions.contains(title)) {
              suggestions.add(title);
            }
          }
        }

        // Extract suggestions from albums
        if (data['albums'] != null && data['albums']['data'] != null) {
          for (var album in data['albums']['data']) {
            final title = album['title']?.toString() ?? '';
            if (title.isNotEmpty && !suggestions.contains(title)) {
              suggestions.add(title);
            }
          }
        }

        // Extract suggestions from artists
        if (data['artists'] != null && data['artists']['data'] != null) {
          for (var artist in data['artists']['data']) {
            final name = artist['name']?.toString() ?? '';
            if (name.isNotEmpty && !suggestions.contains(name)) {
              suggestions.add(name);
            }
          }
        }

        emit(AutocompleteSuccess(suggestions.take(8).toList()));
      } else {
        emit(AutocompleteError('Failed to load suggestions'));
      }
    } catch (e) {
      log('Error getting autocomplete: $e', name: 'AUTOCOMPLETE_CUBIT');
      emit(AutocompleteError(e.toString()));
    }
  }

  void clearSuggestions() {
    emit(AutocompleteInitial());
  }

  @override
  Future<void> close() {
    if (httpClient == null) {
      _client.close();
    }
    return super.close();
  }
}
