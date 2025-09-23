import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AllSongScreen extends StatelessWidget {
  const AllSongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllSongsCubit, AllsongsState>(
      builder: (context, state) {
        final cubit = context.read<AllSongsCubit>();
        final songs = (state is AllSongsLoaded) ? state.songs : <SongModel>[];

        if (state is AllSongsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AllSongsError) {
          return Center(child: Text("Error: ${state.message}"));
        }

        final loaded = state as AllSongsLoaded;
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
                      "Total ${songs.length} Songs",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    DropdownButton<SongSortOption>(
                      focusColor: Colors.transparent,
                      dropdownColor: Theme.of(context)
                          .dropdownMenuTheme
                          .inputDecorationTheme
                          ?.fillColor,
                      value: cubit.currentSort,
                      borderRadius: BorderRadius.circular(15),
                      underline: const SizedBox.shrink(),
                      style: Theme.of(context).dropdownMenuTheme.textStyle,
                      onChanged: (value) {
                        if (value != null) cubit.changeSort(value);
                      },
                      items: const [
                        DropdownMenuItem(
                          value: SongSortOption.dateAdded,
                          child: Text("Date Added"),
                        ),
                        DropdownMenuItem(
                          value: SongSortOption.name,
                          child: Text("Name"),
                        ),
                        DropdownMenuItem(
                          value: SongSortOption.durationLargest,
                          child: Text("Duration ↑"),
                        ),
                        DropdownMenuItem(
                          value: SongSortOption.durationSmallest,
                          child: Text("Duration ↓"),
                        ),
                        DropdownMenuItem(
                          value: SongSortOption.fileSizeLargest,
                          child: Text("File Size ↑"),
                        ),
                        DropdownMenuItem(
                          value: SongSortOption.fileSizeSmallest,
                          child: Text("File Size ↓"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = songs[index];

                  return CustomSongTile(
                    isTrailingChange: loaded.isSelecting,
                    trailing: loaded.isSelecting
                        ? Checkbox(
                            value: loaded.selectedSongs.contains(song.data),
                            onChanged: (_) {
                              cubit.toggleSongSelection(song.data);
                            },
                          )
                        : null,
                    song: song,
                    onTap: () {
                      if (loaded.isSelecting) {
                        cubit.toggleSongSelection(song.data);
                      } else {
                        context.read<AudioBloc>().add(PlaySong(song, songs));
                      }
                    },
                  );
                },
                childCount: songs.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
