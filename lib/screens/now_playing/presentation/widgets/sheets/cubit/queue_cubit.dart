import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/main.dart';

class QueueCubit extends Cubit<List<MediaItem>> {
  QueueCubit() : super([]) {
    _listenToQueue();
  }

  void _listenToQueue() {
    audioHandler.currentQueue$.listen((queue) {
      emit(List<MediaItem>.from(queue));
    });
  }

  Future<void> removeFromQueue(MediaItem mediaItem) async {
    await audioHandler.removeQueueItem(mediaItem);
  }

  Future<void> skipToIndex(int index) async {
    await audioHandler.skipToEffectiveQueueItem(index);
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    await audioHandler.moveQueueItem(oldIndex, newIndex);
  }
}
