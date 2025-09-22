import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          final _lastAddedSongs =
              (state.songs
                    ..sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!)))
                  .take(15)
                  .toList();

          final allSongs = (state.songs
            ..sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!)));

          double ht = MediaQuery.sizeOf(context).height * 0.30;
          double adjustedHeight = (_lastAddedSongs.length == 1)
              ? ht / 3
              : (_lastAddedSongs.length == 2)
              ? ht / 1.5
              : ht;

          return SizedBox(
            height: adjustedHeight,
            child: PageView.builder(
              controller: PageController(viewportFraction: 1),
              physics: const PageScrollPhysics(),
              itemCount: (_lastAddedSongs.length / itemsPerView).ceil(),
              itemBuilder: (context, pageIndex) {
                int startIndex = pageIndex * itemsPerView;
                int endIndex = (pageIndex + 1) * itemsPerView;
                if (endIndex > _lastAddedSongs.length)
                  endIndex = _lastAddedSongs.length;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        var offsetAnimation = Tween(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(animation);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                  child: SizedBox(
                    key: ValueKey<int>(_lastAddedSongs.length),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      itemCount: endIndex - startIndex,
                      itemBuilder: (context, listIndex) {
                        int crtIndex = startIndex + listIndex;
                        final song = _lastAddedSongs[crtIndex];

                        return FutureBuilder<String>(
                          future: getTimeAgoFromPath(song.data),
                          builder: (context, snapshot) {
                            final timeAgo = snapshot.data ?? "Unknown";

                            return CustomSongTile(
                              isTrailingChange: true,

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
