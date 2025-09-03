import 'package:hive/hive.dart';
import 'package:moz_updated_version/core/utils/repository/theme_repository/theme_repo.dart';
import 'theme_repo.dart';

class ThemeRepository implements ThemeRepo {
  final Box _settingsBox = Hive.box('settingsBox');

  @override
  String loadTheme() {
    return _settingsBox.get('themeMode', defaultValue: 'light');
  }

  @override
  Future<void> saveTheme(String themeMode) async {
    await _settingsBox.put('themeMode', themeMode);
  }
}
