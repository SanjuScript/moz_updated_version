part of 'artworkcolorextractor_cubit.dart';

class ArtworkColorState extends Equatable {
  final List<Color> imageColors;
  final Color dominantColor;
  final Color ogDominantColor;

  final List<Color> albumImageColors;
  final Color albumDominantColor;
  final Color albumOgDominantColor;

  const ArtworkColorState({
    required this.imageColors,
    required this.dominantColor,
    required this.ogDominantColor,
    required this.albumImageColors,
    required this.albumDominantColor,
    required this.albumOgDominantColor,
  });

  const ArtworkColorState.initial()
    : imageColors = const [Colors.black, Colors.black],
      dominantColor = Colors.black,
      ogDominantColor = Colors.black,
      albumImageColors = const [Colors.black, Colors.black],
      albumDominantColor = Colors.black,
      albumOgDominantColor = Colors.black;

  ArtworkColorState copyWith({
    List<Color>? imageColors,
    Color? dominantColor,
    Color? ogDominantColor,
    List<Color>? albumImageColors,
    Color? albumDominantColor,
    Color? albumOgDominantColor,
  }) {
    return ArtworkColorState(
      imageColors: imageColors ?? this.imageColors,
      dominantColor: dominantColor ?? this.dominantColor,
      ogDominantColor: ogDominantColor ?? this.ogDominantColor,
      albumImageColors: albumImageColors ?? this.albumImageColors,
      albumDominantColor: albumDominantColor ?? this.albumDominantColor,
      albumOgDominantColor: albumOgDominantColor ?? this.albumOgDominantColor,
    );
  }

  List<Color> get primaryColors {
    if (imageColors.isEmpty) {
      return [dominantColor, dominantColor];
    }
    return imageColors.take(2).toList();
  }

  List<Color> get albumPrimaryColors => albumImageColors.isNotEmpty
      ? albumImageColors.take(2).toList()
      : [albumDominantColor, albumDominantColor];

  bool get isDarkTheme => sl<ThemeCubit>().isDark;

  @override
  List<Object?> get props => [
    imageColors,
    dominantColor,
    ogDominantColor,
    albumImageColors,
    albumDominantColor,
    albumOgDominantColor,
  ];
}
