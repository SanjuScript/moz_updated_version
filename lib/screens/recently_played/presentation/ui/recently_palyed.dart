import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/recently_played/presentation/cubit/recently_played_cubit.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:moz_updated_version/main.dart';

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
              return CustomSongTile(
                disableOnTap: true,
                song: song,
                onTap: () {
                  context.read<AudioBloc>().add(PlaySong(song, items));
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
