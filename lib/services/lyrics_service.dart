import 'dart:async';
import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/core/utils/repository/lyric_repository/lyric_repo.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/service_locator.dart';

enum LyricsFetchState { fetching, success, notFound }

class CachedLyrics {
  final LyricsFetchState state;
  final String? lyrics;

  const CachedLyrics.fetching()
    : state = LyricsFetchState.fetching,
      lyrics = null;

  const CachedLyrics.success(this.lyrics) : state = LyricsFetchState.success;

  const CachedLyrics.notFound()
    : state = LyricsFetchState.notFound,
      lyrics = null;
}

class BackgroundLyricsService {
  final MozAudioHandler _audioHandler = sl<MozAudioHandler>();
  final LyricsRepository _lyricsRepository = sl<LyricsRepository>();

  StreamSubscription<MediaItem?>? _mediaItemSubscription;

  static final Map<String, CachedLyrics> _lyricsCache = {};
  static final StreamController<String> _lyricsUpdateController =
      StreamController<String>.broadcast();

  static Stream<String> get lyricsUpdates => _lyricsUpdateController.stream;

  void startListening() {
    _mediaItemSubscription = _audioHandler.mediaItem
        .distinct((a, b) => a?.id == b?.id)
        .listen((mediaItem) {
          if (mediaItem == null) return;
          _handleSongChange(mediaItem);
        });
  }

  void _handleSongChange(MediaItem mediaItem) {
    final songId = mediaItem.id;
    if (songId.isEmpty) return;

    if (_lyricsCache.containsKey(songId)) return;

    final language =
        mediaItem.extras?['language']?.toString() ?? mediaItem.genre;
    _fetchLyrics(songId, mediaItem.title, mediaItem.artist, language: language);
  }

  Future<void> triggerFetch(
    String songId,
    String title,
    String? artist, {
    String? language,
  }) async {
    if (_lyricsCache.containsKey(songId)) {
      final cached = _lyricsCache[songId]!;
      if (cached.state == LyricsFetchState.fetching ||
          cached.state == LyricsFetchState.success) {
        return; // Already fetching or succeeded
      }
    }
    await _fetchLyrics(songId, title, artist, language: language);
  }

  Future<void> _fetchLyrics(
    String songId,
    String title,
    String? artist, {
    String? language,
  }) async {
    _lyricsCache[songId] = const CachedLyrics.fetching();

    try {
      final lyrics = await _lyricsRepository.fetchLyrics(title, artist: artist);

      if (lyrics != null && lyrics.isNotEmpty) {
        _lyricsCache[songId] = CachedLyrics.success(lyrics);
        log("Lyrics cached for $songId");
      } else {
        _lyricsCache[songId] = const CachedLyrics.notFound();
        log("Lyrics not found for $songId");
      }
    } catch (e) {
      _lyricsCache[songId] = const CachedLyrics.notFound();
      log("Lyrics fetch failed for $songId: $e");
    } finally {
      _lyricsUpdateController.add(songId);
    }
  }

  static CachedLyrics? getLyrics(String songId) {
    return _lyricsCache[songId];
  }

  static void clearCache() {
    _lyricsCache.clear();
  }

  void dispose() {
    _mediaItemSubscription?.cancel();
  }
}
