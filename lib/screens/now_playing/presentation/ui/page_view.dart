import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/ui/now_playing_screen.dart';

class NowplayingPageView extends StatelessWidget {
  const NowplayingPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ArtworkColorCubit, ArtworkColorState>(
        builder: (context, colorState) {
          final themeState = context.watch<ThemeCubit>();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.2, 0.8],
                colors: [
                  themeState.isDark
                      ? colorState.dominantColor
                      : Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: PageView(
              scrollDirection: Axis.vertical,
              children: const [
                NowPlayingScreen(),
                Center(child: Text("Page 3")),
              ],
            ),
          );
        },
      ),
    );
  }
}
