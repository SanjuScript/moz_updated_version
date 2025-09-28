import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/froasted_dialogue.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';

void showAddToPlaylistDialog(
  BuildContext context, {
  int? songId,
  List<int>? songIds,
}) {
  final ids = songIds ?? (songId != null ? [songId] : []);
  if (ids.isEmpty) return;
  final cubit = context.read<AllSongsCubit>();
  showDialog(
    context: context,
    builder: (dcontext) => FrostedDialog(
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
                  return const CircularProgressIndicator.adaptive();
                } else if (state is PlaylistLoaded) {
                  final playlists = state.playlists;
                  return Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: Colors.white.withValues(alpha: 0.3)),
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        final allAdded = ids.every(
                          (id) => playlist.songIds.contains(id),
                        );
                        return CheckboxListTile(
                          value: allAdded,
                          onChanged: (checked) {
                            if (checked == true) {
                              context.read<PlaylistCubit>().addSongsToPlaylist(
                                playlist.key,
                                ids,
                              );
                            } else {
                              context
                                  .read<PlaylistCubit>()
                                  .removeSongsFromPlaylist(playlist.key, ids);
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
                onPressed: () {
                  Navigator.of(dcontext, rootNavigator: true).pop();
                },

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
  ).then((_) {
    cubit.disableSelectionMode();
  });
}
