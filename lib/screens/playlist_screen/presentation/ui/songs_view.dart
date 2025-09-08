import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/ui/add_songs_to_playlist.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/app_bar_bg.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/bottom_navigation_widget.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/custom_tile_with_trailing.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistSongsScreen extends StatelessWidget {
  final int playlistkey;
  const PlaylistSongsScreen({super.key, required this.playlistkey});

  @override
  Widget build(BuildContext context) {
    final allSongsCubit = context.read<AllSongsCubit>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final cubit = context.read<PlaylistCubit>();
        final state = cubit.state;
        if (state is PlaylistLoaded && state.isSelecting) {
          context.read<PlaylistCubit>().disableSelection();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: BlocBuilder<PlaylistCubit, PlaylistState>(
          builder: (context, state) {
            if (state is PlaylistInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PlaylistError) {
              return Center(child: Text("Error: ${state.message}"));
            }

            if (state is PlaylistLoaded) {
              final playlist = state.playlists.firstWhere(
                (p) => p.key == playlistkey,
                orElse: () => throw Exception("Playlist not found"),
              );

              final songIds = playlist.songIds;

              final allSongs = (allSongsCubit.state is AllSongsLoaded)
                  ? (allSongsCubit.state as AllSongsLoaded).songs
                  : <SongModel>[];

              final songsInPlaylist = allSongs
                  .where((song) => songIds.contains(song.id))
                  .toList();

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 280,
                    stretch: true,
                    actions: [
                      IconButton(
                        tooltip: "Add Songs",
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddSongsToPlaylistScreen(
                                playlistKey: playlist.key,
                              ),
                            ),
                          );
                        },
                      ),
                      BlocBuilder<PlaylistCubit, PlaylistState>(
                        builder: (context, state) {
                          if (state is PlaylistLoaded) {
                            return IconButton(
                              tooltip: state.isSelecting
                                  ? "Cancel Selection"
                                  : "Select Songs",
                              icon: Icon(
                                state.isSelecting
                                    ? Icons.close
                                    : Icons.check_box_outlined,
                              ),
                              onPressed: () {
                                if (state.isSelecting) {
                                  context
                                      .read<PlaylistCubit>()
                                      .disableSelection();
                                } else {
                                  context
                                      .read<PlaylistCubit>()
                                      .enableSelection();
                                }
                              },
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        final isCollapsed =
                            constraints.maxHeight <= kToolbarHeight + 40;

                        return FlexibleSpaceBar(
                          centerTitle: false,
                          title: isCollapsed
                              ? Text(
                                  playlist.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                )
                              : null,
                          background: AppBarBackground(
                            songsInPlaylist: songsInPlaylist,
                            playlist: playlist,
                            isCollapsed: isCollapsed,
                          ),
                        );
                      },
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final song = songsInPlaylist[index];
                      if (index < 10) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 400),
                          child: SlideAnimation(
                            verticalOffset: 50,
                            child: FadeInAnimation(
                              child: CustomTileWithTrailing(
                                songsInPlaylist: songsInPlaylist,
                                playlistkey: playlistkey,
                                index: index,
                              ),
                            ),
                          ),
                        );
                      }
                      return CustomTileWithTrailing(
                        songsInPlaylist: songsInPlaylist,
                        playlistkey: playlistkey,
                        index: index,
                      );
                    }, childCount: songsInPlaylist.length),
                  ),
                  if (songsInPlaylist.length > 9)
                    SliverToBoxAdapter(child: SizedBox(height: 5)),
                ],
              );
            }

            return const SizedBox();
          },
        ),
        bottomNavigationBar: BottomNavigationWidget(playlistkey: playlistkey),
      ),
    );
  }
}
