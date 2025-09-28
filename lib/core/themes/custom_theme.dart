import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/extensions/color_ext.dart';
import 'package:moz_updated_version/core/helper/font_helper.dart';

class CustomThemes {
  static ThemeData lightThemeMode({
    TargetPlatform platform = TargetPlatform.android,
    required Color primary,
  }) {
    return ThemeData(
      useMaterial3: true,
      platform: platform,
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xffffffff),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        contentTextStyle: TextStyle(fontSize: 16, color: Colors.black54),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xffffffff),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: PerfectTypography.bold.copyWith(
          fontSize: 20,
          color: "0D0D0D".toColor(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: PerfectTypography.regular.copyWith(
          fontSize: 14,
          color: const Color(0xff333c67).withValues(alpha: 0.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        prefixIconColor: primary,
        suffixIconColor: primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primary, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primary, width: 2),
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
      hintColor: const Color.fromARGB(255, 241, 241, 241),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: PerfectTypography.normal,
        enableFeedback: true,
      ),
      cardColor: const Color.fromARGB(255, 255, 255, 255),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: const BorderSide(color: Colors.grey, width: 2),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: WidgetStateProperty.all(Colors.black),
          padding: WidgetStateProperty.all(EdgeInsets.all(8)),
          minimumSize: WidgetStateProperty.all(const Size(36, 36)),
          splashFactory: NoSplash.splashFactory,
          foregroundColor: WidgetStateProperty.all(primary),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color.fromARGB(255, 64, 64, 64),
        size: 24,
        opticalSize: 24,
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          elevation: WidgetStateProperty.all(4),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        textStyle: PerfectTypography.regular.copyWith(
          fontSize: 16,
          color: const Color(0xff333c67).withValues(alpha: 0.4),
        ),
        inputDecorationTheme: InputDecorationTheme(
          iconColor: primary,
          filled: true,
          fillColor: const Color.fromARGB(255, 255, 255, 255),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),

      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primary,
        secondary: primary,
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: primary,
        labelColor: primary,

        unselectedLabelColor: Color(0xff9CADC0),
        labelStyle: PerfectTypography.bold.copyWith(fontSize: 16),
        unselectedLabelStyle: PerfectTypography.regular.copyWith(fontSize: 14),
      ),
    );
  }

  static ThemeData darkThemeMode({
    TargetPlatform platform = TargetPlatform.android,
    required Color primary,
  }) {
    return ThemeData(
      useMaterial3: true,
      platform: platform,
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.black,
      dividerColor: const Color.fromARGB(255, 25, 25, 25),
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
      cardColor: const Color.fromARGB(255, 23, 23, 23),
      hintColor: const Color.fromARGB(255, 32, 32, 32),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.grey.shade900,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        enableFeedback: true,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: const Color.fromARGB(255, 39, 39, 39),

        hintStyle: PerfectTypography.regular.copyWith(
          fontSize: 14,
          color: Colors.white70,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        prefixIconColor: primary,
        suffixIconColor: primary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white70, size: 24),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: WidgetStateProperty.all(Colors.white),
          padding: WidgetStateProperty.all(EdgeInsets.all(8)),
          minimumSize: WidgetStateProperty.all(const Size(36, 36)),
          splashFactory: NoSplash.splashFactory,
          foregroundColor: WidgetStateProperty.all(Colors.white70),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: const BorderSide(color: Colors.white70, width: 2),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            const Color.fromARGB(255, 14, 14, 14),
          ),
          elevation: WidgetStateProperty.all(4),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        textStyle: PerfectTypography.regular.copyWith(
          fontSize: 16,
          color: Colors.white70,
        ),
        inputDecorationTheme: InputDecorationTheme(
          iconColor: primary,
          filled: true,
          fillColor: const Color.fromARGB(255, 26, 26, 26),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primary, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primary, width: 2),
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        contentTextStyle: TextStyle(fontSize: 16, color: Colors.grey[300]),
      ),
      colorScheme: ColorScheme.fromSwatch(
        brightness: Brightness.dark,
      ).copyWith(primary: primary, secondary: primary),
      tabBarTheme: TabBarThemeData(
        indicatorColor: primary.withValues(alpha: .9),
        dividerColor: Colors.transparent,
        labelColor: primary.withValues(alpha: .9),
        unselectedLabelColor: Color.fromARGB(255, 68, 69, 70),
        labelStyle: PerfectTypography.bold.copyWith(fontSize: 16),
        unselectedLabelStyle: PerfectTypography.regular.copyWith(fontSize: 14),
      ),
    );
  }
}
