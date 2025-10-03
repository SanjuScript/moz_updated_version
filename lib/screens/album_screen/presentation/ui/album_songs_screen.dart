import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/album_screen/presentation/cubit/album_cubit.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';

class AlbumSongsScreen extends StatelessWidget {
  final AlbumModel album;
  const AlbumSongsScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AlbumCubit, AlbumState>(
        builder: (context, state) {
          if (state is AlbumLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AlbumError) {
            return Center(child: Text("Error: ${state.message}"));
          }

          if (state is AlbumLoaded) {
            final songs = state.songs;

            if (album == null) {
              return const Center(child: Text("Album not found"));
            }
            if (songs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.library_music_outlined,
                        size: 72,
                        color: Colors.grey.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No songs in this album",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Some songs might be hidden due to your filter settings.\n"
                        "Check storage location and filtering options in settings.",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 200,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCollapsed =
                          constraints.maxHeight <= kToolbarHeight + 40;

                      return FlexibleSpaceBar(
                        centerTitle: false,
                        title: isCollapsed
                            ? Text(
                                album.album,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              )
                            : null,
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            AudioArtWorkWidget(
                              id: album.id,
                              type: ArtworkType.ALBUM,
                              size: 500,
                            ),

                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.7),
                              ),
                            ),

                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Theme.of(context).scaffoldBackgroundColor,
                                    ],
                                    stops: const [0.3, 1.0],
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: 120,
                                      width: 120,
                                      child: AudioArtWorkWidget(
                                        id: album.id,
                                        type: ArtworkType.ALBUM,
                                        size: 500,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            album.album,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${album.numOfSongs} Songs",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.white70,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (album.artist != null)
                                            Text(
                                              album.artist ?? '',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Colors.white70,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
                    final song = songs[index];
                    return CustomSongTile(
                      song: song,
                      onTap: () {
                        context.read<AudioBloc>().add(PlaySong(song, songs));
                      },
                    );
                  }, childCount: songs.length),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: MiniPlayer(),
    );
  }
}
