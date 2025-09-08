import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';

class GlobalWidgets{
static  Future<void> showAddToPlaylistDialog(BuildContext context, SongModel song) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400, minWidth: 320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Manage Playlists",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Content
              Expanded(
                child: BlocBuilder<PlaylistCubit, PlaylistState>(
                  builder: (context, state) {
                    if (state is PlaylistInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PlaylistLoaded) {
                      if (state.playlists.isEmpty) {
                        return const Center(
                          child: Text("No playlists found. Create one first."),
                        );
                      }
                      return Scrollbar(
                        thumbVisibility: true,
                        radius: const Radius.circular(12),
                        thickness: 6,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: state.playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = state.playlists[index];
                            final isAlreadyInPlaylist = playlist.songIds
                                .contains(song.id);

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              leading: AudioArtWorkWidget(
                                id: playlist.artwork,
                                iconSize: 50,
                              ),
                              title: Text(
                                playlist.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                "${playlist.songIds.length} songs",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  elevation: 2,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () {
                                  if (isAlreadyInPlaylist) {
                                    context
                                        .read<PlaylistCubit>()
                                        .removeSongFromPlaylist(
                                          playlist.key,
                                          song.id,
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Removed from ${playlist.name}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    context
                                        .read<PlaylistCubit>()
                                        .addSongToPlaylist(
                                          playlist.key,
                                          song.id,
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Added to ${playlist.name}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  isAlreadyInPlaylist
                                      ? Icons.remove_circle
                                      : Icons.add,
                                  color: Theme.of(context).hintColor,
                                  size: 18,
                                ),
                                label: Text(
                                  isAlreadyInPlaylist ? "Remove" : "Add",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else if (state is PlaylistError) {
                      return Center(child: Text("Error: ${state.message}"));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

}