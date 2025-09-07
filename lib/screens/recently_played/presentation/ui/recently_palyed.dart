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

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final song = items[index];
              log(song.getMap.toString());
              return CustomSongTile(
                disableOnTap: true,
                isTrailingChange: true,
                trailing: Text(
                  TimeHelper.timeAgo(song.getMap["playedAt"] ?? 0),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                song: song,
                onTap: () {
                  context.read<AudioBloc>().add(PlaySong(song, items));
                  // context.read<RecentlyPlayedCubit>().clear();
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
