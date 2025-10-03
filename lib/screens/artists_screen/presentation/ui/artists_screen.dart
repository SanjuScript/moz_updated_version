import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/artists_screen/presentation/cubit/artist_cubit.dart';
import 'package:moz_updated_version/screens/artists_screen/presentation/ui/artists_songs_screen.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/widgets/custom_menu/custom_dropdown.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistCubit, ArtistState>(
      builder: (context, state) {
        final cubit = context.read<ArtistCubit>();
        final artists = (state is ArtistLoaded)
            ? state.artists
            : <ArtistModel>[];

        if (state is ArtistLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ArtistError) {
          return Center(child: Text("Error: ${state.message}"));
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              expandedHeight: 50,
              automaticallyImplyLeading: false,
              flexibleSpace: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total ${artists.length} Artists",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),

                    PremiumDropdown<ArtistSortOption>(
                      items: const [
                        ArtistSortOption.name,
                        ArtistSortOption.numberOfAlbums,
                        ArtistSortOption.numberOfTracks,
                      ],
                      initialValue: cubit.currentSort,
                      borderRadius: BorderRadius.circular(15),
                      width: 160,
                      hint: const Text("Sort Artists"),
                      labelBuilder: (option) {
                        switch (option) {
                          case ArtistSortOption.name:
                            return "Name";
                          case ArtistSortOption.numberOfAlbums:
                            return "Albums";
                          case ArtistSortOption.numberOfTracks:
                            return "Tracks";
                        }
                      },
                      onChanged: (value) {
                        if (value != null) cubit.changeSort(value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final artist = artists[index];
                  return GestureDetector(
                    onTap: () {
                      context.read<ArtistCubit>().loadArtistSongs(artist.id);
                      sl<NavigationService>().navigateTo(
                        ArtistSongsScreen(artist: artist),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AudioArtWorkWidget(
                              id: artist.id,
                              type: ArtworkType.ARTIST,
                              radius: 15,
                              size: 500,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    artist.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 10,
                                    children: [
                                      Text(
                                        "${artist.numberOfAlbums} Albums",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      Text(
                                        "${artist.numberOfTracks} Tracks",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: artists.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
