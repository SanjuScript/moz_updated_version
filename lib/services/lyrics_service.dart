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

  static final Map<int, String> _lyricsCache = {};

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

    if (_lastFetchedSongId == mediaItem.id) return;
    _lastFetchedSongId = mediaItem.id;

    if (_lyricsCache.containsKey(songId)) {
      log("Lyrics already cached for song id: $songId");
      return;
    }

    _fetchLyricsInBackground(songId, mediaItem.title, mediaItem.artist);
  }

  Future<void> _fetchLyricsInBackground(
    int songId,
    String title,
    String? artist,
  ) async {
    try {
      log("Fetching lyrics in background for: $title (ID: $songId)");

      final lyrics = await _lyricsRepository.fetchLyrics(title, artist: artist);

      if (lyrics != null && lyrics.isNotEmpty) {
        _lyricsCache[songId] = lyrics;
        log("Cached lyrics for song id: $songId");
      } else {
        log("No lyrics found for: $title");
      }
    } catch (e) {
      log("Error fetching lyrics in background: $e");
    }
  }

  String? getCachedLyrics(int songId) => _lyricsCache[songId];

  bool hasLyrics(int songId) => _lyricsCache.containsKey(songId);

  void clearCache() {
    _lyricsCache.clear();
    log("Lyrics cache cleared");
  }

  void dispose() {
    _mediaItemSubscription?.cancel();
    log("BackgroundLyricsService: Stopped listening");
  }

  static Map<int, String> get lyricsCache => _lyricsCache;
}
