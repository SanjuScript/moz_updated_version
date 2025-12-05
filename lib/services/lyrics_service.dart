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

  // Cache for lyrics - empty string means "no lyrics found"
  static final Map<int, String> _lyricsCache = {};

  // NEW: Track songs that are currently being fetched to avoid duplicate requests
  final Set<int> _fetchingInProgress = {};

  void startListening() {
    log('BackgroundLyricsService: Started listening for song changes');
    _mediaItemSubscription = _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        _handleSongChange(mediaItem);
      }
    });
  }

  void _handleSongChange(MediaItem mediaItem) {
    final songIdString = mediaItem.id;
    if (songIdString.isEmpty) return;

    final songId = int.tryParse(songIdString);
    if (songId == null) {
      log("Invalid mediaItem.id, cannot parse to int: ${mediaItem.id}");
      return;
    }

    // Don't fetch if same song
    if (_lastFetchedSongId == mediaItem.id) return;
    _lastFetchedSongId = mediaItem.id;

    // Don't fetch if already cached (including "no lyrics" state)
    if (_lyricsCache.containsKey(songId)) {
      log("Lyrics already cached for song id: $songId");
      return;
    }

    // NEW: Don't fetch if already fetching
    if (_fetchingInProgress.contains(songId)) {
      log("Already fetching lyrics for song id: $songId");
      return;
    }

    _fetchLyricsInBackground(songId, mediaItem.title, mediaItem.artist);
  }

  Future<void> _fetchLyricsInBackground(
    int songId,
    String title,
    String? artist,
  ) async {
    // NEW: Mark as fetching
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
        // FIXED: Cache empty string to indicate "no lyrics found"
        _lyricsCache[songId] = '';
        log(
          "BackgroundLyricsService: No lyrics found for '$title' - cached as empty for song ID: $songId",
        );
      }
    } catch (e) {
      log(
        "BackgroundLyricsService: Error fetching lyrics for song ID $songId - $e",
      );
      // FIXED: Cache empty string even on error to prevent retry spam
      _lyricsCache[songId] = '';
    } finally {
      // NEW: Remove from fetching set
      _fetchingInProgress.remove(songId);
    }
  }

  // UPDATED: Returns null if no lyrics (empty string cached)
  String? getCachedLyrics(int songId) {
    final lyrics = _lyricsCache[songId];
    return (lyrics == null || lyrics.isEmpty) ? null : lyrics;
  }

  // UPDATED: Check if we've attempted to fetch (even if no lyrics found)
  bool hasLyrics(int songId) {
    final lyrics = _lyricsCache[songId];
    return lyrics != null && lyrics.isNotEmpty;
  }

  // NEW: Check if lyrics were attempted but not found
  bool hasAttemptedFetch(int songId) => _lyricsCache.containsKey(songId);

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

  static Map<int, String> get lyricsCache => _lyricsCache;
}
