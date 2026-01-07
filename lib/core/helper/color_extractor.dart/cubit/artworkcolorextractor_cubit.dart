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
  ArtworkColorCubit() : super(const ArtworkColorState.initial()) {
    sl<ThemeCubit>().stream.listen((themeState) {
      _updateForTheme(themeState.isDark);
    });
  }

  void _updateForTheme(bool isDark) {
    emit(
      state.copyWith(
        dominantColor: isDark
            ? state.ogDominantColor.withValues(alpha: 0.8)
            : Colors.white,
      ),
    );
  }

  /// Extract artwork colors from either network or local storage
  ///
  /// [id] - The song/artwork ID
  /// [isOnline] - If true, extracts from network URL, otherwise from local storage
  /// [networkUrl] - Optional network URL (required if isOnline is true)
  Future<void> extractArtworkColors(
    int? id, {
    bool isOnline = false,
    String? networkUrl,
  }) async {
    final theme = sl<ThemeCubit>();

    // Validate network URL if online mode
    if (isOnline && (networkUrl == null || networkUrl.isEmpty)) {
      _emitDefaultColors(theme.isDark);
      return;
    }

    try {
      PaletteGenerator palette;

      if (isOnline) {
        // Extract colors from network image
        palette = await PaletteGenerator.fromImageProvider(
          NetworkImage(networkUrl!),
          size: const Size(500, 500),
          maximumColorCount: 20,
        );
      } else {
        // Extract colors from local artwork
        final artworkData = await getSongArtwork(id!);

        if (artworkData == null) {
          _emitDefaultColors(theme.isDark);
          return;
        }

        palette = await PaletteGenerator.fromImageProvider(
          MemoryImage(artworkData),
          size: const Size(500, 500),
          maximumColorCount: 20,
        );
      }

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
        _emitDefaultColors(theme.isDark, colors: colors);
      }
    } catch (e) {
      // Handle errors (network issues, invalid URLs, etc.)
      debugPrint('Error extracting artwork colors: $e');
      _emitDefaultColors(theme.isDark);
    }
  }

  //For extracting color form album artwork(online)
  Future<void> extractAlbumArtworkColors(String imageUrl) async {
    final isDark = sl<ThemeCubit>().isDark;

    if (imageUrl.isEmpty) {
      _emitAlbumDefaults(isDark);
      return;
    }

    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        size: const Size(500, 500),
        maximumColorCount: 20,
      );

      _emitAlbumPalette(palette, isDark);
    } catch (e) {
      debugPrint('Album artwork color error: $e');
      _emitAlbumDefaults(isDark);
    }
  }

  void _emitAlbumPalette(PaletteGenerator palette, bool isDark) {
    final dominant = palette.dominantColor?.color;
    final colors = palette.colors.toList();

    if (dominant == null) {
      _emitAlbumDefaults(isDark);
      return;
    }

    emit(
      state.copyWith(
        albumOgDominantColor: dominant,
        albumDominantColor: isDark
            ? dominant.withValues(alpha: _opacity(dominant))
            : Colors.white,
        albumImageColors: colors,
      ),
    );
  }

  /// Helper method to emit default colors
  void _emitDefaultColors(bool isDark, {List<Color>? colors}) {
    emit(
      state.copyWith(
        ogDominantColor: isDark
            ? const Color.fromARGB(255, 24, 24, 24)
            : Colors.white,
        dominantColor: isDark
            ? Colors.black
            : Colors.grey.withValues(alpha: 0.5),
        imageColors: colors ?? [Colors.black, Colors.black],
      ),
    );
  }

  void _emitAlbumDefaults(bool isDark) {
    emit(
      state.copyWith(
        albumOgDominantColor: isDark ? const Color(0xFF181818) : Colors.white,
        albumDominantColor: isDark
            ? Colors.black
            : Colors.grey.withValues(alpha: 0.5),
        albumImageColors: const [Colors.black, Colors.black],
      ),
    );
  }

  void reapplyTheme() {
    final theme = sl<ThemeCubit>();
    emit(
      state.copyWith(
        dominantColor: theme.isDark
            ? state.ogDominantColor.withValues(alpha: 0.8)
            : Colors.white,
      ),
    );
  }

  /// Extract colors from multiple images (local or network)
  ///
  /// [imageList] - List of local image data (Uint8List)
  /// [isOnline] - If true, uses network URLs instead
  /// [networkUrls] - List of network URLs (required if isOnline is true)
  Future<void> extractImageColors({
    List<Uint8List?>? imageList,
    bool isOnline = false,
    List<String>? networkUrls,
  }) async {
    List<Color> colors = [];

    try {
      if (isOnline) {
        // Extract from network URLs
        if (networkUrls == null || networkUrls.isEmpty) {
          emit(state.copyWith(imageColors: colors));
          return;
        }

        for (String url in networkUrls) {
          if (url.isNotEmpty) {
            try {
              final palette = await PaletteGenerator.fromImageProvider(
                NetworkImage(url),
                size: const Size(250, 250),
                maximumColorCount: 20,
              );
              colors.addAll(palette.colors);
            } catch (e) {
              debugPrint(
                'Error extracting colors from network URL: $url, Error: $e',
              );
            }
          }
        }
      } else {
        // Extract from local image data
        if (imageList == null || imageList.isEmpty) {
          emit(state.copyWith(imageColors: colors));
          return;
        }

        for (Uint8List? imageData in imageList) {
          if (imageData != null) {
            try {
              final palette = await PaletteGenerator.fromImageProvider(
                MemoryImage(imageData),
                size: const Size(250, 250),
                maximumColorCount: 20,
              );
              colors.addAll(palette.colors);
            } catch (e) {
              debugPrint('Error extracting colors from local image: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error in extractImageColors: $e');
    }

    emit(state.copyWith(imageColors: colors));
  }

  Color get dominantColor => state.dominantColor;
  List<Color> get imageColors => state.imageColors;
  bool get isDarkTheme => sl<ThemeCubit>().isDark;

  double _opacity(Color color) => color.computeLuminance() > 0.5 ? 0.2 : 0.8;
}
