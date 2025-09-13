import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/froasted_dialogue.dart';

void showAddToPlaylistDialog(BuildContext context, int songId) {
  showDialog(
    context: context,
    builder: (_) => FrostedDialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Add to Playlist",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 20),
            BlocBuilder<PlaylistCubit, PlaylistState>(
              builder: (context, state) {
                if (state is PlaylistInitial) {
                  return const CircularProgressIndicator();
                } else if (state is PlaylistLoaded) {
                  final playlists = state.playlists;
                  return Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: Colors.white.withOpacity(0.3)),
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        final isAdded = playlist.songIds.contains(songId);
                        return CheckboxListTile(
                          value: isAdded,
                          onChanged: (checked) {
                            if (checked == true) {
                              context.read<PlaylistCubit>().addSongToPlaylist(
                                playlist.key,
                                songId,
                              );
                            } else {
                              context
                                  .read<PlaylistCubit>()
                                  .removeSongFromPlaylist(playlist.key, songId);
                            }
                          },
                          title: Text(
                            playlist.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Close",
                  style: TextStyle(color: Theme.of(context).disabledColor),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
