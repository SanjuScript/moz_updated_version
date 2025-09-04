import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moz_updated_version/core/extensions/media_item_ext.dart';
import 'package:moz_updated_version/services/helpers/get_artworks.dart';
import 'package:moz_updated_version/services/helpers/get_media_state.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

class MozAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  final List<MediaItem> _mediaItems = [];
  final List<AudioSource> _audioSources = [];

  MozAudioHandler() {
    _player.playbackEventStream.listen((event) {
      playbackState.add(_transformEvent(event));
    });

    _player.currentIndexStream.listen((index) async {
      if (index != null && index < _mediaItems.length) {
        final current = _mediaItems[index];

        if (current.artUri != null) {
          mediaItem.add(current);
          return;
        }

        final artUri = await ArtworkHelper.getArtworkUri(int.parse(current.id));

        if (artUri != null) {
          final updated = current.copyWith(artUri: artUri);
          _mediaItems[index] = updated;
          mediaItem.add(updated);
        } else {
          mediaItem.add(current);
        }
      }
    });
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    return super.onTaskRemoved();
  }


Stream<MediaState> get mediaState$ {
  return Rx.combineLatest3<MediaItem?, Duration, bool, MediaState>(
    mediaItem,
    _player.positionStream,
    _player.playingStream,
    (item, position, isPlaying) {
      return MediaState(
        mediaItem: item,
        queue: _mediaItems,
        position: position,
        isPlaying: isPlaying,
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
    await _player.play();
  }

  Future<void> setPlaylist(List<SongModel> songs) async {
    _mediaItems.clear();
    _audioSources.clear();

    for (var song in songs) {
      final mediaItem = MediaItem(
        id: song.id.toString() ?? '',
        title: song.title,
        artist: song.artist ?? 'Unknown Artist',
        album: song.album ?? '',
        duration: Duration(milliseconds: song.duration ?? 0),
      );
      // log(song.uri.toString());

      _mediaItems.add(mediaItem);
      _audioSources.add(AudioSource.uri(Uri.parse(song.uri ?? '')));
    }

    queue.add(_mediaItems);

    await _player.setAudioSources(_audioSources, preload: true);
  }

  Future<void> playFromIndex(int index) async {
    if (_audioSources.isEmpty) return;
    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);
}
