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
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/recommendations_popup_overlay.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/text_boxes.dart';
import 'package:audio_service/audio_service.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/services/one_time_dialogue_service.dart';
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
  // State to handle the animation toggle
  bool _isMiniPlayer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OneTimeDialog.show(
        context: context,
        dialogId: DialogIds.nowPlayingTips,
        content: DialogContents.nowPlayingTips,
      );
    });
  }

  void _toggleAnimation() {
    setState(() {
      _isMiniPlayer = !_isMiniPlayer;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.sizeOf(context);
    final bool isDesktop = size.width > 900;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!isDesktop) {
          if (_isMiniPlayer) {
            _toggleAnimation();
          } else {
            Navigator.pop(context);
          }
        }
      },
      child: BlocBuilder<NowPlayingCubit, NowPlayingState>(
        builder: (context, state) {
          if (state.currentSong == null) {
            return const Scaffold(body: Center(child: Text("No song playing")));
          }

          if (isDesktop) {
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: const Text("Now Playing"),
                centerTitle: true,
                leading: _buildBackButton(context),
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    onPressed: () => showCurrentQueueSheet(context),
                    icon: const Icon(Icons.queue_music),
                  ),
                  const CurrentSongOptionsMenu(),
                ],
              ),
              backgroundColor: Colors.transparent,
              body: _buildDesktopLayout(context, state),
            );
          } else {
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: null,
              backgroundColor: Colors.transparent,
              body: _buildMobileAnimatedLayout(context, state),
            );
          }
        },
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return PlatformButton(
      isIos: sl<ThemeCubit>().isIos,
      materialIcon: Icons.arrow_back,
      cupertinoIcon: CupertinoIcons.back,
      color: Theme.of(context).textTheme.titleLarge!.color!,
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, NowPlayingState state) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    if (state.currentSong == null) {
      return const Center(child: Text('No song playing'));
    }

    final song = state.currentSong!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: size.width * 0.30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: size.width * 0.28,
                  height: size.height * .55,
                  child: AudioArtWorkWidget(
                    radius: 10,
                    id: int.tryParse(song.id),
                    imageUrl: song.artUri?.toString(),
                    artworkPath: song.extras?['artworkPath'],
                    isDownloaded: song.extras?['is_downloaded'] == true,
                    isOnline: song.extras?['isOnline'] == true,
                    size: 500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: RecommendationsOverlayWrapper(
                    song: state.currentSong!,
                  ),
                ),
                const SizedBox(height: 10),
                _buildQualityTag(
                  context,
                  song,
                  alignment: Alignment.centerLeft,
                  showLyricsButton: false,
                ),
                const SizedBox(height: 30),

                PlayerControls(),
              ],
            ),
          ),

          const SizedBox(width: 32),

          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: LyricsScreen(
                      artist: song.artist ?? '',
                      title: song.title,
                      songId: song.id,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Column(
                  children: [
                    StreamBuilder<Duration>(
                      stream: audioHandler.positionStream,
                      builder: (context, snapshot) {
                        final pos = snapshot.data ?? Duration.zero;
                        final dur = song.duration ?? Duration.zero;

                        return MozSlider(
                          currentPosition: pos,
                          totalDuration: dur,
                          sliderColor: theme.colorScheme.primary,
                          thumbColor: Colors.white,
                          backgroundColor: Colors.grey.shade400,
                          onChanged: (relative) {
                            final newPos = Duration(
                              milliseconds: (dur.inMilliseconds * relative)
                                  .toInt(),
                            );
                            context.read<AudioBloc>().add(SeekSong(newPos));
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    PlaybackButtons(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAnimatedLayout(
    BuildContext context,
    NowPlayingState state,
  ) {
    final size = MediaQuery.sizeOf(context);
    final paddingTop = MediaQuery.of(context).padding.top;
    final song = state.currentSong!;

    // "Big" Artwork position (Body)
    final double bigSize = size.width - 25;
    final double bigTop = size.height * 0.13;
    final double bigLeft = 10.0;

    //  "Small" Artwork position (AppBar)
    final double smallSize = 45.0;
    final double smallTop = paddingTop + 5;
    final double smallLeft = 55.0;

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.13),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AnimatedContainer(
                    height: _isMiniPlayer ? bigSize + 100 : bigSize + 10,
                    width: bigSize,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      opacity: _isMiniPlayer ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: LyricsScreen(
                          artist: state.currentSong!.artist!,
                          title: state.currentSong!.title,
                          songId: state.currentSong!.id,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * .05),

                AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    height: _isMiniPlayer ? 0 : null,
                    child: AnimatedOpacity(
                      opacity: _isMiniPlayer ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextBoxesWidgets(song: song),
                      ),
                    ),
                  ),
                ),
                if (!_isMiniPlayer) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: _buildQualityTag(
                      context,
                      song,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ],
                SizedBox(height: size.height * .01),

                _buildSlider(context, song),

                SizedBox(height: size.height * .0035),

                PlayerControls(),

                SizedBox(height: size.height * .02),

                PlaybackButtons(),

                SizedBox(height: size.height * 0.1),
              ],
            ),
          ),
        ),

        Positioned(
          top: -7,
          left: 0,
          right: 0,
          height: paddingTop + kToolbarHeight,
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(top: paddingTop),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 50, child: _buildBackButton(context)),

                Expanded(
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 400),
                    padding: EdgeInsets.only(left: _isMiniPlayer ? 60.0 : 0.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _isMiniPlayer
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: ListTile(
                                key: const ValueKey('mini_title'),
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                subtitle: Text(
                                  song.artist ?? "Unknown",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                "Now Playing",
                                maxLines: 1,
                                key: const ValueKey('big_title'),
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(fontSize: 20),
                              ),
                            ),
                    ),
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => showCurrentQueueSheet(context),
                      icon: const Icon(Icons.queue_music),
                    ),
                    const CurrentSongOptionsMenu(),
                  ],
                ),
              ],
            ),
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubicEmphasized,
          top: _isMiniPlayer ? smallTop : bigTop,
          left: _isMiniPlayer ? smallLeft : bigLeft,
          width: _isMiniPlayer ? smallSize : bigSize,
          height: _isMiniPlayer ? smallSize : bigSize + 20,
          child: GestureDetector(
            onTap: _toggleAnimation,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(_isMiniPlayer ? 8 : 16),
              clipBehavior: Clip.antiAlias,
              child: AudioArtWorkWidget(
                isDownloaded: song.extras?["is_downloaded"] == true,
                artworkPath: song.extras?["artworkPath"],
                key: ValueKey(song.id),
                id: int.tryParse(song.id),
                imageUrl: song.artUri?.toString(),
                isOnline: song.extras?["isOnline"] == true,
                size: 500,
              ),
            ),
          ),
        ),
        if (!_isMiniPlayer)
          Positioned(
            left: 20,
            right: 20,
            bottom: size.height - (bigTop + bigSize + size.height * 0.05 + 5),
            child: RecommendationsPopupOverlay(song: song),
          ),
      ],
    );
  }

  Widget _buildQualityTag(
    BuildContext context,
    MediaItem song, {
    Alignment alignment = Alignment.center,
    bool showLyricsButton = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final extras = song.extras ?? {};
    final isOnline = extras['isOnline'] == true || int.tryParse(song.id) == null;

    String tagText = "HQ Audio";
    if (isOnline) {
      tagText = "AAC 320K";
    } else {
      final ext = (extras['fileExtension'] ?? song.id.split('.').last).toString().toLowerCase();
      if (ext == 'flac' || ext == 'wav' || ext == 'alac') {
        tagText = "LOSSLESS";
      } else {
        tagText = ext.toUpperCase();
      }
    }

    return Align(
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(25),
                width: 0.8,
              ),
            ),
            child: Text(
              tagText,
              style: TextStyle(
                fontSize: 8.0,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
                letterSpacing: 1.0,
              ),
            ),
          ),
          if (showLyricsButton) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _toggleAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(25),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lyrics_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                      size: 9,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "LYRICS",
                      style: TextStyle(
                        fontSize: 8.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black54,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSlider(BuildContext context, dynamic song) {
    final theme = Theme.of(context);
    return StreamBuilder<Duration>(
      stream: audioHandler.positionStream,
      builder: (context, snapshot) {
        final pos = snapshot.data ?? Duration.zero;
        final dur = song.duration ?? Duration.zero;
        return MozSlider(
          currentPosition: pos,
          totalDuration: dur,
          sliderColor: theme.colorScheme.primary,
          thumbColor: Colors.white,
          backgroundColor: Colors.grey.shade400,
          onChanged: (relativeValue) {
            final newPos = Duration(
              milliseconds: (dur.inMilliseconds * relativeValue).toInt(),
            );
            context.read<AudioBloc>().add(SeekSong(newPos));
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
