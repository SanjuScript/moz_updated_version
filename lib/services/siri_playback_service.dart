import 'dart:async';
import 'dart:developer';

import 'package:moz_updated_version/core/utils/online_playback_repo/audio_playback_repository.dart';
import 'package:moz_updated_version/data/db/favorites/repository/favorite_ab.dart';
import 'package:moz_updated_version/data/firebase/data/repository/favorites_repository.dart';
import 'package:moz_updated_version/data/firebase/data/repository/playlist_repository.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/data/model/song_playlist_model/online_song_playlist.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/data/repository/saavn_repository.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/service_locator.dart';

/// Routes native Siri Intents into the same playback queue used by the UI.
class SiriPlaybackService {
  Future<bool> handleAction(Map<String, dynamic> request) async {
    final action = request['action']?.toString();

    try {
      switch (action) {
        case 'playMusic':
          return await _playMusic();
        case 'playFavorites':
          return await _playFavorites();
        case 'playPlaylist':
          return await _playPlaylist(request['playlistName']?.toString() ?? '');
        case 'playSearch':
          return await _playSearch(request['query']?.toString() ?? '');
        case 'pause':
          await sl<MozAudioHandler>().pause();
          return true;
        case 'next':
          await sl<MozAudioHandler>().skipToNext();
          return true;
        case 'previous':
          await sl<MozAudioHandler>().skipToPrevious();
          return true;
        default:
          log('Unknown Siri action: $action', name: 'SIRI_PLAYBACK');
          return false;
      }
    } catch (error, stackTrace) {
      log(
        'Siri action failed: $action',
        error: error,
        stackTrace: stackTrace,
        name: 'SIRI_PLAYBACK',
      );
      return false;
    }
  }

  Future<bool> _playMusic() async {
    final handler = sl<MozAudioHandler>();
    if (handler.mediaItems.isNotEmpty) {
      return _startPlayback(sl<AudioPlaybackRepository>().play);
    }

    try {
      final result = await sl<SaavnRepository>().searchAll(
        'popular songs',
        limit: 25,
      );
      final ids = (result['ids'] as List? ?? const [])
          .map((id) => id.toString())
          .toList();
      if (ids.isNotEmpty) {
        final songs = await _loadSongsInOrder(ids);
        if (songs.isNotEmpty) {
          return await _playSongs(songs);
        }
      }
    } catch (e) {
      log('Failed to fetch popular songs: $e', name: 'SIRI_PLAYBACK');
    }
    return false;
  }

  Future<bool> _playFavorites() async {
    // 1. Try Firebase Firestore favorites (online user)
    try {
      final uid = sl<UserStorageAbRepo>().userID;
      if (uid != null && uid.isNotEmpty) {
        final ids = await FavoritesRepository.instance
            .favoritesStream()
            .first
            .timeout(const Duration(seconds: 4));
        if (ids.isNotEmpty) {
          final songs = await _loadSongsInOrder(ids.toList());
          if (songs.isNotEmpty) {
            return await _playSongs(songs);
          }
        }
      }
    } catch (e) {
      log('Firestore favorites retrieval failed: $e', name: 'SIRI_PLAYBACK');
    }

    // 2. Fallback to local favorites database
    try {
      final favRepo = sl<FavoriteAbRepo>();
      await favRepo.init();
      final localSongs = favRepo.favoriteItems.value;
      if (localSongs.isNotEmpty) {
        final onlineModels = localSongs
            .map((s) => OnlineSongModel(
                  id: s.id.toString(),
                  song: s.title,
                  singers: s.artist,
                  primaryArtists: s.artist,
                  duration: s.duration?.toString(),
                  mediaUrl: s.uri ?? s.data,
                ))
            .toList();
        return await _playSongs(onlineModels);
      }
    } catch (e) {
      log('Local favorites retrieval failed: $e', name: 'SIRI_PLAYBACK');
    }

    // 3. If no favorites exist yet, fall back to popular music so music always plays
    log('No favorites found; playing popular music', name: 'SIRI_PLAYBACK');
    return await _playMusic();
  }

