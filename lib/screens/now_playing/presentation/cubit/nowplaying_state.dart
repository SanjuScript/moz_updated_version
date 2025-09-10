part of 'nowplaying_cubit.dart';

class NowPlayingState extends Equatable {
  final List<MediaItem> queue;
  final MediaItem? currentSong;
  final int currentIndex;
  final bool isPlaying;
  final bool isShuffled;
  final Duration position;

  const NowPlayingState({
    required this.queue,
    required this.currentSong,
    required this.currentIndex,
    required this.isPlaying,
    required this.isShuffled,
    required this.position,
  });

  factory NowPlayingState.initial() => const NowPlayingState(
    queue: [],
    currentSong: null,
    currentIndex: 0,
    isPlaying: false,
    isShuffled: false,
    position: Duration(),
  );

  NowPlayingState copyWith({
    List<MediaItem>? queue,
    MediaItem? currentSong,
    int? currentIndex,
    bool? isPlaying,
    bool? isShuffled,
    Duration? position,
  }) {
    return NowPlayingState(
      queue: queue ?? this.queue,
      currentSong: currentSong ?? this.currentSong,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffled: isShuffled ?? this.isShuffled,
      position: position ?? this.position
    );
  }

  @override
  List<Object?> get props => [
    queue,
    currentSong?.id,
    currentIndex,
    isPlaying,
    isShuffled,
    position
  ];
}
