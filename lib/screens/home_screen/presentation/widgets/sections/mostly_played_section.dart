import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/mostly_played/presentation/cubit/mostlyplayed_cubit.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class MostlyPlayedSection extends StatelessWidget {
  const MostlyPlayedSection({super.key});
  final int itemsPerView = 3;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MostlyPlayedCubit, MostlyplayedState>(
      builder: (context, state) {
        log('MostlyPlayedSection rebuild: ${Theme.of(context).brightness}');

        if (state is MostlyPlayedLoaded && state.items.isNotEmpty) {
          final _mostlyPlayedSongs = state.items;

          double ht = MediaQuery.sizeOf(context).height * 0.30;
          double adjustedHeight = (_mostlyPlayedSongs.length == 1)
              ? ht / 3
              : (_mostlyPlayedSongs.length == 2)
              ? ht / 1.5
              : ht;

          return SizedBox(
            height: adjustedHeight,
            child: PageView.builder(
              controller: PageController(viewportFraction: 1.0),
              physics: const PageScrollPhysics(),
              itemCount: (_mostlyPlayedSongs.length / itemsPerView).ceil(),
              itemBuilder: (context, pageIndex) {
                int startIndex = pageIndex * itemsPerView;
                int endIndex = (pageIndex + 1) * itemsPerView;
                if (endIndex > _mostlyPlayedSongs.length) {
                  endIndex = _mostlyPlayedSongs.length;
                }

                final pageItems = _mostlyPlayedSongs.sublist(
                  startIndex,
                  endIndex,
                );

                return AnimationLimiter(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    itemCount: pageItems.length,
                    itemBuilder: (context, listIndex) {
                      final song = pageItems[listIndex];
                      final playCount = (song.getMap["playCount"] ?? 0) as int;

                      return AnimationConfiguration.staggeredList(
                        position: listIndex,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          horizontalOffset: 50,
                          curve: Curves.easeOutCubic,
                          child: FadeInAnimation(
                            curve: Curves.easeIn,
                            child: CustomSongTile(
                              key: ValueKey(song.data),
                              isTrailingChange: true,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    playCount.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                  ),
                                  Text(
                                    "Played",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          shadows: const [
                                            BoxShadow(
                                              color: Color.fromARGB(
                                                34,
                                                107,
                                                107,
                                                107,
                                              ),
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
                                context.read<AudioBloc>().add(
                                  PlaySong(song, _mostlyPlayedSongs),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
