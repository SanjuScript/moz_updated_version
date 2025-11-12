part of 'volume_manager_cubit.dart';

class VolumeState extends Equatable {
  final int currentVolume;
  final int maxVolume;
  final bool isLoading;
  final String? errorMessage;

  const VolumeState({
    required this.currentVolume,
    required this.maxVolume,
    this.isLoading = false,
    this.errorMessage,
  });

  factory VolumeState.initial() {
    return const VolumeState(
      currentVolume: 0,
      maxVolume: 15,
      isLoading: false,
      errorMessage: null,
    );
  }

  VolumeState copyWith({
    int? currentVolume,
    int? maxVolume,
    bool? isLoading,
    String? errorMessage,
  }) {
    return VolumeState(
      currentVolume: currentVolume ?? this.currentVolume,
      maxVolume: maxVolume ?? this.maxVolume,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    currentVolume,
    maxVolume,
    isLoading,
    errorMessage,
  ];
}
