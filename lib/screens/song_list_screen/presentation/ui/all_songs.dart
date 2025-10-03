import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/widgets/custom_menu/custom_dropdown.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AllSongScreen extends StatelessWidget {
  const AllSongScreen({super.key});

  String sortLabel(SongSortOption option) {
    switch (option) {
      case SongSortOption.dateAdded:
        return "Date Added";
      case SongSortOption.name:
        return "Name";
      case SongSortOption.durationLargest:
        return "Duration ↑";
      case SongSortOption.durationSmallest:
        return "Duration ↓";
      case SongSortOption.fileSizeLargest:
        return "File Size ↑";
      case SongSortOption.fileSizeSmallest:
        return "File Size ↓";
    }
  }

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
                    PremiumDropdown<SongSortOption>(
                      items: const [
                        SongSortOption.dateAdded,
                        SongSortOption.name,
                        SongSortOption.durationLargest,
                        SongSortOption.durationSmallest,
                        SongSortOption.fileSizeLargest,
                        SongSortOption.fileSizeSmallest,
                      ],
                      initialValue: cubit.currentSort,
                      hint: const Text("Sort By"),
                      width: 160,
                      labelBuilder: (option) {
                        switch (option) {
                          case SongSortOption.dateAdded:
                            return "Date Added";
                          case SongSortOption.name:
                            return "Name";
                          case SongSortOption.durationLargest:
                            return "Duration ↑";
                          case SongSortOption.durationSmallest:
                            return "Duration ↓";
                          case SongSortOption.fileSizeLargest:
                            return "File Size ↑";
                          case SongSortOption.fileSizeSmallest:
                            return "File Size ↓";
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
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
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
              }, childCount: songs.length),
            ),
          ],
        );
      },
    );
  }
}
