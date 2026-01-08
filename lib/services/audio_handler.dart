import 'dart:developer';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moz_updated_version/core/extensions/media_item_ext.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/data/db/mostly_played/repository/mostly_played_ab.dart';
import 'package:moz_updated_version/data/db/recently_played/repository/recent_ab_repo.dart';
import 'package:moz_updated_version/data/firebase/data/repository/recently_played_repository.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/services/core/user_service.dart';
import 'package:moz_updated_version/services/helpers/get_artworks.dart';
import 'package:moz_updated_version/services/helpers/get_media_state.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

class MozAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  final List<MediaItem> _mediaItems = [];
  final List<AudioSource> _audioSources = [];
  final recentRepo = sl<RecentAbRepo>();
  final mostlyRepo = sl<MostlyPlayedRepo>();
  final artworkExtractor = sl<ArtworkColorCubit>();
  final _playlist = ConcatenatingAudioSource(children: []);
  final BehaviorSubject<int?> _audioSessionId = BehaviorSubject<int?>.seeded(
    null,
  );

  Stream<int?> get audioSessionIdStream => _audioSessionId.stream;
  int? get audioSessionId => _audioSessionId.value;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<LoopMode> get loopStream => _player.loopModeStream;
  Stream<double> get speedStream => _player.speedStream;
  Stream<double> get volumeStream => _player.volumeStream;
  List<MediaItem> get mediaItems => List.unmodifiable(_mediaItems);
  Stream<bool> get isPlaying => _player.playingStream;
  Duration _lastPosition = Duration.zero;
  Duration _accumulatedDuration = Duration.zero;

  int? get currentSongId {
    final index = _player.currentIndex;
    if (index != null && index < _mediaItems.length) {
      return int.tryParse(_mediaItems[index].id);
    }
    return null;
  }

  bool isInQueue(String mediaItemId) {
    return _mediaItems.any((item) => item.id == mediaItemId);
  }

  bool _countInProgress = false;
  String? _lastCountedSongId;
  final Duration _maxLegitDelta = Duration(seconds: 2);

  MozAudioHandler() {
    _initializeAudioSessionId();
    _player.playbackEventStream.listen((event) async {
      playbackState.add(_transformEvent(event));

      if (_player.playing && event.currentIndex != null) {
        final index = event.currentIndex!;

        if (index < _mediaItems.length) {
          final current = _mediaItems[index];
          mediaItem.add(current);
          // log(current.toString());

          if (_lastCountedSongId != current.id) {
            _flushDuration();
            _lastCountedSongId = current.id;
            _lastPosition = Duration.zero;
            _accumulatedDuration = Duration.zero;
            final isOnline = current.extras?["isOnline"] == true;
            log(
              (current.extras!["isOnline"] == true).toString(),
              name: "ISONLINE",
            );
            log((current.artUri).toString(), name: "ISONLINE");
            artworkExtractor.extractArtworkColors(
              isOnline ? null : int.tryParse(_lastCountedSongId!),
              isOnline: current.extras!["isOnline"] == true,
              networkUrl: current.artUri.toString(),
            );
            log(
              (current.extras!["isOnline"] == true).toString(),
              name: "ISONLINE",
            );
            log((current.artUri).toString(), name: "ISONLINE");
            if (isOnline) {
              await sl<OnlineRecentlyPlayedRepository>().add(current.id);
            }
            if (!isOnline) {
              await mostlyRepo.add(current);
              await recentRepo.add(current);
            }
          }
        }
        if (!_player.playing) {
          await _flushDuration();
        }
      }
    });

    _player.positionStream.listen((pos) {
      if (_lastCountedSongId == null || !_player.playing) {
        _lastPosition = pos;
        return;
      }

      final diff = pos - _lastPosition;

      if (diff > Duration.zero && diff <= _maxLegitDelta) {
        _accumulatedDuration += diff;
      }

      _lastPosition = pos;
    });

    _player.currentIndexStream.listen((index) async {
      if (index != null && index < _mediaItems.length) {
        final current = _mediaItems[index];
        if (_lastCountedSongId == current.id) {
          mediaItem.add(current);
          return;
        }

        if (_countInProgress) return;

        _countInProgress = true;
        final isOnline = current.extras!["isOnline"] == true;
        final isDownloaded = current.extras!["is_downloaded"] == true;

        try {
          await sl<UserService>().incrementSongPlayCount();

          log("ADDED SONG", name: "SONG ADDED****");
          _lastCountedSongId = current.id;
          _lastPosition = Duration.zero;
          _accumulatedDuration = Duration.zero;
          mediaItem.add(current);
        } finally {
          _countInProgress = false;
        }
        if (current.artUri != null) {
          return;
        }
        if (isDownloaded) {
          final artworkPath = current.extras!["artworkPath"];

          if (artworkPath != null && File(artworkPath).existsSync()) {
            final updated = current.copyWith(artUri: Uri.file(artworkPath));

            _mediaItems[index] = updated;
            mediaItem.add(updated);
            return;
          }
        }

        // if (isOnline != null && !isOnline) {
        //   final artUri = await ArtworkHelper.getArtworkUri(
        //     int.parse(current.id),
        //   );

        //   final updated = current.copyWith(artUri: artUri);
        //   _mediaItems[index] = updated;
        //   mediaItem.add(updated);
        // }
      }
    });
  }

  Future<void> _flushDuration() async {
    if (_lastCountedSongId != null && _accumulatedDuration > Duration.zero) {
      await sl<UserService>().addListeningTime(_accumulatedDuration);
      log(
        'Flushed listening time: ${_accumulatedDuration.inSeconds}s',
        name: 'LISTEN_TIME',
      );
      await mostlyRepo.updatePlayedDuration(
        _lastCountedSongId!,
        _accumulatedDuration,
      );
      _accumulatedDuration = Duration.zero;
    }
  }

  Future<void> _initializeAudioSessionId() async {
    try {
      final sessionId = _player.androidAudioSessionId;
      _audioSessionId.add(sessionId);
      log('Audio Session ID initialized: $sessionId');

      _player.androidAudioSessionIdStream.listen((sessionId) {
        _audioSessionId.add(sessionId);
        log('Audio Session ID updated: $sessionId');
      });

      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      log('Error getting audio session ID: $e');
    }
  }

  Future<int?> getAudioSessionId() async {
    try {
      return _player.androidAudioSessionId;
    } catch (e) {
      log('Error getting audio session ID: $e');
      return null;
    }
  }

  Stream<List<MediaItem>> get currentQueue$ {
    return Rx.combineLatest2<List<MediaItem>, List<int?>, List<MediaItem>>(
      queue,
      _player.shuffleIndicesStream,
      (originalQueue, shuffleIndices) {
        if (_player.shuffleModeEnabled && shuffleIndices != null) {
          return shuffleIndices.map((i) => originalQueue[i!]).toList();
        }
        return originalQueue;
      },
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    await _flushDuration();
    await _audioSessionId.close();
    await _player.clearAudioSources();
    await stop();
    return super.onTaskRemoved();
  }

  Stream<List<MediaItem>> get shuffledQueue$ async* {
    yield* _player.shuffleIndicesStream.map((indices) {
      if (indices == null) return _mediaItems;
      return indices.map((i) => _mediaItems[i]).toList();
    });
  }

  Stream<int?> get effectiveIndex$ {
    return Rx.combineLatest2<int?, List<int>?, int?>(
      _player.currentIndexStream,
      _player.shuffleIndicesStream,
      (rawIndex, shuffleIndices) {
        if (rawIndex == null) return null;

        if (_player.shuffleModeEnabled && shuffleIndices != null) {
          return shuffleIndices.indexOf(rawIndex);
        } else {
          return rawIndex;
        }
      },
    );
  }

  Stream<MediaState> get mediaState$ {
    return Rx.combineLatest5<
      MediaItem?,
      Duration,
      bool,
      List<int>?,
      int?,
      MediaState
    >(
      mediaItem,
      _player.positionStream,
      _player.playingStream,
      _player.shuffleIndicesStream,
      effectiveIndex$,
      (item, position, isPlaying, indices, effectiveIndex) {
        final effectiveQueue = (indices == null || !_player.shuffleModeEnabled)
            ? _mediaItems
            : indices.map((i) => _mediaItems[i]).toList();

        return MediaState(
          mediaItem: item,
          queue: effectiveQueue,
          position: position,
          isPlaying: isPlaying,
          effectiveIndex: effectiveIndex ?? 0,
        );
      },
    );
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,

      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      updateTime: DateTime.now(),
      queueIndex: event.currentIndex,
    );
  }

  Future<void> setExternalSource(Uri uri) async {
    try {
      final source = AudioSource.uri(uri);
      await _player.setAudioSource(source);

      final mediaItem = MediaItem(
        id: uri.toString(),
        album: "External Audio",
        title: uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last
            : "Unknown Audio",
        artist: "Shared file",
        extras: {"isExternal": true},
      );

      mediaItem.addToQueue(this);
      mediaItem.setNowPlaying(this);
    } catch (e) {
      debugPrint("Error setting external source: $e");
    }
  }

  Future<void> playSong(String uri, MediaItem item) async {
    mediaItem.add(item);
    await _player.setAudioSource(AudioSource.uri(Uri.parse(uri)));
    log("URI : ${uri.toString()} Media Item : ${item.toString()}");
    await _player.play();
  }

  Future<void> setPlaylist(List<SongModel> songs, {int? index}) async {
    final newMediaItems = songs.toMediaitems();

    if (_isSamePlaylist(newMediaItems)) {
      log('Same playlist, just seeking to index ${index ?? 0}');
      await skipToQueueItem(index ?? 0);
      return;
    }

    _mediaItems.clear();
    _audioSources.clear();
    await _playlist.clear();

    _mediaItems.addAll(newMediaItems);

    _audioSources.addAll(
      songs.map((e) => AudioSource.uri(Uri.parse(e.uri ?? ''))),
    );

    await _playlist.addAll(_audioSources);

    queue.add(_mediaItems);

    await _player.setAudioSource(
      _playlist,
      preload: false,
      initialIndex: index ?? 0,
    );
  }

  Future<void> setOnlinePlaylist(
    List<OnlineSongModel> songs, {
    int? index,
  }) async {
    final newMediaItems = songs.map((e) => e.toMediaItem()).toList();

    if (_isSamePlaylist(newMediaItems)) {
      log('Same online playlist, just seeking to index ${index ?? 0}');
      await skipToQueueItem(index ?? 0);
      return;
    }

    _mediaItems.clear();
    _audioSources.clear();
    await _playlist.clear();

    _mediaItems.addAll(newMediaItems);

    _audioSources.addAll(
      songs.map((e) {
        final uri = e.mediaUrl ?? '';
        final parsed = Uri.parse(uri);
        return (parsed.scheme == 'http' || parsed.scheme == 'https')
            ? AudioSource.uri(parsed)
            : AudioSource.uri(Uri.file(uri));
      }),
    );

    await _playlist.addAll(_audioSources);

    queue.add(_mediaItems);
    mediaItem.add(_mediaItems[index ?? 0]);

    await _player.setAudioSource(
      _playlist,
      preload: false,
      initialIndex: index ?? 0,
    );
  }

  Future<void> playOnlineSong(String uri, MediaItem item) async {
    mediaItem.add(item);
    log(mediaItem.toString(), name: "MEDIA");
    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(item.extras!['mediaUrl']), tag: item),
    );
    log("URI : $uri Media Item : ${item.toString()}");
    await _player.play();
  }

  bool _isSamePlaylist(List<MediaItem> newItems) {
    if (_mediaItems.length != newItems.length) return false;

    for (int i = 0; i < _mediaItems.length; i++) {
      if (_mediaItems[i].id != newItems[i].id) return false;
    }

    return true;
  }

  @override
  Future<void> skipToNext() async {
    final currentIndex = _player.currentIndex;
    if (currentIndex == null) return;

    if (currentIndex + 1 >= _audioSources.length) {
      await _player.seek(Duration.zero, index: 0);
    } else {
      await _player.seekToNext();
    }
    await _player.play();
  }

  @override
  Future<void> skipToPrevious() async {
    final currentIndex = _player.currentIndex;

    if (currentIndex == null) return;
    if (currentIndex == 0) {
      await _player.seek(Duration.zero, index: _audioSources.length - 1);
    } else {
      await _player.seekToPrevious();
    }

    await _player.play();
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    try {
      final exists = _mediaItems.any((item) => item.id == mediaItem.id);
      if (exists) {
        log('Item already in queue: ${mediaItem.title}', name: 'AUDIO_HANDLER');
        return;
      }
      final uri = mediaItem.extras?['uri'];
      if (uri == null || uri.isEmpty) {
        throw Exception('Invalid media URI');
      }

      final audioSource = AudioSource.uri(Uri.parse(uri), tag: mediaItem);

      _mediaItems.add(mediaItem);
      _audioSources.add(audioSource);

      await _playlist.add(audioSource);

      queue.add(List<MediaItem>.from(_mediaItems));

      log('Added item to queue at position ${_mediaItems.length - 1}');
    } catch (e) {
      log('Error adding queue item: $e');
    }
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = _mediaItems.indexWhere((m) => m.id == mediaItem.id);
    if (index == -1) return;

    _mediaItems.removeAt(index);
    _audioSources.removeAt(index);

    await _playlist.removeAt(index);

    queue.add(List<MediaItem>.from(_mediaItems));
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= _mediaItems.length) return;

    _mediaItems.removeAt(index);
    _audioSources.removeAt(index);

    await _playlist.removeAt(index);

    queue.add(List<MediaItem>.from(_mediaItems));
    return super.removeQueueItemAt(index);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    _mediaItems
      ..clear()
      ..addAll(queue);

    _audioSources
      ..clear()
      ..addAll(
        _mediaItems.map(
          (m) => AudioSource.uri(Uri.parse(m.extras?['uri'] ?? "")),
        ),
      );

    queue.addAll(List<MediaItem>.from(_mediaItems));

    await _player.setAudioSources(
      List<AudioSource>.from(_audioSources),
      preload: true,
      initialIndex: _player.currentIndex,
    );
    return super.updateQueue(queue);
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    if (index < 0 || index > _mediaItems.length) return;

    final uri = mediaItem.extras?['uri'] ?? mediaItem.extras?['mediaUrl'];
    final source = AudioSource.uri(Uri.parse(uri ?? ''));

    _mediaItems.insert(index, mediaItem);
    _audioSources.insert(index, source);

    await _playlist.insert(index, source);

    queue.add(List<MediaItem>.from(_mediaItems));

    return super.insertQueueItem(index, mediaItem);
  }

  Future<void> playNext(MediaItem mediaItem) async {
    try {
      final currentIndex = _player.currentIndex ?? 0;
      final targetIndex = currentIndex + 1;

      final existingIndex = _mediaItems.indexWhere(
        (item) => item.id == mediaItem.id,
      );

      if (existingIndex != -1) {
        if (existingIndex == targetIndex) {
          log('Song already set to play next', name: 'PLAY_NEXT');
          return;
        }

        final item = _mediaItems[existingIndex];
        final source = _audioSources[existingIndex];

        _mediaItems.removeAt(existingIndex);
        _audioSources.removeAt(existingIndex);
        await _playlist.removeAt(existingIndex);

        final adjustedIndex = existingIndex < targetIndex
            ? targetIndex - 1
            : targetIndex;

        _mediaItems.insert(adjustedIndex, item);
        _audioSources.insert(adjustedIndex, source);
        await _playlist.insert(adjustedIndex, source);

        queue.add(List<MediaItem>.from(_mediaItems));

        log(
          'Moved song from position $existingIndex to $adjustedIndex',
          name: 'PLAY_NEXT',
        );
      } else {
        await insertQueueItem(targetIndex, mediaItem);
        log(
          'Added new song to play next at position $targetIndex',
          name: 'PLAY_NEXT',
        );
      }
    } catch (e) {
      log('Error in playNext: $e', name: 'PLAY_NEXT');
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (_audioSources.isEmpty) return;
    if (index >= 0 && index < _mediaItems.length) {
      mediaItem.add(_mediaItems[index]);
    }
    await _player.seek(Duration.zero, index: index);
    await _player.play();
    return super.skipToQueueItem(index);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    return super.setSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    switch (shuffleMode) {
      case AudioServiceShuffleMode.none:
        await _player.setShuffleModeEnabled(false);
        break;
      case AudioServiceShuffleMode.all:
        await _player.setShuffleModeEnabled(true);
        break;
      case AudioServiceShuffleMode.group:
        await _player.setShuffleModeEnabled(true);
        break;
    }
    return super.setShuffleMode(shuffleMode);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
        break;
      case AudioServiceRepeatMode.group:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
    return super.setRepeatMode(repeatMode);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);
}
