import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/db/app_settings/app_settings_db.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
    : super(
        SettingsState(
          imageQuality: SettingsManager.getImageQuality(),
          audioQuality: SettingsManager.getAudioQuality(),
        ),
      );

  Future<void> setImageQuality(String quality) async {
    await SettingsManager.setImageQuality(quality);
    emit(state.copyWith(imageQuality: quality));
  }

  Future<void> setAudioQuality(String quality) async {
    await SettingsManager.setAudioQuality(quality);
    emit(state.copyWith(audioQuality: quality));
  }

  void reload() {
    emit(
      SettingsState(
        imageQuality: SettingsManager.getImageQuality(),
        audioQuality: SettingsManager.getAudioQuality(),
      ),
    );
  }
}
