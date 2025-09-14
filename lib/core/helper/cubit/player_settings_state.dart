part of 'player_settings_cubit.dart';

enum RepeatMode {
  off,
  one,
  all,
}

class PlayerSettingsState extends Equatable {
  final bool shuffle;
  final RepeatMode repeatMode;
  final double speed; 
  final double volume;
  const PlayerSettingsState({
    required this.shuffle,
    required this.repeatMode,
    required this.speed,
    required this.volume,
  });

  factory PlayerSettingsState.initial() {
    return const PlayerSettingsState(
      shuffle: false,
      repeatMode: RepeatMode.off,
      speed: 1.0,
      volume: 1.0,
    );
  }

  PlayerSettingsState copyWith({
    bool? shuffle,
    RepeatMode? repeatMode,
    double? speed,
    double? volume,
  }) {
    return PlayerSettingsState(
      shuffle: shuffle ?? this.shuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
    );
  }

  @override
  List<Object> get props => [shuffle, repeatMode, speed, volume];
}
