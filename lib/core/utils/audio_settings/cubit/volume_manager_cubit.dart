import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/services/volume_services.dart';

part 'volume_manager_state.dart';

class VolumeCubit extends Cubit<VolumeState> {
  final VolumeService _volumeService = VolumeService();

  VolumeCubit() : super(VolumeState.initial());

  Future<void> loadVolume() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final maxVol = await _volumeService.getMaxVolume();
      final currVol = await _volumeService.getCurrentVolume();

      emit(
        state.copyWith(
          currentVolume: currVol,
          maxVolume: maxVol,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> setVolume(int volume) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _volumeService.setVolume(volume);
      emit(state.copyWith(currentVolume: volume, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> increase([int amount = 1]) async {
    try {
      await _volumeService.increaseVolume(amount);
      final newVol = _volumeService.currentVolume;
      emit(state.copyWith(currentVolume: newVol));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> decrease([int amount = 1]) async {
    try {
      await _volumeService.decreaseVolume(amount);
      final newVol = _volumeService.currentVolume;
      emit(state.copyWith(currentVolume: newVol));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> setByPercentage(double percent) async {
    try {
      await _volumeService.setVolumeByPercentage(percent);
      final newVol = _volumeService.currentVolume;
      emit(state.copyWith(currentVolume: newVol));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
