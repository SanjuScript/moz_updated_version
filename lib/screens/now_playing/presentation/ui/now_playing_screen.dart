import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repo.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final repo = sl<AudioRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Now Playing",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AudioBloc, AudioState>(
        builder: (context, state) {
          if (state is AudioInitial || repo.currentPlaylist.isEmpty) {
            return const Center(child: Text("No songs playing"));
          }

          // Determine current song
          SongModel? currentSong;
          if (state is SongPlaying) {
            currentSong = state.currentSong;
          } else if (state is SongPaused) {
            currentSong = state.currentSong;
          }

          if (currentSong == null) {
            return const Center(child: Text("No songs playing"));
          }

          final songs = repo.currentPlaylist;
          _currentIndex = songs.indexOf(currentSong);

          if (_currentIndex == -1) _currentIndex = 0;

          return Column(
            children: [
              SizedBox(height: 20),
              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: songs.length,
                itemBuilder: (context, index, realIndex) {
                  final song = songs[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AudioArtWorkWidget(
                      id: int.tryParse(song.id.toString()) ?? 0,
                      size: 500,
                    ),
                  );
                },
                options: CarouselOptions(
                  aspectRatio: .9,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  viewportFraction: .9,
                  enlargeFactor: .5,
                  initialPage: _currentIndex,
                  onPageChanged: (index, reason) {
                    if (!mounted) return;

                    setState(() {
                      _currentIndex = index;
                    });

                    context.read<AudioBloc>().add(
                      PlaySong(songs[index], songs),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Song title
              Text(
                songs[_currentIndex].title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Artist
              Text(
                songs[_currentIndex].artist ?? "Unknown Artist",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 32),

              // Playback controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () {
                      context.read<AudioBloc>().add(PreviousSong());
                      _carouselController.animateToPage(_currentIndex - 1);
                    },
                  ),
                  const SizedBox(width: 32),
                  BlocBuilder<AudioBloc, AudioState>(
                    builder: (context, state) {
                      final isPlaying = state is SongPlaying;

                      return IconButton(
                        iconSize: 60,
                        icon: Icon(
                          isPlaying ? Icons.pause_circle : Icons.play_circle,
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            context.read<AudioBloc>().add(PauseSong());
                          } else if (state is SongPaused) {
                            context.read<AudioBloc>().add(ResumeSong());
                          } else {
                            // fallback play current song
                            context.read<AudioBloc>().add(
                              PlaySong(songs[_currentIndex], songs),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {
                      context.read<AudioBloc>().add(NextSong());
                      _carouselController.animateToPage(_currentIndex + 1);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
