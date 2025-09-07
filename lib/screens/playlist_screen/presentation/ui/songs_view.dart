import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/cubit/playlist_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/ui/add_songs_to_playlist.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistSongsScreen extends StatelessWidget {
  final int playlistkey;
  const PlaylistSongsScreen({super.key, required this.playlistkey});

  @override
  Widget build(BuildContext context) {
    final allSongsCubit = context.read<AllSongsCubit>();

    return Scaffold(
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
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Hero(
                              tag: playlist.key,
                              child: AudioArtWorkWidget(
                                id: playlist.artwork,
                                size: 500,
                                radius: 0,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Theme.of(context).scaffoldBackgroundColor
                                        .withValues(alpha: .2),
                                    Theme.of(context).scaffoldBackgroundColor
                                        .withValues(alpha: 1),
                                  ],
                                ),
                              ),
                            ),
                            if (!isCollapsed)
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 24,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          playlist.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "${songsInPlaylist.length} songs",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      overlayColor: WidgetStateProperty.all(
                                        Colors.transparent,
                                      ),
                                      onTap: () {
                                        context.read<AudioBloc>().add(
                                          PlaySong(
                                            songsInPlaylist.first,
                                            songsInPlaylist,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.pink,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              offset: const Offset(0, 4),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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
                            child: CustomSongTile(
                              song: song,
                              disableOnTap: true,
                              onTap: () => context.read<AudioBloc>().add(
                                PlaySong(song, songsInPlaylist),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return CustomSongTile(
                      song: song,
                      disableOnTap: true,
                      onTap: () => context.read<AudioBloc>().add(
                        PlaySong(song, songsInPlaylist),
                      ),
                    );
                  }, childCount: songsInPlaylist.length),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
