import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist/playlist_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/froasted_dialogue.dart';

void showOnlinePlaylistDalogue(BuildContext context, {required String songId}) {
  context.read<OnlinePlaylistCubit>().loadPlaylists();
  showDialog(
    context: context,
    builder: (dContext) => FrostedDialog(
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
            const SizedBox(height: 16),

            BlocBuilder<OnlinePlaylistCubit, OnlinePlaylistState>(
              builder: (context, state) {
                if (state is! OnlinePlaylistsLoaded) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (state.playlists.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "No playlists yet.\nCreate one first.",
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.playlists.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.white.withValues(alpha: 0.2)),
                  itemBuilder: (context, index) {
                    final playlist = state.playlists[index];

                    return ListTile(
                      leading: const Icon(Icons.queue_music),
                      title: Text(
                        playlist.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      onTap: () async {
                        await context
                            .read<OnlinePlaylistCubit>()
                            .addSongToPlaylist(
                              playlistId: playlist.id,
                              songId: songId,
                            );

                        Navigator.of(dContext, rootNavigator: true).pop();
                        AppSnackBar.success(
                          context,
                          "Added to ${playlist.name}",
                        );
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(dContext, rootNavigator: true).pop();
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
  );
}
