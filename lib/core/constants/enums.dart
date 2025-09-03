enum AppTheme { light, dark, system, timeBased }

extension AppThemeX on AppTheme {
  int get indexValue {
    switch (this) {
      case AppTheme.light:
        return 0;
      case AppTheme.dark:
        return 1;
      case AppTheme.system:
        return 2;
      case AppTheme.timeBased:
        return 3;
    }
  }

  static AppTheme fromIndex(int index) {
    switch (index) {
      case 0:
        return AppTheme.light;
      case 1:
        return AppTheme.dark;
      case 2:
        return AppTheme.system;
      case 3:
        return AppTheme.timeBased;
      default:
        return AppTheme.light;
    }
  }
}
