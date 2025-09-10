import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/cubit/nowplaying_cubit.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/buttons/playback_buttons.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/buttons/player_controls.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/moz_slider.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/text_boxes.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/main.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with AutomaticKeepAliveClientMixin {
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
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_rounded)),
        ],
      ),
      body: BlocBuilder<NowPlayingCubit, NowPlayingState>(
        builder: (context, state) {
          if (state.currentSong == null) {
            return const Center(child: Text("No song playing"));
          }

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

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                        child: ClipRRect(
                          key: ValueKey(state.currentSong?.id),
                          borderRadius: BorderRadius.circular(16),
                          child: AudioArtWorkWidget(
                            id: int.tryParse(state.currentSong?.id ?? "0"),
                            size: 500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextBoxesWidgets(song: state.currentSong!),
                    ),
                    const SizedBox(height: 20),

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
                    PlaybackButtons(),
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
