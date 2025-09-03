abstract class ThemeRepo {
  Future<void> saveTheme(String themeMode);
  String loadTheme();
}
