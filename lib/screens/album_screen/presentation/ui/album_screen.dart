import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/album_screen/presentation/cubit/album_cubit.dart';
import 'package:moz_updated_version/screens/album_screen/presentation/ui/album_songs_screen.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumCubit, AlbumState>(
      builder: (context, state) {
        final cubit = context.read<AlbumCubit>();
        final albums = (state is AlbumLoaded) ? state.albums : <AlbumModel>[];

        if (state is AlbumLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AlbumError) {
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
                      "Total ${albums.length} Albums",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    DropdownButton<AlbumSortOption>(
                      focusColor: Colors.transparent,
                      dropdownColor: Theme.of(
                        context,
                      ).dropdownMenuTheme.inputDecorationTheme?.fillColor,
                      value: cubit.currentSort,
                      borderRadius: BorderRadius.circular(15),
                      underline: const SizedBox.shrink(),
                      style: Theme.of(context).dropdownMenuTheme.textStyle,
                      onChanged: (value) {
                        if (value != null) cubit.changeSort(value);
                      },
                      items: const [
                        DropdownMenuItem(
                          value: AlbumSortOption.name,
                          child: Text("Name"),
                        ),
                        DropdownMenuItem(
                          value: AlbumSortOption.numberOfSongsLargest,
                          child: Text("More songs"),
                        ),
                        DropdownMenuItem(
                          value: AlbumSortOption.numberOfSongsSmallest,
                          child: Text("Less songs"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 Change to Grid Layout
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final album = albums[index];
                  return GestureDetector(
                    onTap: () {
                      context.read<AlbumCubit>().loadAlbumSongs(album.id);
                      sl<NavigationService>().navigateTo(
                        AlbumSongsScreen(
                      album: album,
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Hero(
                              tag: album.id,
                              child: AudioArtWorkWidget(
                                id: album.id,
                                type: ArtworkType.ALBUM,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Column(
                              children: [
                                Text(
                                  album.album,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${album.numOfSongs} Songs",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: albums.length),
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
