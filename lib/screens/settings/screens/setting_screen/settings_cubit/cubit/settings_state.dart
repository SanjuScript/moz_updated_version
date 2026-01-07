part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final String imageQuality;
  final String audioQuality;

  const SettingsState({required this.imageQuality, required this.audioQuality});

  SettingsState copyWith({String? imageQuality, String? audioQuality}) {
    return SettingsState(
      imageQuality: imageQuality ?? this.imageQuality,
      audioQuality: audioQuality ?? this.audioQuality,
    );
  }

  @override
  List<Object> get props => [imageQuality, audioQuality];
}
