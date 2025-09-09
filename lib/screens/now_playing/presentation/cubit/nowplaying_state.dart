part of 'nowplaying_cubit.dart';

class NowPlayingState extends Equatable {
  final List<MediaItem> queue;
  final MediaItem? currentSong;
  final int currentIndex;
  final bool isPlaying;
  final bool isShuffled;

  const NowPlayingState({
    required this.queue,
    required this.currentSong,
    required this.currentIndex,
    required this.isPlaying,
    required this.isShuffled,
  });

  factory NowPlayingState.initial() => const NowPlayingState(
    queue: [],
    currentSong: null,
    currentIndex: 0,
    isPlaying: false,
    isShuffled: false,
  );

  NowPlayingState copyWith({
    List<MediaItem>? queue,
    MediaItem? currentSong,
    int? currentIndex,
    bool? isPlaying,
    bool? isShuffled,
  }) {
    return NowPlayingState(
      queue: queue ?? this.queue,
      currentSong: currentSong ?? this.currentSong,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffled: isShuffled ?? this.isShuffled,
    );
  }

  @override
  List<Object?> get props => [queue, currentSong?.id, currentIndex, isPlaying,isShuffled];
}
