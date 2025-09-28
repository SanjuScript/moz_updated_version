import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moz_updated_version/core/extensions/media_item_ext.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/data/db/mostly_played/repository/mostly_played_ab.dart';
import 'package:moz_updated_version/data/db/recently_played/repository/recent_ab_repo.dart';
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
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<LoopMode> get loopStream => _player.loopModeStream;
  Stream<double> get speedStream => _player.speedStream;
  Stream<double> get volumeStream => _player.volumeStream;
  List<MediaItem> get mediaItems => List.unmodifiable(_mediaItems);
  Stream<bool> get isPlaying => _player.playingStream;

  String? _lastCountedSongId;
  MozAudioHandler() {
    _player.playbackEventStream.listen((event) async {
      playbackState.add(_transformEvent(event));
      if (_player.playing && event.currentIndex != null) {
        final index = event.currentIndex!;
        if (index < _mediaItems.length) {
          final current = _mediaItems[index];
          if (_lastCountedSongId != current.id) {
            _lastCountedSongId = current.id;
            artworkExtractor.extractArtworkColors(
              int.parse(_lastCountedSongId!),
            );
            await mostlyRepo.add(current);
            await recentRepo.add(current);
          }
        }
      }
    });

    _player.currentIndexStream.listen((index) async {
      if (index != null && index < _mediaItems.length) {
        final current = _mediaItems[index];
        if (current.artUri != null) {
          mediaItem.add(current);
          return;
        }

        final artUri = await ArtworkHelper.getArtworkUri(int.parse(current.id));

        final updated = current.copyWith(artUri: artUri);
        _mediaItems[index] = updated;
        mediaItem.add(updated);
      }
    });
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
    _mediaItems.clear();
    _audioSources.clear();
    final mediaItem = songs.toMediaitems();
    _mediaItems.addAll(mediaItem);
    _audioSources.addAll(
      songs.map((e) => AudioSource.uri(Uri.parse(e.uri ?? ''))),
    );

    queue.add(_mediaItems);
    await _player.setAudioSources(
      _audioSources,
      preload: true,
      initialIndex: index,
    );
  }

  // Future<void> _fadeVolume(double from, double to, Duration duration) async {
  //   const steps = 20;
  //   final stepDuration = duration ~/ steps;
  //   final step = (to - from) / steps;

  //   for (var i = 0; i < steps; i++) {
  //     final newVolume = (from + step * i).clamp(0.0, 1.0);
  //     _player.setVolume(newVolume);
  //     await Future.delayed(stepDuration);
  //   }
  //   await _player.setVolume(to);
  // }

  // Future<void> _fadeOut({
  //   Duration duration = const Duration(milliseconds: 700),
  // }) {
  //   return _fadeVolume(_player.volume, 0.0, duration);
  // }

  // Future<void> _fadeIn({
  //   Duration duration = const Duration(milliseconds: 700),
  // }) {
  //   return _fadeVolume(0.0, 1.0, duration);
  // }

  @override
  Future<void> skipToNext() async {
    final currentIndex = _player.currentIndex;
    if (currentIndex == null) return;

    // _fadeOut();

    if (currentIndex + 1 >= _audioSources.length) {
      await _player.seek(Duration.zero, index: 0);
    } else {
      await _player.seekToNext();
    }
    // _fadeIn();
    await _player.play();
  }

  @override
  Future<void> skipToPrevious() async {
    final currentIndex = _player.currentIndex;
    // _fadeOut();
    if (currentIndex == null) return;
    if (currentIndex == 0) {
      await _player.seek(Duration.zero, index: _audioSources.length - 1);
    } else {
      await _player.seekToPrevious();
    }
    // _fadeIn();
    await _player.play();
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    _mediaItems.add(mediaItem);
    _audioSources.add(
      AudioSource.uri(Uri.parse(mediaItem.extras?['uri'] ?? '')),
    );
    queue.add(_mediaItems);
    return super.addQueueItem(mediaItem);
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = _mediaItems.indexWhere((m) => m.id == mediaItem.id);
    if (index == -1) return;

    _mediaItems.removeAt(index);
    _audioSources.removeAt(index);

    queue.add(List<MediaItem>.from(_mediaItems));
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= _mediaItems.length) return;

    _mediaItems.removeAt(index);
    _audioSources.removeAt(index);

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

    final source = AudioSource.uri(Uri.parse(mediaItem.extras?['uri'] ?? ''));

    _mediaItems.insert(index, mediaItem);
    _audioSources.insert(index, source);

    queue.add(List<MediaItem>.from(_mediaItems));

    return super.insertQueueItem(index, mediaItem);
  }

  Future<void> playNext(MediaItem mediaItem) async {
    final currentIndex = _player.currentIndex ?? 0;
    final insertIndex = currentIndex + 1;

    await insertQueueItem(insertIndex, mediaItem);
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
