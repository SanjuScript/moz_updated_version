import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/helper/get_date.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/cubit/allsongs_cubit.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';

class LastAddedSection extends StatelessWidget {
  const LastAddedSection({super.key});
  final int itemsPerView = 3;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllSongsCubit, AllsongsState>(
      builder: (context, state) {
        if (state is AllSongsLoaded && state.songs.isNotEmpty) {
          final lastAddedSongs =
              (state.songs
                    ..sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!)))
                  .take(15)
                  .toList();

          final allSongs = (state.songs
            ..sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!)));

          double ht = MediaQuery.sizeOf(context).height * 0.30;
          double adjustedHeight = (lastAddedSongs.length == 1)
              ? ht / 3
              : (lastAddedSongs.length == 2)
              ? ht / 1.5
              : ht;

          return SizedBox(
            height: adjustedHeight,
            child: PageView.builder(
              pageSnapping: false,
              controller: PageController(viewportFraction: .9),
              padEnds: false,
              physics: const BouncingScrollPhysics(),
              itemCount: (lastAddedSongs.length / itemsPerView).ceil(),
              itemBuilder: (context, pageIndex) {
                int startIndex = pageIndex * itemsPerView;
                int endIndex = (pageIndex + 1) * itemsPerView;
                if (endIndex > lastAddedSongs.length) {
                  endIndex = lastAddedSongs.length;
                }

                final pageItems = lastAddedSongs.sublist(startIndex, endIndex);

                return AnimationLimiter(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    itemCount: pageItems.length,
                    itemBuilder: (context, listIndex) {
                      final song = pageItems[listIndex];
                      return FutureBuilder<String>(
                        future: getTimeAgoFromPath(song.data),
                        builder: (context, snapshot) {
                          final timeAgo = snapshot.data ?? "Unknown";

                          return AnimationConfiguration.staggeredList(
                            position: listIndex,
                            duration: const Duration(milliseconds: 400),
                            child: SlideAnimation(
                              horizontalOffset: 50,
                              curve: Curves.easeOutCubic,
                              child: FadeInAnimation(
                                curve: Curves.easeIn,
                                child: CustomSongTile(
                                  isTrailingChange: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        timeAgo,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                      ),
                                      Text(
                                        "Ago",
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
                                      PlaySong(song, allSongs),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
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
