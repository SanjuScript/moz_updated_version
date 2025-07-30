import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:moz_updated_version/core/extensions/capitalize.dart';
import 'package:moz_updated_version/core/storage/moz_storage.dart';
import 'package:moz_updated_version/core/themes/custom_theme.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeData _themeData = CustomThemes.lightThemeMode;
  String _themeMode = 'light';
  bool _isTimeBasedModeEnabled = false;

  String get currentTheme => _themeMode;
  ThemeData getTheme() => _themeData;
  bool isTimeBased() => _isTimeBasedModeEnabled;
  String getDisplayThemeMode() {
    if (_themeMode == 'system') {
      return 'System Default';
    } else if (_themeMode == 'timeBased') {
      return 'Time-Based';
    } else {
      return _themeMode.capitalize();
    }
  }

  ThemeProvider() {
    WidgetsBinding.instance.addObserver(this);
    MozStorageManager.readData('themeMode').then((value) {
      _themeMode = value ?? 'light';
      _isTimeBasedModeEnabled = value == 'timeBased';
      _setThemeMode(_themeMode);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setThemeMode(String themeMode) {
    if (themeMode == 'light') {
      _themeData = CustomThemes.lightThemeMode;
    } else if (themeMode == 'dark') {
      _themeData = CustomThemes.darkThemeMode;
    } else if (themeMode == 'system') {
      var brightness = PlatformDispatcher.instance.platformBrightness;
      _themeData = brightness == Brightness.dark
          ? CustomThemes.darkThemeMode
          : CustomThemes.lightThemeMode;
    } else if (themeMode == 'timeBased') {
      _setTimeBasedMode();
    }

    _themeMode = themeMode;
    notifyListeners();
  }

  void setDarkMode() async {
    _themeData = CustomThemes.darkThemeMode;
    _themeMode = 'dark';
    MozStorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = CustomThemes.lightThemeMode;
    _themeMode = 'light';
    MozStorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }

  void setSystemMode() async {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    _themeData = brightness == Brightness.dark
        ? CustomThemes.darkThemeMode
        : CustomThemes.lightThemeMode;
    _themeMode = 'system';
    MozStorageManager.saveData('themeMode', 'system');
    notifyListeners();
  }

  void setTimeBasedMode(bool enabled) async {
    _isTimeBasedModeEnabled = enabled;
    if (enabled) {
      _themeMode = 'timeBased';
      _setTimeBasedMode();
    } else {
      _themeMode = 'light';
      _themeData = CustomThemes.lightThemeMode;
    }
    MozStorageManager.saveData('themeMode', _themeMode);
    notifyListeners();
  }

  void _setTimeBasedMode() {
    final currentTime = DateTime.now();
    final hour = currentTime.hour;

    if (hour >= 6 && hour < 18) {
      _themeData = CustomThemes.lightThemeMode;
    } else {
      _themeData = CustomThemes.darkThemeMode;
    }
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    MozStorageManager.readData('themeMode').then((themeMode) {
      if (themeMode == 'system') {
        var brightness = PlatformDispatcher.instance.platformBrightness;
        _themeData = brightness == Brightness.dark
            ? CustomThemes.darkThemeMode
            : CustomThemes.lightThemeMode;
        notifyListeners();
      }
    });
  }
}
