part of 'artworkcolorextractor_cubit.dart';

class ArtworkColorState extends Equatable {
  final List<Color> imageColors;
  final Color dominantColor;
  final Color ogDominantColor;

  const ArtworkColorState({
    required this.imageColors,
    required this.dominantColor,
    required this.ogDominantColor,
  });

  const ArtworkColorState.initial()
    : imageColors = const [Colors.black, Colors.black],
      dominantColor = Colors.black,
      ogDominantColor = Colors.black;

  ArtworkColorState copyWith({
    List<Color>? imageColors,
    Color? dominantColor,
    Color? ogDominantColor,
  }) {
    return ArtworkColorState(
      imageColors: imageColors ?? this.imageColors,
      dominantColor: dominantColor ?? this.dominantColor,
      ogDominantColor: ogDominantColor ?? this.ogDominantColor,
    );
  }

  List<Color> get primaryColors {
    if (imageColors.isEmpty) {
      return [dominantColor, dominantColor];
    }
    return imageColors.take(2).toList();
  }

  bool get isDarkTheme => sl<ThemeCubit>().isDark;

  @override
  List<Object?> get props => [imageColors, dominantColor, ogDominantColor];
}
