import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/core/utils/repository/lyric_repository/lyric_repo.dart';
import 'package:moz_updated_version/services/lyrics_service.dart';
import 'package:moz_updated_version/services/service_locator.dart';

part 'lyrics_state.dart';

class LyricsCubit extends Cubit<LyricsState> {
  final LyricsRepository repository = sl<LyricsRepository>();

  static Map<String, String> get _lyricsCache =>
      BackgroundLyricsService.lyricsCache;

  LyricsCubit() : super(LyricsInitial());

  String _getCacheKey(String artist, String title) {
    return '${artist.toLowerCase()}_${title.toLowerCase()}';
  }

  Future<void> getLyrics(String artist, String title) async {
    final cacheKey = _getCacheKey(artist, title);

    if (_lyricsCache.containsKey(cacheKey)) {
      log('Loading lyrics from cache for: $title');
      emit(LyricsLoaded(_lyricsCache[cacheKey]!));
      return;
    }

    emit(LyricsLoading());
    try {
      final lyrics = await repository.fetchLyrics(title);
      if (lyrics != null && lyrics.isNotEmpty) {
        // Store in cache
        _lyricsCache[cacheKey] = lyrics;
        log('Fetched and cached lyrics for: $title');
        emit(LyricsLoaded(lyrics));
      } else {
        emit(const LyricsError("Lyrics not found"));
      }
    } catch (e) {
      log('Error fetching lyrics: $e');
      emit(LyricsError("Failed to load lyrics: ${e.toString()}"));
    }
  }

  static void clearCache() {
    BackgroundLyricsService.lyricsCache.clear();
    log('Lyrics cache cleared');
  }

  void removeLyricsFromCache(String artist, String title) {
    final cacheKey = _getCacheKey(artist, title);
    _lyricsCache.remove(cacheKey);
    log('Removed lyrics from cache: $title');
  }
}
