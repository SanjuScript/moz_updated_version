import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StorageLocationScreen extends StatefulWidget {
  const StorageLocationScreen({Key? key}) : super(key: key);

  @override
  State<StorageLocationScreen> createState() => _StorageLocationScreenState();
}

class _StorageLocationScreenState extends State<StorageLocationScreen> {
  final Box _settingsBox = Hive.box('settingsBox');

  List<String> allFolders = [
    '/storage/emulated/0/Music',
    '/storage/emulated/0/Download',
    '/storage/emulated/0/WhatsApp/Media/WhatsApp Audio',
    '/storage/emulated/0/Recordings',
    '/storage/emulated/0/Documents',
  ];

  Set<String> selectedFolders = {};
  double minAudioDuration = 5; // Default 5s

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  void _loadSavedSettings() {
    final savedFolders =
        _settingsBox.get('selected_folders', defaultValue: <String>[]);
    final savedDuration =
        _settingsBox.get('min_audio_duration', defaultValue: 5.0);

    setState(() {
      selectedFolders = (savedFolders as List).cast<String>().toSet();
      minAudioDuration = savedDuration;
    });
  }

  void _saveFolders() {
    _settingsBox.put('selected_folders', selectedFolders.toList());
  }

  void _saveDuration() {
    _settingsBox.put('min_audio_duration', minAudioDuration);
  }

  void _toggleFolder(String folder) {
    setState(() {
      if (selectedFolders.contains(folder)) {
        selectedFolders.remove(folder);
      } else {
        selectedFolders.add(folder);
      }
      _saveFolders(); // Auto-save after toggle
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Exclusion Settings"),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Select folders to EXCLUDE from your music library.\n"
                    "Songs inside these folders will NOT be scanned.\n\n"
                    "You can also exclude very short audios like WhatsApp tones by adjusting the minimum duration filter below.",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // Slider for minimum duration
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Minimum Audio Duration to Include",
                  style: theme.textTheme.titleMedium,
                ),
                Slider(
                  value: minAudioDuration,
                  min: 1,
                  max: 60,
                  divisions: 59,
                  label: "${minAudioDuration.toStringAsFixed(0)}s",
                  onChanged: (value) {
                    setState(() => minAudioDuration = value);
                    _saveDuration(); // Auto-save on slider move
                  },
                ),
                Text(
                  "Audios shorter than ${minAudioDuration.toStringAsFixed(0)} seconds will be excluded.",
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5),

          Expanded(
            child: ListView.separated(
              itemCount: allFolders.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, thickness: 0.5),
              itemBuilder: (context, index) {
                final folder = allFolders[index];
                final isSelected = selectedFolders.contains(folder);

                return ListTile(
                  leading: Icon(
                    Icons.folder,
                    color: isSelected
                        ? Colors.pinkAccent
                        : theme.iconTheme.color,
                  ),
                  title: Text(
                    folder.split('/').last,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.pinkAccent : null,
                    ),
                  ),
                  subtitle: Text(folder, style: const TextStyle(fontSize: 12)),
                  trailing: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: isSelected
                        ? const Icon(
                            Icons.block,
                            color: Colors.pinkAccent,
                            key: ValueKey('excluded'),
                          )
                        : const Icon(
                            Icons.check_circle_outline,
                            key: ValueKey('included'),
                          ),
                  ),
                  onTap: () => _toggleFolder(folder),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
