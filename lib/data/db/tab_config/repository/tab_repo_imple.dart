import 'package:hive/hive.dart';
import 'package:moz_updated_version/data/db/tab_config/repository/tab_repo.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/model/tab_model.dart';

class TabConfigRepository implements TabRepo {
  static final TabConfigRepository _instance = TabConfigRepository._internal();

  factory TabConfigRepository() {
    return _instance;
  }

  TabConfigRepository._internal();

  final Box<TabModel> tabBox = Hive.box<TabModel>('tabs');
  final Box settingsBox = Hive.box('settingsBox');

  /// Loads all saved tabs from Hive.
  @override
  List<TabModel> loadTabs() {
    if (tabBox.isEmpty) {
      final defaultTabs = [
        TabModel(title: "Mostly Played"),
        TabModel(title: "Recently Played"),
        TabModel(title: "Home"),
        TabModel(title: "All Songs"),
        TabModel(title: "Albums"),
        TabModel(title: "Artists"),
        TabModel(title: "Favorites"),
        TabModel(title: "Playlists"),
      ];
      tabBox.addAll(defaultTabs);
    }
    return tabBox.values.toList();
  }

  /// Saves the current tab order and state persistently.
  @override
  Future<void> saveTabs(List<TabModel> tabs) async {
    await tabBox.clear(); // Remove old ordering
    await tabBox.addAll(tabs);
  }

  /// Save the user-selected default tab title.
  @override
  void saveDefaultTab(String title) {
    settingsBox.put('defaultTab', title);
  }

  /// Fetch the default tab title from settings.
  @override
  String? getDefaultTab() {
    return settingsBox.get('defaultTab') as String?;
  }
}
