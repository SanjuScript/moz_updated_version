import 'dart:async';
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
  StreamSubscription<String>? _lyricsUpdateSub;
  final LyricsRepository repository = sl<LyricsRepository>();
  final localRepo = sl<LyricsDbAb>();
  final audioRepo = sl<AudioRepository>();
  String? _activeSongId;
  List<SongModel> _allSongs = [];

  LyricsCubit() : super(LyricsInitial()) {
    _lyricsUpdateSub = BackgroundLyricsService.lyricsUpdates.listen(
      _onLyricsUpdated,
    );
  }

  void _onLyricsUpdated(String songId) {
    if (songId != _activeSongId) {
      return;
    }
    final cached = BackgroundLyricsService.getLyrics(songId);
    if (cached == null) return;

    if (cached.state == LyricsFetchState.success) {
      emit(LyricsLoaded(cached.lyrics!));
    } else if (cached.state == LyricsFetchState.notFound) {
      emit(const LyricsError("Lyrics not found"));
    }
  }

  void getLyrics(String songId) {
    _activeSongId = songId;
    final cached = BackgroundLyricsService.getLyrics(songId);

    if (cached == null || cached.state == LyricsFetchState.fetching) {
      emit(LyricsLoading());
      return;
    }

    if (cached.state == LyricsFetchState.success) {
      emit(LyricsLoaded(cached.lyrics!));
      return;
    }

    emit(const LyricsError("Lyrics not found"));
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
    // BackgroundLyricsService.lyricsCache.clear();
    log('Lyrics cache cleared');
  }

  void removeLyricsFromCache(String songId) {
    // _lyricsCache.remove(songId);
    BackgroundLyricsService.clearCache();
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

  @override
  Future<void> close() {
    _lyricsUpdateSub?.cancel();
    return super.close();
  }
}
