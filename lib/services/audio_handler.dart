import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MozAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  final List<MediaItem> _mediaItems = [];
  final List<AudioSource> _audioSources = [];

  MozAudioHandler() {
    _player.playbackEventStream.listen((event) {
      playbackState.add(_transformEvent(event));
    });

    _player.currentIndexStream.listen((index) {
      if (index != null && index < _mediaItems.length) {
        mediaItem.add(_mediaItems[index]);
      }
    });
  }

  // Transform playback state into AudioService-compatible format
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
        id: song.uri ?? '',
        title: song.title,
        artist: song.artist ?? 'Unknown Artist',
        album: song.album ?? '',
        duration: Duration(milliseconds: song.duration ?? 0),

        artUri: Uri.parse(
          'content://media/external/audio/albumart/${song.albumId}',
        ),
      );

      _mediaItems.add(mediaItem);
      _audioSources.add(AudioSource.uri(Uri.parse(song.uri ?? '')));
    }

    queue.add(_mediaItems);

    // This is the updated, recommended method
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
