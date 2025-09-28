part of 'theme_cubit.dart';

class ThemeState {
  final ThemeData themeData;
  final String themeMode;
  final bool isTimeBased;
  final TargetPlatform platform;
  final bool isDark;
  final Color primaryColor;

  const ThemeState({
    required this.themeData,
    required this.themeMode,
    required this.isTimeBased,
    required this.primaryColor,
    this.platform = TargetPlatform.android,
    required this.isDark,
  });

  ThemeState copyWith({
    ThemeData? themeData,
    String? themeMode,
    bool? isTimeBased,
    TargetPlatform? platform,
    bool? isDark,
    Color? primaryColor,
  }) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      themeMode: themeMode ?? this.themeMode,
      isTimeBased: isTimeBased ?? this.isTimeBased,
      platform: platform ?? this.platform,
      isDark: isDark ?? this.isDark,
      primaryColor: primaryColor ?? this.primaryColor
    );
  }
}
