import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/artists_screen/presentation/cubit/artist_cubit.dart';
import 'package:moz_updated_version/screens/mini_player/presentation/ui/mini_player.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';

class ArtistSongsScreen extends StatelessWidget {
  final ArtistModel artist;
  const ArtistSongsScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ArtistCubit, ArtistState>(
        builder: (context, state) {
          if (state is ArtistLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ArtistError) {
            return Center(child: Text("Error: ${state.message}"));
          }

          if (state is ArtistLoaded) {
            final songs = state.songs;

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
                        color: Colors.grey.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No songs for this artist",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.surface,
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
                                artist.artist,
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
                              id: artist.id,
                              type: ArtworkType.ARTIST,
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
                                        id: artist.id,
                                        type: ArtworkType.ARTIST,
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
                                            artist.artist,
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
                                            "${artist.numberOfAlbums} Albums",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.white70,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${artist.numberOfTracks} Tracks",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.white70,
                                                ),
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
