import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;
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
import 'package:moz_updated_version/services/helpers/get_media_state.dart';
import 'package:moz_updated_version/services/helpers/get_artworks.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

class MozAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer(maxSkipsOnError: 3);
  final List<MediaItem> _mediaItems = [];
  final List<AudioSource> _audioSources = [];
  final _shuffleOrder = ManagedShuffleOrder();
  final recentRepo = sl<RecentAbRepo>();
  final mostlyRepo = sl<MostlyPlayedRepo>();
  final artworkExtractor = sl<ArtworkColorCubit>();
  late final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(
    children: [],
    shuffleOrder: _shuffleOrder,
  );
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

  void _broadcastQueue() {
    queue.add(List<MediaItem>.from(_mediaItems));
  }

  String? _asNonEmptyString(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String? _resolveMediaPath(MediaItem item) {
    final extras = item.extras ?? const <String, dynamic>{};

    return _asNonEmptyString(extras['uri']) ??
        _asNonEmptyString(extras['mediaUrl']) ??
        _asNonEmptyString(extras['data']) ??
        ((extras['isExternal'] == true) ? _asNonEmptyString(item.id) : null);
  }

  Uri _resolveMediaUri(MediaItem item) {
    final mediaPath = _resolveMediaPath(item);
    if (mediaPath == null) {
      throw Exception('Invalid media URI for "${item.title}"');
    }

    final parsed = Uri.tryParse(mediaPath);
    if (parsed != null && parsed.scheme.isNotEmpty) {
      return parsed;
    }

    return Uri.file(mediaPath);
  }

  AudioSource _buildAudioSource(MediaItem item) {
    return AudioSource.uri(_resolveMediaUri(item), tag: item);
  }

  List<MediaItem> _buildEffectiveQueue(
    List<MediaItem> sourceQueue,
    List<int> effectiveIndices,
  ) {
    if (sourceQueue.isEmpty || effectiveIndices.isEmpty) {
      return List<MediaItem>.from(sourceQueue);
    }

    if (effectiveIndices.length != sourceQueue.length) {
      return List<MediaItem>.from(sourceQueue);
    }

    final reorderedQueue = <MediaItem>[];
    for (final index in effectiveIndices) {
      if (index < 0 || index >= sourceQueue.length) {
        return List<MediaItem>.from(sourceQueue);
      }
      reorderedQueue.add(sourceQueue[index]);
    }

    return reorderedQueue;
  }

  int? _rawIndexForEffectiveIndex(int effectiveIndex) {
    if (effectiveIndex < 0 || effectiveIndex >= _mediaItems.length) {
      return null;
    }

    if (!_player.shuffleModeEnabled) {
      return effectiveIndex;
    }

    final effectiveIndices = _player.effectiveIndices;
    if (effectiveIndex >= effectiveIndices.length) {
      return null;
    }

    return effectiveIndices[effectiveIndex];
  }

  Future<void> _syncShuffleOrder() async {
    if (_player.shuffleModeEnabled && _mediaItems.length > 1) {
      await _player.shuffle();
    }
  }

  List<int> _effectiveIndicesSnapshot() {
    final effectiveIndices = _player.effectiveIndices;
    if (effectiveIndices.isNotEmpty) {
      return List<int>.from(effectiveIndices);
    }

    return List<int>.generate(_mediaItems.length, (index) => index);
  }

  Future<void> _applyExplicitShuffleOrder(List<int> desiredIndices) async {
    if (desiredIndices.length != _mediaItems.length) {
      return;
    }

    final expected = List<int>.generate(_mediaItems.length, (index) => index)
      ..sort();
    final actual = List<int>.from(desiredIndices)..sort();
    if (actual.length != expected.length) {
      return;
    }
    for (var i = 0; i < actual.length; i++) {
      if (actual[i] != expected[i]) {
        return;
      }
    }

    _shuffleOrder.setExplicitOrder(desiredIndices);
    await _player.shuffle();
  }

  int _normalizeIndex(int requestedIndex, int itemCount) {
    if (itemCount <= 0) return 0;
    if (requestedIndex < 0) return 0;
    if (requestedIndex >= itemCount) return itemCount - 1;
    return requestedIndex;
  }

  /// Whether playback was active before an audio interruption (e.g. phone call).
  /// Used to decide whether to auto-resume after the interruption ends.
  bool _wasPlayingBeforeInterruption = false;

  MozAudioHandler() {
    _initializeAudioSessionId();
    _player.playbackEventStream.listen(
      (event) async {
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
                await sl<UserService>().incrementSongPlayCount();
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
      },
      onError: (Object error, StackTrace stackTrace) {
        // Keep stream errors visible instead of letting playback fail silently.
        log('playbackEventStream error: $error', name: 'AUDIO_ERROR');
        log('Stack trace: $stackTrace', name: 'AUDIO_ERROR');
      },
    );

    // Keep queue playback recoverable when the player reaches the end.
    _player.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        log('ProcessingState.completed detected', name: 'PLAYBACK');
        await _flushDuration();

        if (_player.loopMode == LoopMode.one) {
          await _player.seek(Duration.zero);
          await _player.play();
        } else if (_player.hasNext) {
          log('Auto-advancing to next track', name: 'PLAYBACK');
          await skipToNext();
        } else if (_mediaItems.length > 1 && _player.loopMode == LoopMode.all) {
          log('Looping back to first track', name: 'PLAYBACK');
          final firstIndex = _player.effectiveIndices.isNotEmpty
              ? _player.effectiveIndices.first
              : 0;
          await _player.seek(Duration.zero, index: firstIndex);
          await _player.play();
        } else {
          log('Playlist completed, seeking to start', name: 'PLAYBACK');
          final firstIndex = _player.effectiveIndices.isNotEmpty
              ? _player.effectiveIndices.first
              : 0;
          await _player.seek(Duration.zero, index: firstIndex);
        }
      }
    });

    _player.errorStream.listen((error) {
      log(
        'Playback source failed: code=${error.code}, message=${error.message}, index=${error.index}',
        name: 'AUDIO_ERROR',
      );
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

        if (current.artUri == null) {
          final isDownloaded = current.extras?["is_downloaded"] == true;
          final isOnline = current.extras?["isOnline"] == true;

          if (isDownloaded) {
            final artworkPath = current.extras?["artworkPath"];
            if (artworkPath != null && File(artworkPath).existsSync()) {
              final updated = current.copyWith(artUri: Uri.file(artworkPath));
              _mediaItems[index] = updated;
              _broadcastQueue();
              mediaItem.add(updated);
            }
          } else if (!isOnline) {
            final songId = int.tryParse(current.id);
            if (songId != null) {
              final artUri = await ArtworkHelper.getArtworkUri(songId);
              if (artUri != null) {
                final updated = current.copyWith(artUri: artUri);
                _mediaItems[index] = updated;
                _broadcastQueue();
                mediaItem.add(updated);
              }
            }
          }
        }

        final updatedCurrent = _mediaItems[index];
        if (_lastCountedSongId == updatedCurrent.id) {
          mediaItem.add(updatedCurrent);
          return;
        }

        if (_countInProgress) {
          log("Execution stopped");
          return;
        }

        _countInProgress = true;
        try {
          log("ADDED SONG", name: "SONG ADDED****");
          _lastCountedSongId = updatedCurrent.id;
          _lastPosition = Duration.zero;
          _accumulatedDuration = Duration.zero;
          mediaItem.add(updatedCurrent);
        } finally {
          _countInProgress = false;
        }
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

      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(0.3);
              log('Audio ducking: volume lowered', name: 'AUDIO_FOCUS');
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              _wasPlayingBeforeInterruption = _player.playing;
              if (_wasPlayingBeforeInterruption) {
                _player.pause();
                log(
                  'Audio paused due to interruption: ${event.type}',
                  name: 'AUDIO_FOCUS',
                );
              }
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(1.0);
              log('Audio unducking: volume restored', name: 'AUDIO_FOCUS');
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              if (_wasPlayingBeforeInterruption) {
                _player.play();
                log('Audio resumed after interruption', name: 'AUDIO_FOCUS');
              }
              break;
          }
        }
      });

      session.becomingNoisyEventStream.listen((_) {
        log('Headphones disconnected: pausing', name: 'AUDIO_FOCUS');
        _player.pause();
      });
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
    return Rx.combineLatest2<List<MediaItem>, SequenceState, List<MediaItem>>(
      queue,
      _player.sequenceStateStream,
      (originalQueue, sequenceState) {
        if (!sequenceState.shuffleModeEnabled) {
          return List<MediaItem>.from(originalQueue);
        }

        return _buildEffectiveQueue(
          originalQueue,
          sequenceState.shuffleIndices,
        );
      },
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    await _flushDuration();

    // Some OEM skins fire this when the recents task is removed even though the
    // media service should keep playing.
    if (!_player.playing) {
      log('Not playing: stopping service on task removed', name: 'LIFECYCLE');
      await stop();
    } else {
      log('Still playing: keeping foreground service alive', name: 'LIFECYCLE');
    }
    return super.onTaskRemoved();
  }

  Stream<List<MediaItem>> get shuffledQueue$ async* {
    yield* _player.shuffleIndicesStream.map((indices) {
      return _buildEffectiveQueue(_mediaItems, indices);
    });
  }

  Stream<int?> get effectiveIndex$ {
    return Rx.combineLatest2<int?, SequenceState, int?>(
      _player.currentIndexStream,
      _player.sequenceStateStream,
      (rawIndex, sequenceState) {
        if (rawIndex == null) return null;

        if (!sequenceState.shuffleModeEnabled) {
          return rawIndex;
        }

        final effectiveIndex = sequenceState.shuffleIndices.indexOf(rawIndex);
        return effectiveIndex == -1 ? rawIndex : effectiveIndex;
      },
    );
  }

  Stream<MediaState> get mediaState$ {
    return Rx.combineLatest5<
          MediaItem?,
          Duration,
          bool,
          List<MediaItem>,
          int?,
          MediaState
        >(
          mediaItem,
          _player.positionStream,
          _player.playingStream,
          currentQueue$,
          effectiveIndex$,
          (item, position, isPlaying, effectiveQueue, effectiveIndex) {
            return MediaState(
              mediaItem: item,
              queue: List<MediaItem>.from(effectiveQueue),
              position: position,
              isPlaying: isPlaying,
              effectiveIndex: effectiveIndex ?? 0,
            );
          },
        )
        .asyncMap((state) => Future.value(state));
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
      
      _mediaItems.clear();
      _audioSources.clear();
      await _playlist.clear();

      final externalItem = MediaItem(
        id: uri.toString(),
        album: "External Audio",
        title: uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last
            : "Unknown Audio",
        artist: "Shared file",
        extras: {"isExternal": true},
      );

      _mediaItems.add(externalItem);
      _audioSources.add(source);
      await _playlist.add(source);
      
      _broadcastQueue();
      await _player.setAudioSource(
        _playlist,
        preload: true,
        initialIndex: 0,
      );
    } catch (e) {
      debugPrint("Error setting external source: $e");
    }
  }

  Future<void> playSong(String uri, MediaItem item) async {
    mediaItem.add(item);
    
    final index = _mediaItems.indexWhere((m) => m.id == item.id);
    if (index != -1) {
      await skipToQueueItem(index);
    } else {
      _mediaItems.clear();
      _audioSources.clear();
      await _playlist.clear();

      final source = _buildAudioSource(item);
      _mediaItems.add(item);
      _audioSources.add(source);
      await _playlist.add(source);
      
      _broadcastQueue();
      await _player.setAudioSource(
        _playlist,
        preload: true,
        initialIndex: 0,
      );
      await _player.play();
    }
  }

  Future<void> setPlaylist(List<SongModel> songs, {int? index}) async {
    final newMediaItems = songs.toMediaitems();

    if (newMediaItems.isEmpty) {
      _mediaItems.clear();
      _audioSources.clear();
      await _playlist.clear();
      _broadcastQueue();
      return;
    }

    final targetIndex = _normalizeIndex(index ?? 0, newMediaItems.length);

    if (_isSamePlaylist(newMediaItems)) {
      log('Same playlist, just seeking to index $targetIndex');
      await skipToQueueItem(targetIndex);
      return;
    }

    _mediaItems.clear();
    _audioSources.clear();
    await _playlist.clear();

    _mediaItems.addAll(newMediaItems);
    _audioSources.addAll(_mediaItems.map(_buildAudioSource));

    await _playlist.addAll(_audioSources);

    _broadcastQueue();

    await _player.setAudioSource(
      _playlist,
      preload: true,
      initialIndex: targetIndex,
    );
    await _syncShuffleOrder();
  }

  Future<void> setOnlinePlaylist(
    List<OnlineSongModel> songs, {
    int? index,
  }) async {
    final newMediaItems = songs.map((e) => e.toMediaItem()).toList();

    if (newMediaItems.isEmpty) {
      _mediaItems.clear();
      _audioSources.clear();
      await _playlist.clear();
      _broadcastQueue();
      return;
    }

    final targetIndex = _normalizeIndex(index ?? 0, newMediaItems.length);

    if (_isSamePlaylist(newMediaItems)) {
      log('Same online playlist, just seeking to index $targetIndex');
      await skipToQueueItem(targetIndex);
      return;
    }

    _mediaItems.clear();
    _audioSources.clear();
    await _playlist.clear();

    _mediaItems.addAll(newMediaItems);
    _audioSources.addAll(_mediaItems.map(_buildAudioSource));

    await _playlist.addAll(_audioSources);

    _broadcastQueue();
    mediaItem.add(_mediaItems[targetIndex]);

    await _player.setAudioSource(
      _playlist,
      preload: true,
      initialIndex: targetIndex,
    );
    await _syncShuffleOrder();
  }

  Future<void> playOnlineSong(String uri, MediaItem item) async {
    mediaItem.add(item);
    log(mediaItem.toString(), name: "MEDIA");
    
    final index = _mediaItems.indexWhere((m) => m.id == item.id);
    if (index != -1) {
      await skipToQueueItem(index);
    } else {
      _mediaItems.clear();
      _audioSources.clear();
      await _playlist.clear();

      final source = _buildAudioSource(item);
      _mediaItems.add(item);
      _audioSources.add(source);
      await _playlist.add(source);
      
      _broadcastQueue();
      await _player.setAudioSource(
        _playlist,
        preload: true,
        initialIndex: 0,
      );
      await _player.play();
    }
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
    if (_audioSources.isEmpty) return;

    if (_player.hasNext) {
      await _player.seekToNext();
    } else {
      final firstIndex = _player.effectiveIndices.isNotEmpty
          ? _player.effectiveIndices.first
          : 0;
      await _player.seek(Duration.zero, index: firstIndex);
    }
    await _player.play();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_audioSources.isEmpty) return;

    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      final effectiveIndices = _player.effectiveIndices;
      final lastIndex = effectiveIndices.isNotEmpty
          ? effectiveIndices.last
          : _audioSources.length - 1;
      await _player.seek(Duration.zero, index: lastIndex);
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
      final audioSource = _buildAudioSource(mediaItem);

      _mediaItems.add(mediaItem);
      _audioSources.add(audioSource);

      await _playlist.add(audioSource);

      _broadcastQueue();

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

    _broadcastQueue();
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= _mediaItems.length) return;

    _mediaItems.removeAt(index);
    _audioSources.removeAt(index);

    await _playlist.removeAt(index);

    _broadcastQueue();
    return super.removeQueueItemAt(index);
  }

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _mediaItems.length) return;
    if (newIndex < 0 || newIndex >= _mediaItems.length) return;
    if (oldIndex == newIndex) return;

    if (_player.shuffleModeEnabled) {
      final effectiveIndices = _effectiveIndicesSnapshot();
      if (oldIndex >= effectiveIndices.length || newIndex >= effectiveIndices.length) return;
      
      final itemIndex = effectiveIndices.removeAt(oldIndex);
      effectiveIndices.insert(newIndex, itemIndex);
      
      await _applyExplicitShuffleOrder(effectiveIndices);
      return;
    }

    final item = _mediaItems.removeAt(oldIndex);
    final source = _audioSources.removeAt(oldIndex);
    
    _mediaItems.insert(newIndex, item);
    _audioSources.insert(newIndex, source);
    
    await _playlist.move(oldIndex, newIndex);
    
    _broadcastQueue();
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    _mediaItems
      ..clear()
      ..addAll(queue);

    _audioSources
      ..clear()
      ..addAll(_mediaItems.map(_buildAudioSource));

    await _playlist.clear();
    await _playlist.addAll(_audioSources);

    _broadcastQueue();

    if (_audioSources.isNotEmpty) {
      final safeIndex = _normalizeIndex(
        _player.currentIndex ?? 0,
        _audioSources.length,
      );

      await _player.setAudioSource(
        _playlist,
        preload: true,
        initialIndex: safeIndex,
      );
      await _syncShuffleOrder();
    }

    return super.updateQueue(queue);
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    if (index < 0 || index > _mediaItems.length) return;

    final source = _buildAudioSource(mediaItem);

    _mediaItems.insert(index, mediaItem);
    _audioSources.insert(index, source);

    await _playlist.insert(index, source);

    _broadcastQueue();

    return super.insertQueueItem(index, mediaItem);
  }

  Future<void> playNext(MediaItem mediaItem) async {
    try {
      final currentIndex = _player.currentIndex ?? 0;
      var existingIndex = _mediaItems.indexWhere(
        (item) => item.id == mediaItem.id,
      );

      if (_player.shuffleModeEnabled) {
        if (existingIndex == -1) {
          final source = _buildAudioSource(mediaItem);
          _mediaItems.add(mediaItem);
          _audioSources.add(source);
          await _playlist.add(source);
          existingIndex = _mediaItems.length - 1;
          _broadcastQueue();
          log(
            'Added new song to shuffled play-next after current track',
            name: 'PLAY_NEXT',
          );
        } else {
          log(
            'Reordered existing queued song to play next in shuffle mode',
            name: 'PLAY_NEXT',
          );
        }

        final effectiveIndices = _effectiveIndicesSnapshot();
        effectiveIndices.remove(existingIndex);

        final currentEffectiveIndex = effectiveIndices.indexOf(currentIndex);
        var insertAt = currentEffectiveIndex != -1 ? currentEffectiveIndex + 1 : 0;
        effectiveIndices.insert(insertAt, existingIndex);

        await _applyExplicitShuffleOrder(effectiveIndices);
        return;
      }

      final targetIndex = currentIndex + 1;

      if (existingIndex != -1) {
        if (existingIndex == targetIndex) {
          log('Song already set to play next', name: 'PLAY_NEXT');
          return;
        }

        final adjustedIndex = existingIndex < targetIndex
            ? targetIndex - 1
            : targetIndex;

        final item = _mediaItems.removeAt(existingIndex);
        final source = _audioSources.removeAt(existingIndex);
        _mediaItems.insert(adjustedIndex, item);
        _audioSources.insert(adjustedIndex, source);
        
        await _playlist.move(existingIndex, adjustedIndex);

        _broadcastQueue();

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
    if (index < 0 || index >= _mediaItems.length) return;

    mediaItem.add(_mediaItems[index]);
    await _player.seek(Duration.zero, index: index);
    await _player.play();
    return super.skipToQueueItem(index);
  }

  Future<void> skipToEffectiveQueueItem(int effectiveIndex) async {
    final rawIndex = _rawIndexForEffectiveIndex(effectiveIndex);
    if (rawIndex == null) return;

    await skipToQueueItem(rawIndex);
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
        await _player.shuffle();
        await _player.setShuffleModeEnabled(true);
        break;
      case AudioServiceShuffleMode.group:
        await _player.shuffle();
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
  Future<void> play() async {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }

    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _flushDuration();
    await _player.stop();
  }

  @override
  Future<void> onNotificationDeleted() async {
    await _flushDuration();
    if (!_player.playing) {
      await stop();
    }
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);
}

class ManagedShuffleOrder extends ShuffleOrder {
  ManagedShuffleOrder({Random? random}) : _random = random ?? Random();

  final Random _random;

  @override
  final List<int> indices = <int>[];

  List<int>? _explicitOrder;

  void setExplicitOrder(List<int> order) {
    _explicitOrder = List<int>.from(order);
  }

  @override
  void shuffle({int? initialIndex}) {
    final explicitOrder = _explicitOrder;
    if (explicitOrder != null) {
      indices
        ..clear()
        ..addAll(explicitOrder);
      _explicitOrder = null;
      return;
    }

    if (indices.length <= 1) return;
    indices.shuffle(_random);
    if (initialIndex == null) return;

    final swapPos = indices.indexOf(initialIndex);
    if (swapPos <= 0) return;

    final firstIndex = indices.first;
    indices[0] = initialIndex;
    indices[swapPos] = firstIndex;
  }

  @override
  void insert(int index, int count) {
    for (var i = 0; i < indices.length; i++) {
      if (indices[i] >= index) {
        indices[i] += count;
      }
    }

    final newIndices = List<int>.generate(count, (offset) => index + offset);
    for (final newIndex in newIndices) {
      final insertionIndex = _random.nextInt(indices.length + 1);
      indices.insert(insertionIndex, newIndex);
    }
  }

  @override
  void removeRange(int start, int end) {
    final count = end - start;
    final removed = List<int>.generate(
      count,
      (offset) => start + offset,
    ).toSet();
    indices.removeWhere(removed.contains);

    for (var i = 0; i < indices.length; i++) {
      if (indices[i] >= end) {
        indices[i] -= count;
      }
    }
  }

  @override
  void clear() {
    indices.clear();
  }
}
