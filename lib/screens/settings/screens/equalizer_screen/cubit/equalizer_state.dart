part of 'equalizer_cubit.dart';

abstract class EqualizerState extends Equatable {
  const EqualizerState();

  @override
  List<Object?> get props => [];
}

class EqualizerInitial extends EqualizerState {}

class EqualizerLoading extends EqualizerState {}

class EqualizerLoaded extends EqualizerState {
  final EqualizerData data;
  final List<String> presets;
  final List<int> fft;

  const EqualizerLoaded({
    required this.data,
    required this.presets,
    this.fft = const [],
  });

  @override
  List<Object?> get props => [data, presets, fft];

  EqualizerLoaded copyWith({
    EqualizerData? data,
    List<String>? presets,
    List<int>? fft,
  }) {
    return EqualizerLoaded(
      data: data ?? this.data,
      presets: presets ?? this.presets,
      fft: fft ?? this.fft,
    );
  }
}

class EqualizerError extends EqualizerState {
  final String message;

  const EqualizerError(this.message);

  @override
  List<Object?> get props => [message];
}
