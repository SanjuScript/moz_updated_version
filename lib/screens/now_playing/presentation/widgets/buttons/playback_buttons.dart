import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/cubit/nowplaying_cubit.dart';

class PlaybackButtons extends StatelessWidget {
  const PlaybackButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<ArtworkColorCubit, ArtworkColorState>(
      builder: (context, colorState) {
        return Container(
          height: size.height * .10,
          width: size.width * .95,
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: colorState.isDarkTheme
                  ? [
                      const Color.fromARGB(255, 14, 14, 14),
                      const Color.fromARGB(255, 14, 14, 14),
                    ]
                  : [
                      Theme.of(context).primaryColor.withValues(alpha: 0.9),
                      Theme.of(context).primaryColor.withValues(alpha: 0.5),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: colorState.isDarkTheme
                ? []
                : [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.4),
                      offset: const Offset(-2, 4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
                      offset: const Offset(2, 6),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              IconButton(
                iconSize: 40,
                color: Theme.of(
                  context,
                ).buttonTheme.colorScheme!.inversePrimary,
                icon: Icon(Icons.skip_previous_rounded, color: Colors.white),
                onPressed: () {
                  context.read<NowPlayingCubit>().previous();
                },
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: .5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.5),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      blurStyle: BlurStyle.inner,
                    ),
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.4),
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                      blurStyle: BlurStyle.inner,
                    ),
                  ],
                ),
                child: Center(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 50,
                    color: Colors.white,
                    icon: StreamBuilder<bool>(
                      stream: audioHandler.isPlaying,
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.data != null) {
                          return Icon(
                            color: Colors.white,

                            asyncSnapshot.data!
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                          );
                        }
                        return SizedBox();
                      },
                    ),
                    onPressed: () {
                      context.read<NowPlayingCubit>().playPause();
                    },
                  ),
                ),
              ),
              IconButton(
                iconSize: 40,
                color: Theme.of(
                  context,
                ).buttonTheme.colorScheme!.inversePrimary,

                icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                onPressed: () {
                  context.read<NowPlayingCubit>().next();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
