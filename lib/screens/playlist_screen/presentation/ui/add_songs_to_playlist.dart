import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/data/db/download_songs/repository/download_repo.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AddSongsToPlaylistScreen extends StatelessWidget {
  final int playlistKey;
  AddSongsToPlaylistScreen({super.key, required this.playlistKey});

  final ValueNotifier<String> _searchQuery = ValueNotifier("");
  final ValueNotifier<int> _selectedFilter = ValueNotifier(
    0,
  ); // 0: All, 1: Local, 2: Downloaded

  @override
  Widget build(BuildContext context) {
    final playlistCubit = context.read<PlaylistCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Songs")),
      body: BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, playlistState) {
          if (playlistState is! PlaylistLoaded) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final playlist = playlistState.playlists.firstWhere(
            (p) => p.key == playlistKey,
            orElse: () => throw Exception("Playlist not found"),
          );

          final existingSongIds = playlist.songIds.toSet();

          return BlocBuilder<AllSongsCubit, AllsongsState>(
            builder: (context, state) {
              if (state is AllSongsLoading) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
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
                        decoration: const InputDecoration(
                          hintText: "Search songs...",
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (val) =>
                            _searchQuery.value = val.toLowerCase(),

                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: _selectedFilter,
                      builder: (context, filterValue, _) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              ChoiceChip(
                                label: const Text("All"),
                                selected: filterValue == 0,
                                onSelected: (val) => _selectedFilter.value = 0,
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text("Local"),
                                selected: filterValue == 1,
                                onSelected: (val) => _selectedFilter.value = 1,
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text("Downloaded"),
                                selected: filterValue == 2,
                                onSelected: (val) => _selectedFilter.value = 2,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _selectedFilter,
                        builder: (context, filterValue, _) {
                          return ValueListenableBuilder<String>(
                            valueListenable: _searchQuery,
                            builder: (context, query, _) {
                              final downloaded =
                                  DownloadSongRepository.getAllSongs()
                                      .toSongModels();

                              List<SongModel> sourceSongs;
                              if (filterValue == 0) {
                                sourceSongs = [...songs, ...downloaded];
                              } else if (filterValue == 1) {
                                sourceSongs = songs;
                              } else {
                                sourceSongs = downloaded;
                              }

                              final filteredSongs = query.isEmpty
                                  ? sourceSongs
                                  : sourceSongs
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
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
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
