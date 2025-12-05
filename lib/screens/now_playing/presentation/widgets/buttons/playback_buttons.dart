import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/cubit/nowplaying_cubit.dart';
import 'package:vector_math/vector_math_64.dart' as vect;

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
              InkWell(
                onTap: () {
                  context.read<NowPlayingCubit>().previous();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    color: Theme.of(
                      context,
                    ).buttonTheme.colorScheme!.inversePrimary,
                    height: 16,
                    width: 16,
                    "assets/icons/previous.svg",
                  ),
                ),
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
              InkWell(
                onTap: () {
                  context.read<NowPlayingCubit>().next();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..scaleByVector3(vect.Vector3(-1.0, 1.0, 1.0)),
                    child: SvgPicture.asset(
                      color: Theme.of(
                        context,
                      ).buttonTheme.colorScheme!.inversePrimary,
                      height: 16,
                      width: 16,
                      "assets/icons/previous.svg",
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
