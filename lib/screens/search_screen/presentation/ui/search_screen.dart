import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/album_screen/presentation/cubit/album_cubit.dart';
import 'package:moz_updated_version/screens/album_screen/presentation/ui/album_songs_screen.dart';
import 'package:moz_updated_version/screens/artists_screen/presentation/cubit/artist_cubit.dart';
import 'package:moz_updated_version/screens/artists_screen/presentation/ui/artists_songs_screen.dart';
import 'package:moz_updated_version/screens/search_screen/presentation/ui/search_model_helper.dart';
import 'package:moz_updated_version/screens/search_screen/presentation/ui/widgets/seperate_tiles.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SearchSongsScreen extends StatelessWidget {
  SearchSongsScreen({super.key});

  final ValueNotifier<String> _searchQuery = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Search",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: BlocBuilder<AllSongsCubit, AllsongsState>(
        builder: (context, songState) {
          final albumState = context.watch<AlbumCubit>().state;
          final artistState = context.watch<ArtistCubit>().state;

          if (songState is AllSongsLoading ||
              albumState is AlbumLoading ||
              artistState is ArtistLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (songState is AllSongsError ||
              albumState is AlbumError ||
              artistState is ArtistError) {
            return Center(
              child: Text(
                "Error loading library",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            );
          }

          if (songState is AllSongsLoaded &&
              albumState is AlbumLoaded &&
              artistState is ArtistLoaded) {
            final songs = songState.songs;
            final albums = albumState.albums;
            final artists = artistState.artists;

            return Column(
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * .10),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Search songs, artists, albums...",
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                      ),
                      onChanged: (val) =>
                          _searchQuery.value = val.toLowerCase(),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),

                Expanded(
                  child: BlocBuilder<AudioBloc, AudioState>(
                    builder: (context, audioState) {
                      return ValueListenableBuilder<String>(
                        valueListenable: _searchQuery,
                        builder: (context, query, _) {
                          List<SearchResult> results = [];

                          if (query.isEmpty) {
                            results = songs
                                .map((s) => SearchResult.song(s))
                                .toList();
                          } else {
                            results = [
                              ...songs
                                  .where(
                                    (s) =>
                                        s.title.toLowerCase().contains(query),
                                  )
                                  .map((s) => SearchResult.song(s)),
                              ...albums
                                  .where(
                                    (a) =>
                                        a.album.toLowerCase().contains(query),
                                  )
                                  .map((a) => SearchResult.album(a)),
                              ...artists
                                  .where(
                                    (a) =>
                                        a.artist.toLowerCase().contains(query),
                                  )
                                  .map((a) => SearchResult.artist(a)),
                            ];

                            results.sort((a, b) => a.text.compareTo(b.text));
                          }

                          if (results.isEmpty) {
                            return Center(
                              child: Text(
                                "No results found",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final res = results[index];
                              Widget tile;

                              switch (res.type) {
                                case SearchType.song:
                                  tile = CustomSongTile(
                                    song: res.song!,
                                    isTrailingChange: false,
                                    onTap: () {
                                      final songList = results
                                          .where(
                                            (r) => r.type == SearchType.song,
                                          )
                                          .map((r) => r.song!)
                                          .toList();
                                      context.read<AudioBloc>().add(
                                        PlaySong(res.song!, songList),
                                      );
                                    },
                                  );
                                  break;
                                case SearchType.album:
                                  tile = CustomCardTile(
                                    id: res.album!.id,
                                    type: ArtworkType.ALBUM,
                                    title: res.album!.album,
                                    subtitle: "${res.album!.numOfSongs} songs",
                                    onTap: () async {
                                      await context
                                          .read<AlbumCubit>()
                                          .loadAlbumSongs(res.album!.id);
                                      sl<NavigationService>().navigateTo(
                                        AlbumSongsScreen(album: res.album!),
                                      );
                                    },
                                  );

                                  break;
                                case SearchType.artist:
                                  tile = CustomCardTile(
                                    id: res.artist!.id,
                                    type: ArtworkType.ARTIST,
                                    title: res.artist!.artist,
                                    subtitle:
                                        "${res.artist!.numberOfAlbums} albums • ${res.artist!.numberOfTracks} tracks",
                                    onTap: () async {
                                      await context
                                          .read<ArtistCubit>()
                                          .loadArtistSongs(res.artist!.id);
                                      sl<NavigationService>().navigateTo(
                                        ArtistSongsScreen(artist: res.artist!),
                                      );
                                    },
                                  );

                                  break;
                              }

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
                      );
                    },
                  ),
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
