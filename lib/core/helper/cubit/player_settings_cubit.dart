import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repo.dart';
import 'package:moz_updated_version/services/service_locator.dart';

part 'player_settings_state.dart';

class PlayerSettingsCubit extends Cubit<PlayerSettingsState> {
  final Box _settingsBox = Hive.box('settingsBox');
  final AudioRepository _repo = sl<AudioRepository>();

  PlayerSettingsCubit() : super(PlayerSettingsState.initial()) {
    _loadSettings();
  }

  void _loadSettings() {
    final shuffle = _settingsBox.get('shuffle', defaultValue: false) as bool;
    final repeat =
        _settingsBox.get('repeatMode', defaultValue: 'none') as String;
    final speed = _settingsBox.get('speed', defaultValue: 1.0) as double;
    final volume = _settingsBox.get('volume', defaultValue: 1.0) as double;

    final repeatMode = RepeatMode.values.firstWhere(
      (e) => e.name == repeat,
      orElse: () => RepeatMode.off,
    );

    _repo.setShuffle(shuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none);
    _repo.setRepeat(_mapRepeatToService(repeatMode));
    _repo.setSpeed(speed);
    _repo.setVolume(volume);

    emit(
      PlayerSettingsState(
        shuffle: shuffle,
        repeatMode: repeatMode,
        speed: speed,
        volume: volume,
      ),
    );
  }

  void toggleShuffle() {
    final newShuffle = !state.shuffle;
    _settingsBox.put('shuffle', newShuffle);

    _repo.setShuffle(newShuffle
        ? AudioServiceShuffleMode.all
        : AudioServiceShuffleMode.none);

    emit(state.copyWith(shuffle: newShuffle));
  }

  void changeRepeatMode() {
    final next = RepeatMode
        .values[(state.repeatMode.index + 1) % RepeatMode.values.length];

    _settingsBox.put('repeatMode', next.name);

    _repo.setRepeat(_mapRepeatToService(next));

    emit(state.copyWith(repeatMode: next));
  }

  void setSpeed(double newSpeed) {
    _settingsBox.put('speed', newSpeed);

    _repo.setSpeed(newSpeed);

    emit(state.copyWith(speed: newSpeed));
  }

  void setVolume(double newVolume) {
    _settingsBox.put('volume', newVolume);

    _repo.setVolume(newVolume);

    emit(state.copyWith(volume: newVolume));
  }

  AudioServiceRepeatMode _mapRepeatToService(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return AudioServiceRepeatMode.none;
      case RepeatMode.one:
        return AudioServiceRepeatMode.one;
      case RepeatMode.all:
        return AudioServiceRepeatMode.all;
    }
  }
}
