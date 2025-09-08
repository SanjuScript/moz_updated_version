import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/time_helper.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/recently_played/presentation/cubit/recently_played_cubit.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class RecentlyPlayedScreen extends StatelessWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecentlyPlayedCubit, RecentlyPlayedState>(
      builder: (context, state) {
        if (state is RecentlyPlayedLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RecentlyPlayedError) {
          return Center(child: Text(state.message));
        }

        if (state is RecentlyPlayedLoaded) {
          final items = state.items;
          if (items.isEmpty) {
            return const Center(child: Text("No recently played"));
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
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
                        "Total ${items.length} Songs",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      IconButton(
                        icon: Icon(
                          context.read<RecentlyPlayedCubit>().currentSort ==
                                  RecentlySortOption.lastPlayedAsc
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                        ),
                        tooltip: "Toggle Sort",
                        onPressed: () {
                          context.read<RecentlyPlayedCubit>().toggleSort();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = items[index];
                  log(song.getMap.toString());
                  return CustomSongTile(
                    isTrailingChange: true,
                    trailing: Text(
                      TimeHelper.timeAgo(song.getMap["playedAt"] ?? 0),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    song: song,
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
