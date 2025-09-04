import 'package:audio_service/audio_service.dart';

class MediaState {
  final List<MediaItem> queue;
  final MediaItem? mediaItem;
  final Duration position;
  final bool isPlaying;

  MediaState({
    required this.queue,
    required this.mediaItem,
    required this.position,
    required this.isPlaying,
  });
}
