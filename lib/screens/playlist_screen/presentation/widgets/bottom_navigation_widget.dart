import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/ui/now_playing_screen.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/services/core/app_services.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int playlistkey;
  const BottomNavigationWidget({super.key, required this.playlistkey});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        final isSelecting = state is PlaylistLoaded && state.isSelecting;
        final selectedCount = state is PlaylistLoaded
            ? state.selectedSongIds.length
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
                  key: const ValueKey("removeBar"),
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    key: const ValueKey("miniPlayer"),
                    onTap: () {
                      if (selectedCount > 0) {
                        final playlist = state.playlists.firstWhere(
                          (p) => p.key == playlistkey,
                        );

                        context.read<PlaylistCubit>().removeSongsFromPlaylist(
                          playlist.key,
                          state.selectedSongIds.toList(),
                        );

                        context.read<PlaylistCubit>().disableSelection();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          "Remove ($selectedCount)",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const MiniPlayer(),
        );
      },
    );
  }
}
