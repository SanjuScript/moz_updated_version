import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/removed_screen/presentation/cubit/removed_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/widgets/buttons/remove_song_button.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class RemovedSongsScreen extends StatefulWidget {
  const RemovedSongsScreen({super.key});

  @override
  State<RemovedSongsScreen> createState() => _RemovedSongsScreenState();
}

class _RemovedSongsScreenState extends State<RemovedSongsScreen> {
  bool isSelectionMode = false;
  final Set<int> selectedSongIds = {};

  void toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) selectedSongIds.clear();
    });
  }

  void toggleSongSelection(int songId) {
    setState(() {
      if (selectedSongIds.contains(songId)) {
        selectedSongIds.remove(songId);
      } else {
        selectedSongIds.add(songId);
      }
    });
  }

  void removeSelectedSongs(RemovedCubit cubit) async {
    for (final id in selectedSongIds) {
      final song = cubit.repository.removedItems.value.firstWhere(
        (s) => s.id == id,
      );
      await cubit.toggleRemoved(song);
    }
    setState(() {
      selectedSongIds.clear();
      isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Removed Songs"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(isSelectionMode ? Icons.close : Icons.checklist),
            onPressed: toggleSelectionMode,
          ),
        ],
      ),
      body: BlocBuilder<RemovedCubit, RemovedState>(
        builder: (context, state) {
          if (state is RemovedLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state is RemovedError) {
            return Center(child: Text(state.message));
          }
          if (state is RemovedLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text("No removed songs yet"));
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total ${items.length} Removed Songs",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final song = items[index];
                        final isSelected = selectedSongIds.contains(song.id);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: CustomSongTile(
                            song: song,
                            isTrailingChange: isSelectionMode,
                            onTap: isSelectionMode
                                ? () => toggleSongSelection(song.id)
                                : () {
                                    context.read<AudioBloc>().add(
                                      PlaySong(song, items),
                                    );
                                  },
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  )
                                : const Icon(Icons.radio_button_unchecked),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        child: selectedSongIds.isNotEmpty
            ? Padding(
                key: const ValueKey("removeBar"),
                padding: const EdgeInsets.all(16),
                child: AnimatedRemoveButton(
                  selectedCount: selectedSongIds.length,
                  onTap: () {
                    final removedCubit = context.read<RemovedCubit>();
                    final allSongsCubit = context.read<AllSongsCubit>();

                    final selectedSongs = removedCubit
                        .repository
                        .removedItems
                        .value
                        .where((song) => selectedSongIds.contains(song.id))
                        .toList();

                    removeSelectedSongs(removedCubit);

                    allSongsCubit.addRemovedSongsBackToSelection(selectedSongs);
                  },
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
