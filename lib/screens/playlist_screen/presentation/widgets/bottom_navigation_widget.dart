import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/ui/now_playing_screen.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/buttons/remove_song_button.dart';

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
              ? AnimatedRemoveButton(
                  key: const ValueKey("removeBar"),
                  selectedCount: selectedCount,
                  onTap: () {
                    final playlist = state.playlists.firstWhere(
                      (p) => p.key == playlistkey,
                    );

                    context.read<PlaylistCubit>().removeSongsFromPlaylist(
                      playlist.key,
                      state.selectedSongIds.toList(),
                    );

                    context.read<PlaylistCubit>().disableSelection();
                  },
                )
              : const MiniPlayer(),
        );
      },
    );
  }
}
