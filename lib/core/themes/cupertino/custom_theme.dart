import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/extensions/color_ext.dart';
import 'package:moz_updated_version/core/helper/font_helper.dart';

class CustomCupertinoThemes {
  static CupertinoThemeData lightTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xfff55297),
    scaffoldBackgroundColor: const Color(0xffffffff),
    barBackgroundColor: const Color(0xffffffff),
    textTheme: CupertinoTextThemeData(
      navTitleTextStyle: PerfectTypography.bold.copyWith(
        fontSize: 20,
        color: "0D0D0D".toColor(),
      ),
      navLargeTitleTextStyle: PerfectTypography.bold.copyWith(
        fontSize: 28,
        color: "0D0D0D".toColor(),
      ),
      navActionTextStyle: PerfectTypography.regular.copyWith(
        fontSize: 16,
        color: const Color(0xfff55297),
      ),
      // General text styles
      textStyle: PerfectTypography.regular.copyWith(
        fontSize: 16,
        color: "0D0D0D".toColor(),
      ),
      pickerTextStyle: PerfectTypography.regular.copyWith(
        fontSize: 18,
        color: "0D0D0D".toColor(),
      ),
    ),
  );

  static CupertinoThemeData darkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xfff55297), 
    scaffoldBackgroundColor: Colors.black,
    barBackgroundColor: Colors.black,
    textTheme: CupertinoTextThemeData(
      navTitleTextStyle: PerfectTypography.bold.copyWith(
        fontSize: 20,
        color: Colors.white,
      ),
      navLargeTitleTextStyle: PerfectTypography.bold.copyWith(
        fontSize: 28,
        color: Colors.white,
      ),
      navActionTextStyle: PerfectTypography.regular.copyWith(
        fontSize: 16,
        color: const Color(0xfff55297),
      ),
      textStyle: PerfectTypography.regular.copyWith(
        fontSize: 16,
        color: Colors.white70,
      ),
      pickerTextStyle: PerfectTypography.regular.copyWith(
        fontSize: 18,
        color: Colors.white,
      ),
    ),
  );
}
