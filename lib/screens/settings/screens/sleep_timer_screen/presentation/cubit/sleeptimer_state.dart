part of 'sleeptimer_cubit.dart';

class SleepTimerState extends Equatable {
  final bool isTrackMode;
  final double trackCount;
  final double timerMinutes;
  final int remainingSeconds;
  final int tracksLeft;
  final bool isRunning;

  const SleepTimerState({
    required this.isTrackMode,
    required this.trackCount,
    required this.timerMinutes,
    required this.remainingSeconds,
    required this.tracksLeft,
    required this.isRunning,
  });

  factory SleepTimerState.initial() => const SleepTimerState(
        isTrackMode: true,
        trackCount: 1,
        timerMinutes: 15,
        remainingSeconds: 0,
        tracksLeft: 0,
        isRunning: false,
      );

  SleepTimerState copyWith({
    bool? isTrackMode,
    double? trackCount,
    double? timerMinutes,
    int? remainingSeconds,
    int? tracksLeft,
    bool? isRunning,
  }) {
    return SleepTimerState(
      isTrackMode: isTrackMode ?? this.isTrackMode,
      trackCount: trackCount ?? this.trackCount,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      tracksLeft: tracksLeft ?? this.tracksLeft,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  @override
  List<Object> get props => [isTrackMode, trackCount, timerMinutes, remainingSeconds, tracksLeft, isRunning];
}
