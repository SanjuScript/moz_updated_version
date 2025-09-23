part of 'storage_cubit.dart';

class StorageState {
  final Set<String> selectedFolders;
  final List<String> allFolders;
  final double minAudioDuration;

  StorageState({
    required this.selectedFolders,
    required this.allFolders,
    required this.minAudioDuration,
  });

  StorageState copyWith({
    Set<String>? selectedFolders,
    List<String>? allFolders,
    double? minAudioDuration,
  }) {
    return StorageState(
      selectedFolders: selectedFolders ?? this.selectedFolders,
      allFolders: allFolders ?? this.allFolders,
      minAudioDuration: minAudioDuration ?? this.minAudioDuration,
    );
  }
}