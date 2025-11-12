import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:moz_updated_version/screens/all_screens/presentation/model/tab_model.dart';

class TabConfigCubit extends Cubit<List<TabModel>> {
  final Box<TabModel> tabBox = Hive.box<TabModel>('tabs');
  final Box settingsBox = Hive.box('settingsBox');
  TabConfigCubit() : super([]) {
    loadTabs();
  }

  void loadTabs() {
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
      settingsBox.put('tabOrder', defaultTabs.map((e) => e.title).toList());
    }
    final savedOrder = settingsBox.get('tabOrder')?.cast<String>();
    List<TabModel> tabs = tabBox.values.toList();

    if (savedOrder != null && savedOrder.isNotEmpty) {
      tabs.sort(
        (a, b) =>
            savedOrder.indexOf(a.title).compareTo(savedOrder.indexOf(b.title)),
      );
    }

    emit(tabs);
  }

  void toggleTab(int index, bool enabled) {
    final tabs = List<TabModel>.from(state);
    tabs[index].enabled = enabled;
    tabs[index].save();
    emit(tabs);
  }

  void reorderTab(int oldIndex, int newIndex) {
    final tabs = List<TabModel>.from(state);
    if (newIndex > oldIndex) newIndex--;

    final item = tabs.removeAt(oldIndex);
    tabs.insert(newIndex, item);

    final newOrder = tabs.map((e) => e.title).toList();
    settingsBox.put('tabOrder', newOrder);

    for (final tab in tabs) {
      tab.save();
    }

    emit(tabs);
  }

  void setDefaultTab(String title) {
    settingsBox.put('defaultTab', title);
    emit(List<TabModel>.from(state));
  }

  String getDefaultTab(List<TabModel> currentTabs) {
    final enabledTabs = currentTabs.where((t) => t.enabled).toList();
    if (enabledTabs.isEmpty) return '';

    String? stored = settingsBox.get('defaultTab') as String?;
    if (stored != null) {
      final defaultTab = enabledTabs.firstWhere(
        (t) => t.title == stored,
        orElse: () => enabledTabs.first,
      );
      return defaultTab.title;
    }

    final homeTab = enabledTabs.firstWhere(
      (t) => t.title.toLowerCase() == 'home',
      orElse: () => enabledTabs.firstWhere(
        (t) => t.title.toLowerCase() == 'all songs',
        orElse: () => enabledTabs.first,
      ),
    );
    return homeTab.title;
  }
}
