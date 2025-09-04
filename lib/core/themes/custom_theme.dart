import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/extensions/color_ext.dart';
import 'package:moz_updated_version/core/helper/font_helper.dart';

class CustomThemes {
  static final lightThemeMode = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xffffffff),
    dialogTheme: DialogThemeData(backgroundColor: Colors.white.withOpacity(.6)),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xffffffff),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: PerfectTypography.bold.copyWith(
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: PerfectTypography.bold.copyWith(
        fontSize: 32,
        color: "0D0D0D".toColor(),
      ),
      displayMedium: PerfectTypography.bold.copyWith(
        fontSize: 28,
        color: "0D0D0D".toColor(),
      ),
      bodyLarge: PerfectTypography.regular.copyWith(
        fontSize: 16,
        color: "0D0D0D".toColor(),
      ),
      bodyMedium: PerfectTypography.regular.copyWith(
        fontSize: 14,
        color: "0D0D0D".toColor(),
      ),
      bodySmall: PerfectTypography.regular.copyWith(
        fontSize: 12,
        color: "0D0D0D".toColor(),
      ),
      labelLarge: PerfectTypography.bold.copyWith(
        fontSize: 16,
        color: "0D0D0D".toColor(),
      ),
      titleLarge: PerfectTypography.bold.copyWith(
        fontSize: 24,
        color: "0D0D0D".toColor(),
      ),
      headlineLarge: PerfectTypography.regular.copyWith(
        fontSize: 22,
        color: "0D0D0D".toColor(),
      ),
      headlineMedium: PerfectTypography.regular.copyWith(
        fontSize: 20,
        color: "0D0D0D".toColor(),
      ),
      headlineSmall: PerfectTypography.regular.copyWith(
        fontSize: 18,
        color: "0D0D0D".toColor(),
      ),
      labelMedium: PerfectTypography.bold.copyWith(
        fontSize: 16,
        color: "0D0D0D".toColor(),
      ),
      labelSmall: PerfectTypography.bold.copyWith(
        fontSize: 14,
        color: Colors.white70,
      ),
      titleMedium: PerfectTypography.regular.copyWith(
        color: const Color(0xff333c67),
      ),
      titleSmall: PerfectTypography.normal.copyWith(
        fontSize: 13,
        color: const Color(0xff333c67).withValues(alpha: 0.4),
      ),
    ),
    tabBarTheme: TabBarThemeData(indicatorColor: Color(0xffE7EAF3)),
  );

  static final darkThemeMode = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: PerfectTypography.bold.copyWith(
        fontSize: 20,
        color: "F7F7F7".toColor(),
      ),
    ),

    textTheme: TextTheme(
      displayLarge: PerfectTypography.bold.copyWith(
        fontSize: 32,
        color: Colors.white,
      ),
      displayMedium: PerfectTypography.bold.copyWith(
        fontSize: 28,
        color: Colors.white70,
      ),
      bodyLarge: PerfectTypography.regular.copyWith(
        fontSize: 16,
        color: Colors.white70,
      ),
      bodyMedium: PerfectTypography.regular.copyWith(
        fontSize: 14,
        color: Colors.white60,
      ),
      bodySmall: PerfectTypography.regular.copyWith(
        fontSize: 12,
        color: Colors.white70,
      ),
      labelLarge: PerfectTypography.bold.copyWith(
        fontSize: 16,
        color: Colors.white70,
      ),
      titleLarge: PerfectTypography.bold.copyWith(
        fontSize: 24,
        color: Colors.white,
      ),
      headlineLarge: PerfectTypography.regular.copyWith(
        fontSize: 22,
        color: Colors.white,
      ),
      headlineMedium: PerfectTypography.regular.copyWith(
        fontSize: 20,
        color: Colors.white70,
      ),
      headlineSmall: PerfectTypography.regular.copyWith(
        fontSize: 18,
        color: Colors.white70,
      ),
      labelMedium: PerfectTypography.bold.copyWith(
        fontSize: 16,
        color: Colors.white,
      ),
      labelSmall: PerfectTypography.bold.copyWith(
        fontSize: 14,
        color: Colors.white70,
      ),
      titleMedium: PerfectTypography.regular.copyWith(
        color: const Color.fromARGB(255, 204, 203, 203),
      ),
      titleSmall: PerfectTypography.normal.copyWith(
        fontSize: 13,
        color: const Color.fromARGB(255, 68, 69, 70),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Color(0xFF1F1F1F),
      titleTextStyle: PerfectTypography.bold.copyWith(
        fontSize: 20,
        color: Colors.white,
      ),
      contentTextStyle: PerfectTypography.bold.copyWith(
        fontSize: 16,
        color: Colors.white70,
      ),
    ),

    tabBarTheme: TabBarThemeData(indicatorColor: Color(0xff343434)),
  );
}
