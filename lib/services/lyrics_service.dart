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

  final Set<String> _fetchingInProgress = {};

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
    if (songId.isEmpty) return;

    if (_lastFetchedSongId == songId) return;
    _lastFetchedSongId = songId;

    if (_lyricsCache.containsKey(songId)) {
      log("Lyrics already cached for song id: $songId");
      return;
    }

    if (_fetchingInProgress.contains(songId)) {
      log("Already fetching lyrics for song id: $songId");
      return;
    }

    _fetchLyricsInBackground(songId, mediaItem.title, mediaItem.artist);
  }

  Future<void> _fetchLyricsInBackground(
    String songId,
    String title,
    String? artist,
  ) async {
    _fetchingInProgress.add(songId);

    try {
      log("Fetching lyrics in background for: $title (ID: $songId)");
      final lyrics = await _lyricsRepository.fetchLyrics(title, artist: artist);

      if (lyrics != null && lyrics.isNotEmpty) {
        _lyricsCache[songId] = lyrics;
        log(
          "BackgroundLyricsService: Successfully cached lyrics for song ID: $songId",
        );
      } else {
        _lyricsCache[songId] = '';
        log(
          "BackgroundLyricsService: No lyrics found for '$title' - cached as empty for song ID: $songId",
        );
      }
    } catch (e) {
      log(
        "BackgroundLyricsService: Error fetching lyrics for song ID $songId - $e",
      );
      _lyricsCache[songId] = '';
    } finally {
      _fetchingInProgress.remove(songId);
    }
  }

  String? getCachedLyrics(String songId) {
    final lyrics = _lyricsCache[songId];
    return (lyrics == null || lyrics.isEmpty) ? null : lyrics;
  }

  bool hasLyrics(String songId) {
    final lyrics = _lyricsCache[songId];
    return lyrics != null && lyrics.isNotEmpty;
  }

  bool hasAttemptedFetch(String songId) => _lyricsCache.containsKey(songId);

  void clearCache() {
    _lyricsCache.clear();
    _fetchingInProgress.clear();
    log("Lyrics cache cleared");
  }

  void dispose() {
    _mediaItemSubscription?.cancel();
    _fetchingInProgress.clear();
    log("BackgroundLyricsService: Stopped listening");
  }

  static Map<String, String> get lyricsCache => _lyricsCache;
}
