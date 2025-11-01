import 'dart:async';
import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/core/utils/repository/lyric_repository/lyric_repo.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class BackgroundLyricsService {
  final MozAudioHandler _audioHandler = sl<MozAudioHandler>();
  final LyricsRepository _lyricsRepository = sl<LyricsRepository>();

  StreamSubscription? _mediaItemSubscription;
  String? _lastFetchedSongId;

  static final Map<String, String> _lyricsCache = {};

  void startListening() {
    log('BackgroundLyricsService: Started listening for song changes');
    _mediaItemSubscription = _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        _handleSongChange(mediaItem);
      }
    });
  }

  void _handleSongChange(MediaItem mediaItem) {
    final songId = mediaItem.id;

    if (_lastFetchedSongId == songId) return;

    _lastFetchedSongId = songId;

    final artist = mediaItem.artist ?? 'Unknown Artist';
    final title = mediaItem.title;

    final cacheKey = _getCacheKey(artist, title);
    if (_lyricsCache.containsKey(cacheKey)) {
      log('Lyrics already cached for: $title');
      return;
    }

    _fetchLyricsInBackground(artist, title, cacheKey);
  }

  Future<void> _fetchLyricsInBackground(
    String artist,
    String title,
    String cacheKey,
  ) async {
    try {
      log('Fetching lyrics in background for: $title by $artist');

      final lyrics = await _lyricsRepository.fetchLyrics(title);

      if (lyrics != null && lyrics.isNotEmpty) {
        _lyricsCache[cacheKey] = lyrics;
        log('Successfully cached lyrics for: $title');
      } else {
        log('No lyrics found for: $title');
      }
    } catch (e) {
      log('Error fetching lyrics in background: $e');
    }
  }

  String? getCachedLyrics(String artist, String title) {
    final cacheKey = _getCacheKey(artist, title);
    return _lyricsCache[cacheKey];
  }

  bool hasLyrics(String artist, String title) {
    final cacheKey = _getCacheKey(artist, title);
    return _lyricsCache.containsKey(cacheKey);
  }

  String _getCacheKey(String artist, String title) {
    return '${artist.toLowerCase()}_${title.toLowerCase()}';
  }

  void clearCache() {
    _lyricsCache.clear();
    log('Lyrics cache cleared');
  }

  void dispose() {
    _mediaItemSubscription?.cancel();
    log('BackgroundLyricsService: Stopped listening');
  }

  static Map<String, String> get lyricsCache => _lyricsCache;
}
