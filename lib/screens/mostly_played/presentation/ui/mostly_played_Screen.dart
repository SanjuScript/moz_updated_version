import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/cubit/mostlyplayed_cubit.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/widget/new_tile.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MostlyPlayedScreen extends StatelessWidget {
  const MostlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MostlyPlayedCubit, MostlyplayedState>(
      builder: (context, state) {
        if (state is MostlyPlayedLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state is MostlyPlayedError) {
          return Center(child: Text(state.message));
        }

        if (state is MostlyPlayedLoaded) {
          final items = state.items;
          if (items.isEmpty) {
            return const Center(child: Text("No mostly played songs"));
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
                        "Total ${items.length} Mostly Played",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      BlocBuilder<MostlyPlayedCubit, MostlyplayedState>(
                        builder: (context, state) {
                          final cubit = context.read<MostlyPlayedCubit>();
                          return IconButton(
                            onPressed: () {
                              cubit.toggleSort();
                            },
                            icon: Icon(
                              cubit.sortType == MostlyPlayedSortType.playCount
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            tooltip: "Sort",
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = items[index];
                  final playCount = (song.getMap["playCount"] ?? 0) as int;

                  final playedMs = (song.getMap["playedDuration"] ?? 0) as int;
                  final playedDuration = Duration(milliseconds: playedMs);

                  return MostlyPlayedSongTile(
                    song: song,
                    playCount: playCount,
                    playedDuration: playedDuration,
                    allSongs: items,
                    onTap: () {
                      context.read<AudioBloc>().add(PlaySong(song, items));
                    },
                  );
                }, childCount: items.length),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
