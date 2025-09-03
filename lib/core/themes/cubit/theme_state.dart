part of 'theme_cubit.dart';
class ThemeState {
  final ThemeData themeData;
  final String themeMode;
  final bool isTimeBased;

  const ThemeState({
    required this.themeData,
    required this.themeMode,
    required this.isTimeBased,
  });

  ThemeState copyWith({
    ThemeData? themeData,
    String? themeMode,
    bool? isTimeBased,
  }) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      themeMode: themeMode ?? this.themeMode,
      isTimeBased: isTimeBased ?? this.isTimeBased,
    );
  }
}
