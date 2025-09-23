import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/settings/screens/storage_location_screen/cubit/storage_cubit.dart';

class StorageLocationScreen extends StatelessWidget {
  StorageLocationScreen({super.key});

  void _showAddFolderDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add New Folder Path"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "/storage/emulated/0/MyCustomFolder",
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () {
                final folder = controller.text.trim();
                if (folder.isNotEmpty) {
                  context.read<StorageCubit>().addFolder(folder);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<StorageCubit, StorageState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Audio Exclusion Settings"),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddFolderDialog(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            controller: scrollController,
            child: Column(
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
                          "You can also exclude very short audios by adjusting the minimum duration filter below.\n\n"
                          "⚠️ Restart might be needed to reflect changes.",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.5),

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
                        value: state.minAudioDuration,
                        min: 1,
                        max: 60,
                        divisions: 59,
                        label: "${state.minAudioDuration.toStringAsFixed(0)}s",
                        onChanged: (value) =>
                            context.read<StorageCubit>().updateDuration(value),
                      ),
                      Text(
                        "Audios shorter than ${state.minAudioDuration.toStringAsFixed(0)} seconds will be excluded.",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 0.5),

                ListView.separated(
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: state.allFolders.toSet().length + 1,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, index) {
                    final uniqueFolders = state.allFolders.toSet().toList();

                    if (index == uniqueFolders.length) {
                      return ListTile(
                        leading: const Icon(Icons.add, color: Colors.green),
                        title: const Text("Add new folder"),
                        onTap: () => _showAddFolderDialog(context),
                      );
                    }

                    final folder = uniqueFolders[index];
                    final isSelected = state.selectedFolders.contains(folder);

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
                      subtitle: Text(
                        folder,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
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
                          if (!context
                              .read<StorageCubit>()
                              .defaultFolders
                              .contains(folder))
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => context
                                  .read<StorageCubit>()
                                  .removeFolder(folder),
                            ),
                        ],
                      ),
                      onTap: () =>
                          context.read<StorageCubit>().toggleFolder(folder),
                    );
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
