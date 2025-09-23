import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'storage_state.dart';

class StorageCubit extends Cubit<StorageState> {
  final Box settingsBox = Hive.box('settingsBox');

  final List<String> defaultFolders = [
    '/storage/emulated/0/Music',
    '/storage/emulated/0/Download',
    '/storage/emulated/0/WhatsApp/Media/WhatsApp Audio',
    '/storage/emulated/0/Music/Recordings',
    '/storage/emulated/0/Documents',
  ];

  StorageCubit()
    : super(
        StorageState(
          selectedFolders: {},
          allFolders: [],
          minAudioDuration: 5.0,
        ),
      ) {
    _loadSavedSettings();
  }

  void _loadSavedSettings() {
    final savedFolders = settingsBox.get(
      'selected_folders',
      defaultValue: <String>[],
    );
    final savedDuration = settingsBox.get(
      'min_audio_duration',
      defaultValue: 5.0,
    );

    final allFolders = [
      ...defaultFolders,
      ...((savedFolders as List).cast<String>()),
    ];

    emit(
      StorageState(
        selectedFolders: (savedFolders).cast<String>().toSet(),
        allFolders: allFolders,
        minAudioDuration: savedDuration,
      ),
    );
  }

  void toggleFolder(String folder) {
    final updated = Set<String>.from(state.selectedFolders);
    if (updated.contains(folder)) {
      updated.remove(folder);
    } else {
      updated.add(folder);
    }
    settingsBox.put('selected_folders', updated.toList());
    emit(state.copyWith(selectedFolders: updated));
  }

  void updateDuration(double value) {
    settingsBox.put('min_audio_duration', value);
    emit(state.copyWith(minAudioDuration: value));
  }

  void addFolder(String folder) {
    final updated = List<String>.from(state.allFolders)..add(folder);
    final updatedSelected = Set<String>.from(state.selectedFolders)
      ..add(folder);

    settingsBox.put('selected_folders', updatedSelected.toList());
    emit(state.copyWith(allFolders: updated, selectedFolders: updatedSelected));
  }

  void removeFolder(String folder) {
    if (defaultFolders.contains(folder)) return; 

    final updated = List<String>.from(state.allFolders)..remove(folder);
    final updatedSelected = Set<String>.from(state.selectedFolders)
      ..remove(folder);

    settingsBox.put('selected_folders', updatedSelected.toList());
    emit(state.copyWith(allFolders: updated, selectedFolders: updatedSelected));
  }
}
