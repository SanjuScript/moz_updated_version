import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repo.dart';
import 'package:moz_updated_version/core/utils/repository/lyric_repository/lyric_repo.dart';
import 'package:moz_updated_version/data/db/lyrics_db/lyrics_db_ab.dart';
import 'package:moz_updated_version/data/model/lyric_model.dart';
import 'package:moz_updated_version/services/lyrics_service.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'lyrics_state.dart';

class LyricsCubit extends Cubit<LyricsState> {
  final LyricsRepository repository = sl<LyricsRepository>();
  final localRepo = sl<LyricsDbAb>();
  final audioRepo = sl<AudioRepository>();

  List<SongModel> _allSongs = [];

  static Map<String, String> get _lyricsCache =>
      BackgroundLyricsService.lyricsCache;

  LyricsCubit() : super(LyricsInitial());

  Future<void> getLyrics(String songId, String title, {String? artist}) async {
    final intId = int.tryParse(songId);
    if (intId != null) {
      final localLyrics = await localRepo.getLyrics(intId);
      if (localLyrics != null && localLyrics.isNotEmpty) {
        emit(LyricsLoaded(localLyrics));
        return;
      }
    }

    if (_lyricsCache.containsKey(songId)) {
      final cachedLyrics = _lyricsCache[songId];
      if (cachedLyrics != null && cachedLyrics.isNotEmpty) {
        log('Loading lyrics from cache for: $title');
        emit(LyricsLoaded(cachedLyrics));
        return;
      }
    }

    emit(LyricsLoading());
    try {
      final lyrics = await repository.fetchLyrics(title, artist: artist);
      if (lyrics != null && lyrics.isNotEmpty) {
        _lyricsCache[songId] = lyrics;
        log('Fetched and cached lyrics for: $title (ID: $songId)');
        emit(LyricsLoaded(lyrics));
      } else {
        _lyricsCache[songId] = '';
        emit(const LyricsError("Lyrics not found"));
      }
    } catch (e) {
      log('Error fetching lyrics: $e');
      _lyricsCache[songId] = '';
      emit(LyricsError("Failed to load lyrics: ${e.toString()}"));
    }
  }

  void setSongs(List<SongModel> songs) {
    _allSongs = songs;
  }

  Future<List<SavedLyricItem>> loadSavedLyrics() async {
    try {
      await localRepo.init();
      final cachedLyrics = localRepo.cachedLyrics.value;

      final List<SavedLyricItem> savedItems = [];

      for (final entry in cachedLyrics.entries) {
        final songId = entry.key;
        final lyrics = entry.value;
        final song = _getSongById(songId);

        if (song != null) {
          savedItems.add(
            SavedLyricItem(
              songId: songId,
              title: song.title,
              artist: song.artist ?? 'Unknown Artist',
              lyrics: lyrics,
            ),
          );
        }
      }

      return savedItems;
    } catch (e) {
      log('Error loading saved lyrics: $e');
      return [];
    }
  }

  List<SavedLyricItem> filterSavedLyrics(
    List<SavedLyricItem> items,
    String query,
  ) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.title.toLowerCase().contains(lowerQuery) ||
          item.artist.toLowerCase().contains(lowerQuery) ||
          item.lyrics.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<String?> transliterateLyrics(String lyrics, String sourceLang) async {
    try {
      final transliterated = await repository.transliterate(
        lyrics,
        sourceLang: sourceLang,
      );
      return transliterated;
    } catch (e) {
      log("Error transliterating lyrics: $e");
      return null;
    }
  }

  Future<void> saveCurrentLyrics(String songId, String lyrics) async {
    final intId = int.tryParse(songId);
    if (intId != null) {
      await localRepo.saveLyrics(intId, lyrics);
      log('Saved lyrics for offline song ID: $intId');
    } else {
      log(
        'Cannot save lyrics for online song with ID: $songId (not an integer)',
      );
    }
  }

  Future<void> deleteLyrics(String songId) async {
    final intId = int.tryParse(songId);
    if (intId != null) {
      await localRepo.deleteLyrics(intId);
      removeLyricsFromCache(songId);
      log('Deleted lyrics for offline song ID: $intId');
    } else {
      removeLyricsFromCache(songId);
      log('Removed online song from cache: $songId');
    }
  }

  static void clearCache() {
    BackgroundLyricsService.lyricsCache.clear();
    log('Lyrics cache cleared');
  }

  void removeLyricsFromCache(String songId) {
    _lyricsCache.remove(songId);
    log('Removed lyrics from cache: $songId');
  }

  SongModel? _getSongById(int songId) {
    try {
      return _allSongs.firstWhere((song) => song.id == songId);
    } catch (_) {
      log('Song not found for ID: $songId');
      return null;
    }
  }
}
