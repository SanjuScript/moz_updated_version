import 'package:moz_updated_version/screens/all_screens/presentation/model/tab_model.dart';

abstract class TabRepo {
  List<TabModel> loadTabs();
  Future<void> saveTabs(List<TabModel> tabs);
  void saveDefaultTab(String title);
  String? getDefaultTab();
}
