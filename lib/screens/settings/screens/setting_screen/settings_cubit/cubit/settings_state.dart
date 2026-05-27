part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final String imageQuality;
  final String audioQuality;
  final bool glassEnabled;

  const SettingsState({
    required this.imageQuality,
    required this.audioQuality,
    required this.glassEnabled,
  });

  SettingsState copyWith({
    String? imageQuality,
    String? audioQuality,
    bool? glassEnabled,
  }) {
    return SettingsState(
      imageQuality: imageQuality ?? this.imageQuality,
      audioQuality: audioQuality ?? this.audioQuality,
      glassEnabled: glassEnabled ?? this.glassEnabled,
    );
  }

  @override
  List<Object> get props => [imageQuality, audioQuality, glassEnabled];
}
