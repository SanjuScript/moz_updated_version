import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/model/equalizer_data.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/equillizer_service.dart';

import '../../../../../services/core/app_services.dart';

part 'equalizer_state.dart';

class EqualizerCubit extends Cubit<EqualizerState> {
  final _service = sl<EqualizerService>();
  StreamSubscription<int?>? _sessionSub;
  int? _lastSessionId;

  EqualizerCubit() : super(EqualizerInitial()) {
    _sessionSub = sl<MozAudioHandler>().audioSessionIdStream.listen((id) {
      if (id != null && id != 0 && id != _lastSessionId) {
        _lastSessionId = id;
        initialize(id);
      }
    });
  }

  Future<void> initialize(int audioSessionId) async {
    emit(EqualizerLoading());

    try {
      final success = await _service.initialize(audioSessionId);
      if (!success) {
        emit(const EqualizerError('Failed to initialize equalizer'));
        return;
      }

      final numBands = await _service.getNumberOfBands();
      final range = await _service.getBandLevelRange();
      final presets = await _service.getPresets();

      final bands = <BandData>[];
      for (int i = 0; i < numBands; i++) {
        final freq = await _service.getCenterFreq(i);
        final level = await _service.getBandLevel(i);
        bands.add(
          BandData(
            index: i,
            centerFreq: freq,
            level: level,
            minLevel: range[0],
            maxLevel: range[1],
          ),
        );
      }

      emit(
        EqualizerLoaded(
          data: EqualizerData(bands: bands),
          presets: presets,
        ),
      );
    } catch (e) {
      emit(EqualizerError('Error initializing equalizer: $e'));
    }
  }

  Future<void> toggleEqualizer(bool value) async {
    if (state is! EqualizerLoaded) return;

    final currentState = state as EqualizerLoaded;
    await _service.setEnabled(value);

    emit(
      currentState.copyWith(data: currentState.data.copyWith(enabled: value)),
    );
  }

  Future<void> setBandLevel(int band, double value) async {
    if (state is! EqualizerLoaded) return;

    final currentState = state as EqualizerLoaded;
    await _service.setBandLevel(band, value.round());

    final updatedBands = List<BandData>.from(currentState.data.bands);
    updatedBands[band] = updatedBands[band].copyWith(level: value.round());

    emit(
      currentState.copyWith(
        data: currentState.data.copyWith(
          bands: updatedBands,
          currentPreset: null,
        ),
      ),
    );
  }

  Future<void> applyPreset(int index) async {
    if (state is! EqualizerLoaded) return;

    final currentState = state as EqualizerLoaded;
    await _service.usePreset(index);

    // Refresh band levels after preset
    final updatedBands = <BandData>[];
    for (var band in currentState.data.bands) {
      final level = await _service.getBandLevel(band.index);
      updatedBands.add(band.copyWith(level: level));
    }

    emit(
      currentState.copyWith(
        data: currentState.data.copyWith(
          bands: updatedBands,
          currentPreset: index,
        ),
      ),
    );
  }

  Future<void> setBassBoost(double value) async {
    if (state is! EqualizerLoaded) return;

    final currentState = state as EqualizerLoaded;
    await _service.setBassBoost(value.round());

    emit(
      currentState.copyWith(
        data: currentState.data.copyWith(
          bassBoost: currentState.data.bassBoost.copyWith(
            strength: value.round(),
          ),
        ),
      ),
    );
  }

  Future<void> toggleBassBoost(bool value) async {
    if (state is! EqualizerLoaded) return;

    final currentState = state as EqualizerLoaded;
    await _service.setBassBoostEnabled(value);

    emit(
      currentState.copyWith(
        data: currentState.data.copyWith(
          bassBoost: currentState.data.bassBoost.copyWith(enabled: value),
        ),
      ),
    );
  }

  Future<void> setVirtualizer(double value) async {
    if (state is! EqualizerLoaded) return;

    final currentState = state as EqualizerLoaded;
    await _service.setVirtualizer(value.round());

    emit(
      currentState.copyWith(
        data: currentState.data.copyWith(
          virtualizer: currentState.data.virtualizer.copyWith(
            strength: value.round(),
          ),
        ),
      ),
    );
  }

  Future<void> toggleVirtualizer(bool value) async {
    if (state is! EqualizerLoaded) return;

    final currentState = state as EqualizerLoaded;
    await _service.setVirtualizerEnabled(value);

    emit(
      currentState.copyWith(
        data: currentState.data.copyWith(
          virtualizer: currentState.data.virtualizer.copyWith(enabled: value),
        ),
      ),
    );
  }

  Future<void> setLoudness(double value) async {
    if (state is! EqualizerLoaded) return;

    final currentState = state as EqualizerLoaded;
    await _service.setLoudnessGain(value.round());

    emit(
      currentState.copyWith(
        data: currentState.data.copyWith(
          loudness: currentState.data.loudness.copyWith(gain: value.round()),
        ),
      ),
    );
  }

  Future<void> toggleLoudness(bool value) async {
    if (state is! EqualizerLoaded) return;

    final currentState = state as EqualizerLoaded;
    await _service.setLoudnessEnabled(value);

    emit(
      currentState.copyWith(
        data: currentState.data.copyWith(
          loudness: currentState.data.loudness.copyWith(enabled: value),
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _service.release();
    _sessionSub?.cancel();
    return super.close();
  }
}
