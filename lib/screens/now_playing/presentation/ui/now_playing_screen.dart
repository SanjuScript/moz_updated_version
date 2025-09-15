import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/cubit/nowplaying_cubit.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/buttons/more_options.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/buttons/playback_buttons.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/buttons/player_controls.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/moz_slider.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/sheets/quee_sheet.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/text_boxes.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/widgets/buttons/platform_button.dart';

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
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < -100) {
          showCurrentQueueSheet(context);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("Now Playing"),
          centerTitle: true,
          leading: PlatformButton(
            isIos: sl<ThemeCubit>().isIos,
            materialIcon: Icons.arrow_back,
            cupertinoIcon: CupertinoIcons.back,
            color: Theme.of(context).textTheme.titleLarge!.color!,
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.transparent,
          actions: [CurrentSongOptionsMenu()],
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
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeOut,
                          child: ClipRRect(
                            key: ValueKey(state.currentSong?.id),
                            borderRadius: BorderRadius.circular(16),
                            child: AudioArtWorkWidget(
                              id: int.tryParse(state.currentSong?.id ?? "0"),
                              size: 500,
                            ),
                          ),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
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
                                milliseconds:
                                    (dur.inMilliseconds * relativeValue)
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
