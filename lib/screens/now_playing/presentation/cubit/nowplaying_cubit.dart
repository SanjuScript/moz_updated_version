import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/main.dart';

part 'nowplaying_state.dart';

class NowPlayingCubit extends Cubit<NowPlayingState> {
  StreamSubscription? _sub;

  NowPlayingCubit() : super(NowPlayingState.initial()) {
    _sub = audioHandler.mediaState$.listen((state) {
      final queue = state.queue;
      final media = state.mediaItem;
      final queueChanged = !_isSameQueue(queue, this.state.queue);
      final currentIndexChanged =
          state.effectiveIndex != this.state.currentIndex;

      emit(
        state.isPlaying != this.state.isPlaying ||
                media?.id != this.state.currentSong?.id ||
                queueChanged ||
                currentIndexChanged
            ? this.state.copyWith(
                queue: queue,
                currentSong: media,
                position: state.position,
                currentIndex: state.effectiveIndex,
                isPlaying: state.isPlaying,
              )
            : this.state,
      );
    });
  }

  bool _isSameQueue(List<MediaItem> left, List<MediaItem> right) {
    if (left.length != right.length) return false;

    for (var i = 0; i < left.length; i++) {
      if (left[i].id != right[i].id) {
        return false;
      }
    }

    return true;
  }

  void playPause() {
    if (state.isPlaying) {
      audioHandler.pause();
    } else {
      audioHandler.play();
    }
  }

  void skipToIndex(int index) {
    audioHandler.skipToEffectiveQueueItem(index);
  }

  void next() => audioHandler.skipToNext();
  void previous() => audioHandler.skipToPrevious();

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
