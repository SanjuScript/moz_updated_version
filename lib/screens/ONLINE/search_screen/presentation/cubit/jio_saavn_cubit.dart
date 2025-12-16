import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/core/constants/api.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/data/model/online_models/trending_search_model.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/service_locator.dart';

part 'jio_saavn_state.dart';

class JioSaavnCubit extends Cubit<JioSaavnState> {
  final http.Client? httpClient;
  String? _lastQuery;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final List<OnlineSongModel> _songs = [];

  JioSaavnCubit({this.httpClient}) : super(JioSaavnInitial());

  http.Client get _client => httpClient ?? http.Client();

  Future<void> searchSongs(String query) async {
    if (query.trim().isEmpty) return;

    _lastQuery = query;
    _currentPage = 1;
    _hasMore = true;
    _songs.clear();

    emit(JioSaavnSearchLoading());

    await _fetchPage();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _lastQuery == null) return;

    _isLoadingMore = true;
    emit(JioSaavnSearchLoadingMore(List.from(_songs)));

    _currentPage++;
    await _fetchPage(isLoadMore: true);
    log(_currentPage.toString());

    _isLoadingMore = false;
  }

  Future<void> _fetchPage({bool isLoadMore = false}) async {
    try {
      final encodedQuery = Uri.encodeComponent(_lastQuery!);
      final url =
          '$api/search/all/?query=$encodedQuery&page=$_currentPage&n=10&lyrics=false';

      final response = await _client.get(Uri.parse(url));

      final data = json.decode(response.body);

      final results = (data['results'] as List)
          .map((e) => OnlineSongModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      _hasMore = data['has_more'] ?? false;
      _songs.addAll(results);

      emit(
        JioSaavnSearchSuccess(
          songs: List.from(_songs),
          hasMore: _hasMore,
          currentPage: _currentPage,
          total: _songs.length,
        ),
      );
    } catch (e) {
      emit(JioSaavnSearchError(e.toString()));
    }
  }

  Future<void> fetchTrendingSearches() async {
    emit(JioSaavnTrendingLoading());

    try {
      final response = await _client
          .get(
            Uri.parse('$api/topsearches/'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List) {
          final data = TrendingItemModel.parseTrendingItems(decoded);
          log(data.toString());
          emit(JioSaavnTrendingSuccess(data));
        } else {
          emit(const JioSaavnTrendingError('Invalid trending data format'));
        }
      } else {
        emit(
          JioSaavnTrendingError(
            'Failed to load trending: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      emit(JioSaavnTrendingError('Error fetching trending: ${e.toString()}'));
    }
  }

  Future<List<String>> getAutocompleteSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

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

        // Extract suggestions from the response
        if (data['songs'] != null && data['songs']['data'] != null) {
          for (var song in data['songs']['data']) {
            final title = song['title']?.toString() ?? '';
            if (title.isNotEmpty && !suggestions.contains(title)) {
              suggestions.add(title);
            }
          }
        }

        return suggestions.take(8).toList();
      }
    } catch (e) {
      log('Error getting autocomplete: $e', name: 'JIOSAAVN_CUBIT');
    }

    return [];
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
