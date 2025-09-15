import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/removed_screen/presentation/cubit/removed_cubit.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class RemovedSongsScreen extends StatelessWidget {
  const RemovedSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Removed Songs")),
      body: BlocBuilder<RemovedCubit, RemovedState>(
        builder: (context, state) {
          if (state is RemovedLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is RemovedError) {
            return Center(child: Text(state.message));
          }

          if (state is RemovedLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text("No removed songs yet"));
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total ${items.length} Removed Songs",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final song = items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: CustomSongTile(
                            song: song,
                            onTap: () {
                              context.read<AudioBloc>().add(
                                PlaySong(song, items),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
