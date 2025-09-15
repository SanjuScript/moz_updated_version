part of 'theme_cubit.dart';

class ThemeState {
  final ThemeData themeData;
  final String themeMode;
  final bool isTimeBased;
  final TargetPlatform platform;
  final bool isDark;

  const ThemeState({
    required this.themeData,
    required this.themeMode,
    required this.isTimeBased,
    this.platform = TargetPlatform.android,
    required this.isDark,
  });

  ThemeState copyWith({
    ThemeData? themeData,
    String? themeMode,
    bool? isTimeBased,
    TargetPlatform? platform,
    bool? isDark,
  }) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      themeMode: themeMode ?? this.themeMode,
      isTimeBased: isTimeBased ?? this.isTimeBased,
      platform: platform ?? this.platform,
      isDark: isDark ?? this.isDark
    );
  }
}
