import 'dart:typed_data';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:palette_generator/palette_generator.dart';

part 'artworkcolorextractor_state.dart';

class ArtworkColorCubit extends Cubit<ArtworkColorState> {
  ArtworkColorCubit() : super(const ArtworkColorState.initial());

  Future<void> extractArtworkColors(int id) async {
    final theme = sl<ThemeCubit>();
    final artworkData = await getSongArtwork(id);

    if (artworkData == null) {
      emit(
        state.copyWith(
          ogDominantColor: theme.isDark
              ? const Color.fromARGB(255, 24, 24, 24)
              : Colors.white,
          dominantColor: theme.isDark
              ? Colors.black
              : Colors.grey.withValues(alpha: 0.5),
          imageColors: [Colors.black, Colors.black],
        ),
      );
      return;
    }

    final palette = await PaletteGenerator.fromImageProvider(
      MemoryImage(artworkData),
      size: const Size(500, 500),
      maximumColorCount: 20,
    );

    final dominantColor = palette.dominantColor?.color;
    final colors = palette.colors.toList();

    if (dominantColor != null) {
      double luminance = dominantColor.computeLuminance();
      double opacity = luminance > 0.5 ? 0.2 : 0.8;
      emit(
        state.copyWith(
          ogDominantColor: dominantColor,
          dominantColor: theme.isDark
              ? dominantColor.withValues(alpha: opacity)
              : Colors.white,
          imageColors: colors,
        ),
      );
    } else {
      emit(
        state.copyWith(
          ogDominantColor: theme.isDark
              ? const Color.fromARGB(255, 24, 24, 24)
              : Colors.white,
          dominantColor: theme.isDark ? Colors.black : Colors.white,
          imageColors: colors,
        ),
      );
    }
  }

  Future<void> extractImageColors(List<Uint8List?> imageList) async {
    List<Color> colors = [];
    for (Uint8List? imageData in imageList) {
      if (imageData != null) {
        final palette = await PaletteGenerator.fromImageProvider(
          MemoryImage(imageData),
          size: const Size(250, 250),
          maximumColorCount: 20,
        );
        colors.addAll(palette.colors);
      }
    }
    emit(state.copyWith(imageColors: colors));
  }

  Color get dominantColor => state.dominantColor;

  List<Color> get imageColors => state.imageColors;

  bool get isDarkTheme => sl<ThemeCubit>().isDark;
}
