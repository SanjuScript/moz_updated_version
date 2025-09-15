abstract class ThemeRepo {
  Future<void> saveTheme(String themeMode);
  String loadTheme();

  Future<void> savePlatform(String platform);
  String loadPlatform();
}
