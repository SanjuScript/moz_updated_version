import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class AddSongsToPlaylistScreen extends StatelessWidget {
  final int playlistKey;
  const AddSongsToPlaylistScreen({super.key, required this.playlistKey});

  @override
  Widget build(BuildContext context) {
    final playlistCubit = context.read<PlaylistCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Songs")),
      body: BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, playlistState) {
          if (playlistState is! PlaylistLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final playlist = playlistState.playlists.firstWhere(
            (p) => p.key == playlistKey,
            orElse: () => throw Exception("Playlist not found"),
          );

          final existingSongIds = playlist.songIds.toSet();

          return BlocBuilder<AllSongsCubit, AllsongsState>(
            builder: (context, state) {
              if (state is AllSongsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AllSongsError) {
                return Center(child: Text("Error: ${state.message}"));
              }

              if (state is AllSongsLoaded) {
                final songs = state.songs;

                return ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final isSelected = existingSongIds.contains(song.id);

                    final tile = CustomSongTile(
                      song: song,
                      disableOnTap: true,
                      isTrailingChange: true,
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          if (val == true) {
                            playlistCubit.addSongToPlaylist(
                              playlistKey,
                              song.id,
                            );
                          } else {
                            playlistCubit.removeSongFromPlaylist(
                              playlistKey,
                              song.id,
                            );
                          }
                        },
                      ),
                      onTap: () {
                        if (isSelected) {
                          playlistCubit.removeSongFromPlaylist(
                            playlistKey,
                            song.id,
                          );
                        } else {
                          playlistCubit.addSongToPlaylist(playlistKey, song.id);
                        }
                      },
                    );

                    if (index < 10) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          verticalOffset: 50,
                          child: FadeInAnimation(child: tile),
                        ),
                      );
                    }
                    return tile;
                  },
                );
              }

              return const SizedBox();
            },
          );
        },
      ),
    );
  }
}
