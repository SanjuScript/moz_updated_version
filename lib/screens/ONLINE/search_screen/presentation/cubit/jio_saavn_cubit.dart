import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/core/constants/api.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:moz_updated_version/data/model/online_models/oline_album_search_model.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/data/model/online_models/trending_search_model.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/widgets/search_chips.dart';

part 'jio_saavn_state.dart';

class JioSaavnCubit extends Cubit<JioSaavnState> {
  final http.Client? httpClient;
  String? _lastQuery;
  int _songPage = 1;
  int _albumPage = 1;
  bool _isLoadingMore = false;
  bool _songsHasMore = true;
  bool _albumsHasMore = true;
  final List<OnlineSongModel> _songs = [];
  final List<OnlineAlbumSearchModel> _albums = [];

  SearchFilter _currentFilter = SearchFilter.allSongs;

  JioSaavnCubit({this.httpClient}) : super(JioSaavnInitial());

  SearchFilter get currentFilter => _currentFilter;

  http.Client get _client => httpClient ?? http.Client();

  void changeFilter(SearchFilter filter) {
    if (_currentFilter == filter) return;

    _currentFilter = filter;

    if (_lastQuery == null || _lastQuery!.isEmpty) return;

    if (filter == SearchFilter.allSongs) {
      if (_songs.isNotEmpty) {
        emit(
          JioSaavnSearchSuccess(
            songs: List.from(_songs),
            currentPage: _songPage,
            hasMore: _songsHasMore,
            total: _songs.length,
          ),
        );
      } else {
        searchSongs(_lastQuery!);
      }
    } else if (filter == SearchFilter.albums) {
      if (_albums.isNotEmpty) {
        emit(
          JioSaavnAlbumSearchSuccess(
            albums: List.from(_albums),
            currentPage: _albumPage,
            hasMore: _albumsHasMore,
            total: _albums.length,
          ),
        );
      } else {
        searchAlbums(_lastQuery!);
      }
    }
  }

  Future<void> searchAlbums(String query) async {
    final bool isNewQuery = _lastQuery != query;

    if (isNewQuery) {
      _albums.clear();
      _albumPage = 1;
      _albumsHasMore = true;
      _lastQuery = query;
    }

    if (!isNewQuery && _albums.isNotEmpty) {
      _currentFilter = SearchFilter.albums;
      emit(
        JioSaavnAlbumSearchSuccess(
          albums: List.from(_albums),
          currentPage: _albumPage,
          hasMore: _albumsHasMore,
          total: _albums.length,
        ),
      );
      return;
    }

    _currentFilter = SearchFilter.albums;
    emit(JioSaavnAlbumSearchLoading());
    await _fetchAlbumsPage();
  }

  Future<void> loadMoreAlbums() async {
    if (_isLoadingMore || !_albumsHasMore || _lastQuery == null) return;

    _isLoadingMore = true;
    emit(JioSaavnAlbumSearchLoadingMore(List.from(_albums)));

    _albumPage++;
    await _fetchAlbumsPage(isLoadMore: true);

    _isLoadingMore = false;
  }

  Future<void> _fetchAlbumsPage({bool isLoadMore = false}) async {
    try {
      final encodedQuery = Uri.encodeComponent(_lastQuery!);
      final url =
          '$api/search/albums/?query=$encodedQuery&page=$_albumPage&n=10';

      final response = await _client.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to load albums');
      }

      final data = json.decode(response.body);
      log(name: "ALBUM DATA", data.toString());
      final results = (data['results'] as List)
          .map(
            (e) =>
                OnlineAlbumSearchModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();

      _albumsHasMore = data['has_more'] ?? false;
      _albums.addAll(results);

      emit(
        JioSaavnAlbumSearchSuccess(
          albums: List.from(_albums),
          hasMore: _albumsHasMore,
          currentPage: _albumPage,
          total: _albums.length,
        ),
      );
    } catch (e) {
      emit(JioSaavnAlbumSearchError(e.toString()));
    }
  }

  Future<void> searchSongs(String query) async {
    final bool isNewQuery = _lastQuery != query;

    if (isNewQuery) {
      _songs.clear();
      _albums.clear();
      _songPage = 1;
      _albumPage = 1;
      _songsHasMore = true;
      _albumsHasMore = true;
      _lastQuery = query;
    }

    if (!isNewQuery && _songs.isNotEmpty) {
      _currentFilter = SearchFilter.allSongs;
      emit(
        JioSaavnSearchSuccess(
          songs: List.from(_songs),
          currentPage: _songPage,
          hasMore: _songsHasMore,
          total: _songs.length,
        ),
      );
      return;
    }

    _currentFilter = SearchFilter.allSongs;
    emit(JioSaavnSearchLoading());
    await _fetchSongsPage();
  }

  Future<void> loadMore() async {
    if (_currentFilter == SearchFilter.albums) {
      return loadMoreAlbums();
    }

    if (_isLoadingMore || !_songsHasMore || _lastQuery == null) return;

    _isLoadingMore = true;
    emit(JioSaavnSearchLoadingMore(List.from(_songs)));

    _songPage++;
    await _fetchSongsPage(isLoadMore: true);
    log(_songPage.toString());

    _isLoadingMore = false;
  }

  Future<void> _fetchSongsPage({bool isLoadMore = false}) async {
    try {
      final encodedQuery = Uri.encodeComponent(_lastQuery!);
      final url =
          '$api/search/all/?query=$encodedQuery&page=$_songPage&n=10&lyrics=false';

      final response = await _client.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to load songs');
      }

      final data = json.decode(response.body);

      final results = (data['results'] as List)
          .map((e) => OnlineSongModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      _songsHasMore = data['has_more'] ?? false;
      _songs.addAll(results);

      emit(
        JioSaavnSearchSuccess(
          songs: List.from(_songs),
          hasMore: _songsHasMore,
          currentPage: _songPage,
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

  void clearSearchField() {}

  void reset() {
    _lastQuery = null;
    _songPage = 1;
    _albumPage = 1;
    _songsHasMore = true;
    _albumsHasMore = true;
    _songs.clear();
    _albums.clear();
    _currentFilter = SearchFilter.allSongs;
    emit(JioSaavnInitial());
  }

  @override
  Future<void> close() {
    if (httpClient == null) {
      _client.close();
    }
    return super.close();
  }
}
