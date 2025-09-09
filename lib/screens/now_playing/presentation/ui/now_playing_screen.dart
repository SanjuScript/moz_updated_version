import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/cubit/nowplaying_cubit.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/buttons/player_controls.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/moz_slider.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/main.dart'; // audioHandler

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with AutomaticKeepAliveClientMixin {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text("Now Playing"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<NowPlayingCubit, NowPlayingState>(
        builder: (context, state) {
          if (state.currentSong == null) {
            return const Center(child: Text("No song playing"));
          }

          final queue = state.queue;
          final index = state.currentIndex;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_carouselController.ready && index >= 0) {
              _carouselController.animateToPage(index);
            }
          });

          return BlocBuilder<ArtworkColorCubit, ArtworkColorState>(
            builder: (context, colorState) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 400),
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [.2, .8],
                    colors: [
                      colorState.dominantColor,
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 100),

                    CarouselSlider.builder(
                      carouselController: _carouselController,
                      itemCount: queue.length,
                      itemBuilder: (context, i, realIndex) {
                        final song = queue[i];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AudioArtWorkWidget(
                            id: int.parse(song.id),
                            size: 500,
                          ),
                        );
                      },
                      options: CarouselOptions(
                        aspectRatio: .9,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        viewportFraction: .85,
                        initialPage: index,
                        onPageChanged: (i, reason) {
                          if (i != state.currentIndex) {
                            context.read<NowPlayingCubit>().skipToIndex(i);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      state.currentSong?.title ?? "Unknown",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // 👤 Artist
                    Text(
                      state.currentSong?.artist ?? "Unknown Artist",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ⏳ Slider (position only rebuilds here)
                    StreamBuilder<Duration>(
                      stream: audioHandler.positionStream,
                      builder: (context, snapshot) {
                        final pos = snapshot.data ?? Duration.zero;
                        final dur =
                            state.currentSong?.duration ?? Duration.zero;
                        return MozSlider(
                          currentPosition: pos,
                          totalDuration: dur,
                          sliderColor: Theme.of(context).colorScheme.primary,
                          thumbColor: Colors.white,
                          backgroundColor: Colors.grey.shade400,
                          onChanged: (relativeValue) {
                            final newPos = Duration(
                              milliseconds: (dur.inMilliseconds * relativeValue)
                                  .toInt(),
                            );
                            log("Seek to: $newPos");
                            context.read<AudioBloc>().add(SeekSong(newPos));
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 10),
                    PlayerControls(),
                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 40,
                          icon: const Icon(Icons.skip_previous),
                          onPressed: () {
                            context.read<NowPlayingCubit>().previous();
                          },
                        ),
                        IconButton(
                          iconSize: 60,
                          icon: Icon(
                            state.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                          ),
                          onPressed: () {
                            context.read<NowPlayingCubit>().playPause();
                          },
                        ),
                        IconButton(
                          iconSize: 40,
                          icon: const Icon(Icons.skip_next),
                          onPressed: () {
                            context.read<NowPlayingCubit>().next();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
