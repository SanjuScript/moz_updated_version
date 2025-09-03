import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:moz_updated_version/core/themes/custom_theme.dart';
import 'package:moz_updated_version/core/utils/repository/theme_repository/theme_repo.dart';
part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> with WidgetsBindingObserver {
  final ThemeRepo themeRepo;

  ThemeCubit(this.themeRepo)
    : super(
        ThemeState(
          themeData: CustomThemes.lightThemeMode,
          themeMode: 'light',
          isTimeBased: false,
        ),
      ) {
    WidgetsBinding.instance.addObserver(this);
    _loadTheme();
  }

  void _loadTheme() {
    final savedMode = themeRepo.loadTheme();
    final isTimeBased = savedMode == 'timeBased';
    _setThemeMode(savedMode, isTimeBased: isTimeBased);
  }

  void _setThemeMode(String themeMode, {bool isTimeBased = false}) {
    ThemeData themeData;

    if (themeMode == 'light') {
      themeData = CustomThemes.lightThemeMode;
    } else if (themeMode == 'dark') {
      themeData = CustomThemes.darkThemeMode;
    } else if (themeMode == 'system') {
      var brightness = PlatformDispatcher.instance.platformBrightness;
      themeData = brightness == Brightness.dark
          ? CustomThemes.darkThemeMode
          : CustomThemes.lightThemeMode;
    } else if (themeMode == 'timeBased') {
      themeData = _getTimeBasedTheme();
    } else {
      themeData = CustomThemes.lightThemeMode;
    }

    themeRepo.saveTheme(themeMode);

    emit(
      state.copyWith(
        themeData: themeData,
        themeMode: themeMode,
        isTimeBased: isTimeBased,
      ),
    );
  }

  void setLightMode() => _setThemeMode('light');
  void setDarkMode() => _setThemeMode('dark');
  void setSystemMode() => _setThemeMode('system');
  void setTimeBasedMode(bool enabled) =>
      _setThemeMode(enabled ? 'timeBased' : 'light', isTimeBased: enabled);

  ThemeData _getTimeBasedTheme() {
    final hour = DateTime.now().hour;
    return (hour >= 6 && hour < 18)
        ? CustomThemes.lightThemeMode
        : CustomThemes.darkThemeMode;
  }

  @override
  void didChangePlatformBrightness() {
    if (state.themeMode == 'system') {
      var brightness = SchedulerBinding.instance.window.platformBrightness;
      final themeData = brightness == Brightness.dark
          ? CustomThemes.darkThemeMode
          : CustomThemes.lightThemeMode;
      emit(state.copyWith(themeData: themeData));
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
