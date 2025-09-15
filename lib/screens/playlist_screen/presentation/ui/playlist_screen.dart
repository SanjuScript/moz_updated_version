import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:moz_updated_version/core/animations/page_animations/fade_animation.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/ui/add_songs_to_playlist.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/ui/songs_view.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/artwork_displaying.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/playlist_add_dialogue.dart';
import 'package:moz_updated_version/services/core/app_services.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlaylistCubit>();
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistInitial) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is PlaylistError) {
            return Center(child: Text("Error: ${state.message}"));
          }

          if (state is PlaylistLoaded) {
            final playlists = state.playlists;
            if (playlists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No playlists created yet",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton.filled(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (_) => PlaylistDialog(
                            title: "New Playlist",
                            onSave: (name) {
                              cubit.createPlaylist(name);
                            },
                          ),
                        );
                      },
                      icon: Icon(Icons.playlist_add),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: false,
                  expandedHeight: 50,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total ${playlists.length} Playlists",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Spacer(),
                        DropdownButton<PlaylistSortOption>(
                          padding: EdgeInsets.zero,
                          focusColor: Colors.transparent,
                          value: cubit.currentSort,
                          dropdownColor: Theme.of(
                            context,
                          ).dropdownMenuTheme.inputDecorationTheme?.fillColor,
                          underline: const SizedBox.shrink(),
                          borderRadius: BorderRadius.circular(12),
                          style: Theme.of(context).dropdownMenuTheme.textStyle,
                          onChanged: (value) {
                            if (value != null) cubit.changeSort(value);
                          },
                          items: const [
                            DropdownMenuItem(
                              value: PlaylistSortOption.dateAdded,
                              child: Text("Default"),
                            ),
                            DropdownMenuItem(
                              value: PlaylistSortOption.songCountLargest,
                              child: Text("Song Count ↑"),
                            ),
                            DropdownMenuItem(
                              value: PlaylistSortOption.songCountSmallest,
                              child: Text("Song Count ↓"),
                            ),
                            DropdownMenuItem(
                              value: PlaylistSortOption.dateCreatedNewest,
                              child: Text("Created Newest"),
                            ),
                            DropdownMenuItem(
                              value: PlaylistSortOption.dateCreatedOldest,
                              child: Text("Created Oldest"),
                            ),
                          ],
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (_) => PlaylistDialog(
                                title: "New Playlist",
                                onSave: (name) {
                                  cubit.createPlaylist(name);
                                },
                              ),
                            );
                          },
                          icon: Icon(Icons.playlist_add),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final playlist = playlists[index];
                    final currentKeyNotifier =
                        GetIt.I<AudioBloc>().currentPlaylistKeyNotifier;

                    return ValueListenableBuilder<int?>(
                      valueListenable: currentKeyNotifier,
                      builder: (context, value, child) {
                        final isActive = value == playlist.key;
                        return PlaylistGridItem(
                          isNowPlaying: isActive,
                          playlist: playlist,
                          onTap: () {
                            if (playlist.songIds.isEmpty) {
                              sl<NavigationService>().navigateTo(
                                AddSongsToPlaylistScreen(
                                  playlistKey: playlist.key,
                                ),
                                animation: NavigationAnimation.fade,
                              );
                            } else {
                              sl<NavigationService>().navigateTo(
                                PlaylistSongsScreen(playlistkey: playlist.key),
                                animation: NavigationAnimation.fade,
                              );
                            }
                          },
                          onEdit: () {
                            showDialog(
                              context: context,
                              builder: (_) => PlaylistDialog(
                                title: "Edit Playlist",
                                initialName: playlist.name,
                                onSave: (name) {
                                  cubit.editPlaylist(playlist.key, name);
                                },
                              ),
                            );
                          },

                          onDelete: () => cubit.deletePlaylist(playlist.key),
                        );
                      },
                    );
                  }, childCount: playlists.length),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
