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

  static Map<int, String> get _lyricsCache =>
      BackgroundLyricsService.lyricsCache;

  LyricsCubit() : super(LyricsInitial());

  Future<void> getLyrics(int id, String title) async {
    final cacheKey = localRepo.getKey(id);

    final localLyrics = await localRepo.getLyrics(id);
    if (localLyrics != null && localLyrics.isNotEmpty) {
      emit(LyricsLoaded(localLyrics));
      return;
    }

    if (_lyricsCache.containsKey(cacheKey)) {
      log('Loading lyrics from cache for: $title');
      emit(LyricsLoaded(_lyricsCache[cacheKey]!));
      return;
    }

    emit(LyricsLoading());
    try {
      final lyrics = await repository.fetchLyrics(title);
      if (lyrics != null && lyrics.isNotEmpty) {
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

  void setSongs(List<SongModel> songs) {
    _allSongs = songs;
  }

  // Load all saved lyrics with song metadata
  Future<List<SavedLyricItem>> loadSavedLyrics() async {
    try {
      await localRepo.init(); // Ensure initialized
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

  // Filter saved lyrics by search query
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

  Future<void> saveCurrentLyrics(int id, String lyrics) async {
    await localRepo.saveLyrics(id, lyrics);
  }

  Future<void> deleteLyrics(int id) async {
    await localRepo.deleteLyrics(id);
    removeLyricsFromCache(id);
  }

  static void clearCache() {
    BackgroundLyricsService.lyricsCache.clear();
    log('Lyrics cache cleared');
  }

  void removeLyricsFromCache(id) {
    final cacheKey = localRepo.getKey(id);
    _lyricsCache.remove(cacheKey);
    log('Removed lyrics from cache: $id');
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
