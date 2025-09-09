import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class AddSongsToPlaylistScreen extends StatelessWidget {
  final int playlistKey;
  AddSongsToPlaylistScreen({super.key, required this.playlistKey});

  final ValueNotifier<String> _searchQuery = ValueNotifier("");

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

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search songs...",
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (val) =>
                            _searchQuery.value = val.toLowerCase(),

                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    Expanded(
                      child: ValueListenableBuilder<String>(
                        valueListenable: _searchQuery,
                        builder: (context, query, _) {
                          final filteredSongs = query.isEmpty
                              ? songs
                              : songs
                                    .where(
                                      (s) =>
                                          s.title.toLowerCase().contains(
                                            query,
                                          ) ||
                                          (s.artist ?? "")
                                              .toLowerCase()
                                              .contains(query),
                                    )
                                    .toList();

                          if (filteredSongs.isEmpty) {
                            return const Center(
                              child: Text(
                                "No songs found",
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: filteredSongs.length,
                            itemBuilder: (context, index) {
                              final song = filteredSongs[index];
                              final isSelected = existingSongIds.contains(
                                song.id,
                              );

                              final tile = CustomSongTile(
                                song: song,
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
                                    playlistCubit.addSongToPlaylist(
                                      playlistKey,
                                      song.id,
                                    );
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
                        },
                      ),
                    ),
                  ],
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
