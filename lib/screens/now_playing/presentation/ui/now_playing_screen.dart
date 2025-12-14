import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/core/utils/bloc/audio_bloc.dart';
import 'package:moz_updated_version/screens/lyric_screen/presentation/ui/lyric_screen.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/cubit/nowplaying_cubit.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/buttons/more_options.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/buttons/playback_buttons.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/buttons/player_controls.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/moz_slider.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/sheets/quee_sheet.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/text_boxes.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/widgets/buttons/platform_button.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
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
        actions: [
          IconButton(
            onPressed: () {
              showCurrentQueueSheet(context);
            },
            icon: Icon(Icons.queue_music),
          ),
          CurrentSongOptionsMenu(),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: BlocBuilder<NowPlayingCubit, NowPlayingState>(
        builder: (context, state) {
          if (state.currentSong == null) {
            return const Center(child: Text("No song playing"));
          }

          return Column(
            children: [
              SizedBox(height: size.height * .13),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: ClipRRect(
                    key: ValueKey(state.currentSong?.id),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () async {
                        log(state.currentSong!.id);
                        sl<NavigationService>().navigateTo(
                          LyricsScreen(
                            artist: state.currentSong!.artist.toString(),
                            title: state.currentSong!.title,
                            songId: state.currentSong!.id,
                          ),
                        );
                      },
                      child: AudioArtWorkWidget(
                        key: ValueKey(state.currentSong?.id ?? "0"),
                        id: int.tryParse(state.currentSong?.id ?? "0"),
                        imageUrl: state.currentSong?.artUri.toString(),
                        isOnline:
                            state.currentSong?.extras!["isOnline"] == true,
                        size: 500,
                      ),
                    ),
                  ),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ),

              SizedBox(height: size.height * .02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextBoxesWidgets(song: state.currentSong!),
              ),
              SizedBox(height: size.height * .02),

              StreamBuilder<Duration>(
                stream: audioHandler.positionStream,
                builder: (context, snapshot) {
                  final pos = snapshot.data ?? Duration.zero;
                  final dur = state.currentSong?.duration ?? Duration.zero;
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

              SizedBox(height: size.height * .0035),
              PlayerControls(),
              SizedBox(height: size.height * .02),
              PlaybackButtons(),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
