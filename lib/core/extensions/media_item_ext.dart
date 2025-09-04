import 'package:audio_service/audio_service.dart';

extension MediaItemHandler on MediaItem {
  Future<void> addToQueue(BaseAudioHandler handler) async {
    await handler.updateQueue([this]);
  }

  Future<void> setNowPlaying(BaseAudioHandler handler) async {
    handler.mediaItem.add(this);
  }
}