  Future<bool> _playPlaylist(String requestedName) async {
    final normalizedName = _normalize(requestedName);

    try {
      final repository = OnlinePlaylistRepository.instance;
      await repository.initialize();
      final playlists = await repository
          .playlistsStream()
          .first
          .timeout(const Duration(seconds: 4))
          .catchError((_) => <PlaylistModelOnline>[]);

      PlaylistModelOnline? selectedPlaylist;
      if (normalizedName.isNotEmpty) {
        for (final playlist in playlists) {
          if (_normalize(playlist.name) == normalizedName) {
            selectedPlaylist = playlist;
            break;
          }
        }
        if (selectedPlaylist == null) {
          for (final playlist in playlists) {
            final name = _normalize(playlist.name);
            if (name.contains(normalizedName) || normalizedName.contains(name)) {
              selectedPlaylist = playlist;
              break;
            }
          }
        }
      }

      // If no specific playlist matched, use first playlist if available and query is empty
      if (selectedPlaylist == null && playlists.isNotEmpty && normalizedName.isEmpty) {
        selectedPlaylist = playlists.first;
      }

      if (selectedPlaylist != null) {
        final ids = await repository
            .playlistSongIds(selectedPlaylist.id)
            .first
            .timeout(const Duration(seconds: 4))
            .catchError((_) => <String>[]);
        if (ids.isNotEmpty) {
          final songs = await _loadSongsInOrder(ids);
          if (songs.isNotEmpty) {
            return await _playSongs(songs);
          }
        }
      }
    } catch (e) {
      log('Online playlist error: $e', name: 'SIRI_PLAYBACK');
    }

    // If requested a name but playlist not found, search for that playlist/song name online
    if (requestedName.trim().isNotEmpty) {
      return await _playSearch(requestedName);
    }

    return await _playMusic();
  }

  Future<bool> _playSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return await _playMusic();

    try {
      final repository = sl<SaavnRepository>();
      final result = await repository.searchAll(cleanQuery, limit: 25);
      final ids = (result['ids'] as List? ?? const [])
          .map((id) => id.toString())
          .toList();
      if (ids.isNotEmpty) {
        final songs = await _loadSongsInOrder(ids);
        if (songs.isNotEmpty) {
          return await _playSongs(songs);
        }
      }
    } catch (e) {
      log('Search for "$cleanQuery" failed: $e', name: 'SIRI_PLAYBACK');
    }

    return await _playMusic();
  }

  Future<List<OnlineSongModel>> _loadSongsInOrder(List<String> ids) async {
    if (ids.isEmpty) return [];

    final repository = sl<SaavnRepository>();
    final songsById = <String, OnlineSongModel>{};
    for (var start = 0; start < ids.length; start += 50) {
      final end = (start + 50 < ids.length) ? start + 50 : ids.length;
      final response = await repository.getSongsByIds(ids.sublist(start, end));
      for (final json in response) {
        final song = OnlineSongModel.fromJson(json);
        final id = song.id?.toString();
        if (id != null && id.isNotEmpty) songsById[id] = song;
      }
    }

    return ids.map((id) => songsById[id]).whereType<OnlineSongModel>().toList();
  }

  Future<bool> _playSongs(List<OnlineSongModel> songs) async {
    if (songs.isEmpty) {
      log(
        'No playable songs were returned for the Siri request.',
        name: 'SIRI_PLAYBACK',
      );
      return false;
    }

    return _startPlayback(
      () => sl<AudioPlaybackRepository>().playOnlineSong(songs, startIndex: 0),
    );
  }

  Future<bool> _startPlayback(Future<void> Function() start) async {
    final handler = sl<MozAudioHandler>();
    final playing = handler.isPlaying.firstWhere((isPlaying) => isPlaying);
    final playbackFuture = start().catchError((Object error, StackTrace stack) {
      log(
        'Audio start failed',
        error: error,
        stackTrace: stack,
        name: 'SIRI_PLAYBACK',
      );
    });

    try {
      await playing.timeout(const Duration(seconds: 4));
      unawaited(playbackFuture);
      return true;
    } on TimeoutException {
      // Playback has been queued/initiated
      unawaited(playbackFuture);
      return true;
    }
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
