import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/ui/now_playing_screen.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/ui/page_view.dart';
import 'package:moz_updated_version/services/helpers/get_media_state.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import '../../../../services/core/app_services.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == "dark";

        return StreamBuilder<MediaState>(
          stream: audioHandler.mediaState$,
          builder: (context, snapshot) {
            final state = snapshot.data;

            if (state == null || state.mediaItem == null) {
              return const SizedBox();
            }

            final mediaItem = state.mediaItem!;
            final isPlaying = state.isPlaying;

            return InkWell(
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              onTap: () => sl<NavigationService>().navigateTo(
                animation: NavigationAnimation.up,
                // const NowPlayingScreen(),
                NowplayingPageView(),
              ),
              child: LiquidGlassLayer(
                settings: LiquidGlassSettings(
                  thickness: 30,
                  chromaticAberration: .03,
                  glassColor: isDark
                      ? const Color.fromARGB(0, 255, 255, 255)
                      : Colors.grey.shade100.withValues(alpha: 0.5),
                ),
                child: SizedBox(
                  height: 90,
                  child: LiquidStretch(
                    stretch: .4,
                    interactionScale: 1.01,
                    child: LiquidGlass(
                      shape: LiquidRoundedSuperellipse(borderRadius: 18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AudioArtWorkWidget(
                                  id: mediaItem.extras?["isOnline"] == true
                                      ? null
                                      : int.parse(mediaItem.id),
                                  isOnline:
                                      mediaItem.extras?["isOnline"] == true,
                                  imageUrl: mediaItem.artUri.toString(),
                                  iconSize: 30,
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mediaItem.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mediaItem.artist ?? "Unknown Artist",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(letterSpacing: .3),
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                _buildControlButton(
                                  icon: Icons.skip_previous_rounded,
                                  onTap: () => audioHandler.skipToPrevious(),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 8),
                                _buildControlButton(
                                  icon: isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  onTap: () => isPlaying
                                      ? audioHandler.pause()
                                      : audioHandler.play(),
                                  isMain: true,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 8),
                                _buildControlButton(
                                  icon: Icons.skip_next_rounded,
                                  onTap: () => audioHandler.skipToNext(),
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isMain = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.all(isMain ? 12 : 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withValues(alpha: isMain ? 0.2 : 0.1)
              : Colors.black.withValues(alpha: isMain ? 0.1 : 0.05),
          boxShadow: isMain
              ? [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: isMain ? 28 : 22,
        ),
      ),
    );
  }
}
