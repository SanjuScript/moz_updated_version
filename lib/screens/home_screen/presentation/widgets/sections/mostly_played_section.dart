import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset(0.0, 0.0);
                        var offsetAnimation = Tween(
                          begin: begin,
                          end: end,
                        ).animate(animation);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                  child: SizedBox(
                    key: ValueKey<int>(_mostlyPlayedSongs.length),
                    child: ListView.builder(
                      
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      itemCount: endIndex - startIndex,
                      itemBuilder: (context, listIndex) {
                        int crtIndex = startIndex + listIndex;
                        final song = _mostlyPlayedSongs[crtIndex];
                        final playCount =
                            (song.getMap["playCount"] ?? 0) as int;

                        return CustomSongTile(
                          isTrailingChange: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                playCount.toString(),
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                              ),
                              Text(
                                "Played",
                                style: Theme.of(context).textTheme.titleSmall
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
                        );
                      },
                    ),
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
