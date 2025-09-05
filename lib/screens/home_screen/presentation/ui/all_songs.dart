
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:moz_updated_version/screens/home_screen/presentation/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/ui/now_playing_screen.dart';
import 'package:moz_updated_version/widgets/song_list_tile.dart';

class SongView extends StatelessWidget {
  const SongView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (state is SongsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AudioError) {
          return Center(child: Text("Error: ${state.message}"));
        }
        if (state is SongsLoaded) {
          final songs = state.songs;
          final currentSong = state.currentSong;
          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 30),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                final isPlaying = currentSong?.id == song.id;
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: SlideAnimation(
                    duration: const Duration(milliseconds: 2500),
                    curve: Curves.fastLinearToSlowEaseIn,
                    child: FadeInAnimation(
                      duration: const Duration(milliseconds: 2500),
                      curve: Curves.fastLinearToSlowEaseIn,
                      child: CustomSongTile(
                        song: song,
                        disableOnTap: true,
                        onTap: () async {
                          context.read<AudioBloc>().add(PlaySong(song, songs));

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NowPlayingScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: Text("No songs found"));
      },
    );
  }
}
