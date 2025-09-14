import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/screens/removed_screen/presentation/cubit/removed_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/widgets/add_to_playlis_dalogue.dart';

class BottomNavigationWidgetForAllSongs extends StatelessWidget {
  const BottomNavigationWidgetForAllSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllSongsCubit, AllsongsState>(
      builder: (context, state) {
        final isSelecting = state is AllSongsLoaded && state.isSelecting;
        final selectedCount = state is AllSongsLoaded
            ? state.selectedSongs.length
            : 0;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            final offsetAnimation =
                Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );
            return SlideTransition(position: offsetAnimation, child: child);
          },
          child: isSelecting
              ? Container(
                  key: const ValueKey("actionBar"),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ),
                            foregroundColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.playlist_add),
                          label: const Text("Add to Playlist"),
                          onPressed: selectedCount > 0
                              ? () {
                                  final selectedSongIds = state.songs
                                      .where(
                                        (song) => state.selectedSongs.contains(
                                          song.data,
                                        ),
                                      )
                                      .map((song) => song.id)
                                      .toList();
                                  showAddToPlaylistDialog(
                                    context,
                                    songIds: selectedSongIds,
                                  );
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.orange,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(vertical: 14),
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.remove_circle_outline),
                              label: Text("Remove ($selectedCount)"),
                              onPressed: selectedCount > 0
                                  ? () {
                                      final selectedSongs = state.songs
                                          .where(
                                            (song) => state.selectedSongs
                                                .contains(song.data),
                                          )
                                          .toList();
                                      final removedCubit = context
                                          .read<RemovedCubit>();
                                      for (var song in selectedSongs) {
                                        removedCubit.toggleRemoved(song);
                                      }
                                      context
                                          .read<AllSongsCubit>()
                                          .removeSelectedSongsFromList();
                                      context
                                          .read<AllSongsCubit>()
                                          .disableSelectionMode();
                                    }
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.redAccent,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(vertical: 14),
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.delete),
                              label: Text("Delete ($selectedCount)"),
                              onPressed: selectedCount > 0
                                  ? () => context
                                        .read<AllSongsCubit>()
                                        .deleteSelectedSongs()
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const MiniPlayer(key: ValueKey("miniPlayer")),
        );
      },
    );
  }
}
