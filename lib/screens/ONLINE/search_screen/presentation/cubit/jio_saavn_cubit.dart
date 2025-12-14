import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/core/constants/api.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/screens/ONLINE/home_screen/presentation/ui/home_page.dart';
part 'jio_saavn_state.dart';

class JioSaavnCubit extends Cubit<JioSaavnState> {
  final http.Client? httpClient;

  JioSaavnCubit({this.httpClient}) : super(JioSaavnInitial());

  // Use provided client or create new one
  http.Client get _client => httpClient ?? http.Client();

  Future<void> searchSongs(String query) async {
    if (query.trim().isEmpty) {
      emit(const JioSaavnSearchError('Search query cannot be empty'));
      return;
    }

    emit(JioSaavnSearchLoading());

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = '$api/search/all/?query=$encodedQuery&lyrics=false';

      log('JioSaavn API: Searching - $url', name: 'JIOSAAVN_CUBIT');

      final response = await _client
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        log(
          "First Song JSON: ${json.decode(response.body)[0]}",
          name: "JIO-SAAVN-SEARCH",
        );

        if (data is List) {
          final songs = data
              .map(
                (songJson) => OnlineSongModel.fromJson(
                  Map<String, dynamic>.from(songJson),
                ),
              )
              .toList();

          emit(JioSaavnSearchSuccess(songs));
        } else if (data is Map && data.containsKey('error')) {
          emit(JioSaavnSearchError(data['error'].toString()));
        } else {
          emit(const JioSaavnSearchError('Unexpected response format'));
        }
      } else {
        emit(
          JioSaavnSearchError('Failed to search songs: ${response.statusCode}'),
        );
      }
    } catch (e) {
      log('Error searching JioSaavn songs: $e', name: 'JIOSAAVN_CUBIT');
      emit(JioSaavnSearchError('Error searching songs: ${e.toString()}'));
    }
  }

  Future<void> getSongById(String songId) async {
    if (songId.trim().isEmpty) {
      emit(const JioSaavnSongError('Song ID cannot be empty'));
      return;
    }

    emit(JioSaavnSongLoading());

    try {
      final url = '$api/song/get/?id=$songId&lyrics=false';

      final response = await _client
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final song = OnlineSongModel.fromJson(Map<String, dynamic>.from(data));
        emit(JioSaavnSongSuccess(song));
      } else {
        emit(JioSaavnSongError('Failed to get song: ${response.statusCode}'));
      }
    } catch (e) {
      log('Error getting song by ID: $e', name: 'JIOSAAVN_CUBIT');
      emit(JioSaavnSongError('Error getting song: ${e.toString()}'));
    }
  }

  Future<void> getSongByUrl(String url) async {
    if (url.trim().isEmpty) {
      emit(const JioSaavnSongError('URL cannot be empty'));
      return;
    }

    emit(JioSaavnSongLoading());

    try {
      final encodedUrl = Uri.encodeComponent(url);
      final apiUrl = '$api/song/?query=$encodedUrl&lyrics=false';

      final response = await _client
          .get(Uri.parse(apiUrl), headers: {'Accept': 'application/json'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map) {
          final song = OnlineSongModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          emit(JioSaavnSongSuccess(song));
        } else {
          emit(const JioSaavnSongError('Unexpected response format'));
        }
      } else {
        emit(JioSaavnSongError('Failed to get song: ${response.statusCode}'));
      }
    } catch (e) {
      log('Error getting song by URL: $e', name: 'JIOSAAVN_CUBIT');
      emit(JioSaavnSongError('Error getting song: ${e.toString()}'));
    }
  }

  // Reset to initial state
  void reset() {
    emit(JioSaavnInitial());
  }

  @override
  Future<void> close() {
    // Close http client if we created it
    if (httpClient == null) {
      _client.close();
    }
    return super.close();
  }
}
