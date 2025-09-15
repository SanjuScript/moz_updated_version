import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:moz_updated_version/core/themes/custom_theme.dart';
import 'package:moz_updated_version/core/themes/repository/theme__ab_repo.dart';
import 'package:moz_updated_version/services/service_locator.dart';
part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> with WidgetsBindingObserver {
  final ThemeRepo themeRepo = sl<ThemeRepo>();
  ThemeCubit()
    : super(
        ThemeState(
          themeData: CustomThemes.lightThemeMode(),
          themeMode: 'light',
          isTimeBased: false,
          platform: TargetPlatform.android,
          isDark: false,
        ),
      ) {
    WidgetsBinding.instance.addObserver(this);
    _loadTheme();
    _loadPlatform();
  }

  void _loadPlatform() {
    final savedPlatform = themeRepo.loadPlatform();
    final platform = savedPlatform == 'ios'
        ? TargetPlatform.iOS
        : TargetPlatform.android;

    emit(state.copyWith(platform: platform));
  }

  bool get isIos => state.platform == TargetPlatform.iOS;

  void setPlatform(TargetPlatform platform) {
    emit(state.copyWith(platform: platform));
    _setThemeMode(state.themeMode, isTimeBased: state.isTimeBased);
    themeRepo.savePlatform(platform == TargetPlatform.iOS ? 'ios' : 'android');
  }

  void _loadTheme() {
    final savedMode = themeRepo.loadTheme();
    final isTimeBased = savedMode == 'timeBased';
    _setThemeMode(savedMode, isTimeBased: isTimeBased);
  }

  void _setThemeMode(String themeMode, {bool isTimeBased = false}) {
    final platform = state.platform;
    ThemeData themeData;

    if (themeMode == 'light') {
      themeData = CustomThemes.lightThemeMode(platform);
    } else if (themeMode == 'dark') {
      themeData = CustomThemes.darkThemeMode(platform);
    } else if (themeMode == 'system') {
      var brightness = PlatformDispatcher.instance.platformBrightness;
      themeData = brightness == Brightness.dark
          ? CustomThemes.darkThemeMode(platform)
          : CustomThemes.lightThemeMode(platform);
    } else if (themeMode == 'timeBased') {
      themeData = _getTimeBasedTheme(platform).copyWith(platform: platform);
    } else {
      themeData = CustomThemes.lightThemeMode(platform);
    }

    final bool dark = _calculateIsDark(themeMode);
    emit(
      state.copyWith(
        themeData: themeData,
        themeMode: themeMode,
        isTimeBased: isTimeBased,
        isDark: dark,
      ),
    );

    Future.microtask(() => themeRepo.saveTheme(themeMode));
  }

  void setLightMode() => _setThemeMode('light');
  void setDarkMode() => _setThemeMode('dark');
  void setSystemMode() => _setThemeMode('system');
  void setTimeBasedMode(bool enabled) =>
      _setThemeMode(enabled ? 'timeBased' : 'light', isTimeBased: enabled);

  ThemeData _getTimeBasedTheme([TargetPlatform? platform]) {
    final hour = DateTime.now().hour;
    return (hour >= 6 && hour < 18)
        ? CustomThemes.lightThemeMode(platform!)
        : CustomThemes.darkThemeMode(platform!);
  }

  bool get isDark {
    final themeMode = state.themeMode;

    if (themeMode == 'dark') return true;
    if (themeMode == 'light') return false;

    if (themeMode == 'system') {
      return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }

    if (themeMode == 'timeBased') {
      final hour = DateTime.now().hour;
      return hour < 6 || hour >= 18;
    }

    return false;
  }

  bool _calculateIsDark(String themeMode) {
    if (themeMode == 'dark') return true;
    if (themeMode == 'light') return false;

    if (themeMode == 'system') {
      return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }

    if (themeMode == 'timeBased') {
      final hour = DateTime.now().hour;
      return hour < 6 || hour >= 18;
    }

    return false;
  }

  @override
  void didChangePlatformBrightness() {
    if (state.themeMode == 'system') {
      final brightness = PlatformDispatcher.instance.platformBrightness;
      final platform = state.platform;
      final themeData = brightness == Brightness.dark
          ? CustomThemes.darkThemeMode(platform)
          : CustomThemes.lightThemeMode(platform);
      emit(state.copyWith(themeData: themeData));
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
