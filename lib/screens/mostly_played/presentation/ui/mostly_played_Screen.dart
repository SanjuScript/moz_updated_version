import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/cubit/mostlyplayed_cubit.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class MostlyPlayedScreen extends StatelessWidget {
  const MostlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MostlyPlayedCubit, MostlyplayedState>(
      builder: (context, state) {
        if (state is MostlyPlayedLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MostlyPlayedError) {
          return Center(child: Text(state.message));
        }

        if (state is MostlyPlayedLoaded) {
          final items = state.items;
          if (items.isEmpty) {
            return const Center(child: Text("No mostly played songs"));
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final song = items[index];
              final playCount = (song.getMap["playCount"] ?? 0) as int;
              return CustomSongTile(
                isTrailingChange: true,
                trailing: Column(
                  children: [
                    Text(
                      playCount.toString(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      "Played",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,

                        shadows: const [
                          BoxShadow(
                            color: Color.fromARGB(34, 107, 107, 107),
                            blurRadius: 15,
                            offset: Offset(-2, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
