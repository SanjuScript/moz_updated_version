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

  const EqualizerLoaded({required this.data, required this.presets});

  @override
  List<Object?> get props => [data, presets];

  EqualizerLoaded copyWith({EqualizerData? data, List<String>? presets}) {
    return EqualizerLoaded(
      data: data ?? this.data,
      presets: presets ?? this.presets,
    );
  }
}

class EqualizerError extends EqualizerState {
  final String message;

  const EqualizerError(this.message);

  @override
  List<Object?> get props => [message];
}
