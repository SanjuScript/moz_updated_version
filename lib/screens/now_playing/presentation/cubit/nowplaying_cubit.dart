import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/services/helpers/get_media_state.dart';
import 'package:moz_updated_version/main.dart';

part 'nowplaying_state.dart';

class NowPlayingCubit extends Cubit<NowPlayingState> {
  StreamSubscription? _sub;

  NowPlayingCubit() : super(NowPlayingState.initial()) {
    _sub = audioHandler.mediaState$.listen((state) {
      final queue = state.queue;
      final media = state.mediaItem;
      final index = media != null
          ? queue.indexWhere((s) => s.id == media.id)
          : -1;

      emit(
        state.isPlaying != this.state.isPlaying ||
                media?.id != this.state.currentSong?.id ||
                queue.length != this.state.queue.length
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


  void playPause() {
    if (state.isPlaying) {
      audioHandler.pause();
    } else {
      audioHandler.play();
    }
  }

  void skipToIndex(int index) {
    audioHandler.skipToQueueItem(index);
  }

  void next() => audioHandler.skipToNext();
  void previous() => audioHandler.skipToPrevious();

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
