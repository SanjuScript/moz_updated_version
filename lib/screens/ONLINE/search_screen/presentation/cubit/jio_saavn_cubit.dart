import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/data/model/online_models/oline_album_search_model.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/data/model/online_models/trending_search_model.dart';
import 'package:moz_updated_version/data/repository/saavn_repository.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/widgets/search_chips.dart';
import 'package:moz_updated_version/services/service_locator.dart';

part 'jio_saavn_state.dart';

class JioSaavnCubit extends Cubit<JioSaavnState> {
  String? _lastQuery;
  int _songPage = 1;
  int _albumPage = 1;
  bool _isLoadingMore = false;
  bool _songsHasMore = true;
  bool _albumsHasMore = true;
  final List<OnlineSongModel> _songs = [];
  final List<OnlineAlbumSearchModel> _albums = [];

  SearchFilter _currentFilter = SearchFilter.allSongs;
  final SaavnRepository _saavnRepository = sl<SaavnRepository>();

  JioSaavnCubit() : super(JioSaavnInitial());

  SearchFilter get currentFilter => _currentFilter;

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
      final data = await _saavnRepository.searchAlbums(
        _lastQuery!,
        page: _albumPage,
        limit: 10,
      );
      log(data["results"].toString());

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
      final search = await _saavnRepository.searchAll(_lastQuery!);
      final ids = List<String>.from(search['ids']);

      final songMaps = await _saavnRepository.getSongsByIds(ids);

      final results = songMaps.map((e) => OnlineSongModel.fromJson(e)).toList();

      _songsHasMore = search['has_more'] ?? false;
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
      final data = await _saavnRepository.topSearches();

      if (data is List) {
        final parsed = TrendingItemModel.parseTrendingItems(data);
        emit(JioSaavnTrendingSuccess(parsed));
      } else {
        emit(const JioSaavnTrendingError('Invalid trending data format'));
      }
    } catch (e, stack) {
      log('Trending error: $e\n$stack', name: 'JIOSAAVN_TRENDING');
      emit(JioSaavnTrendingError(e.toString()));
    }
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
}
