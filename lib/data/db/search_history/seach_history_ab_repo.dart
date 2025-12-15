import 'package:hive/hive.dart';

class SearchHistoryRepository {
  SearchHistoryRepository._();
  static final SearchHistoryRepository instance = SearchHistoryRepository._();

  static const int _maxItems = 10;
  static const String searchHistoryKey = 'items';
  static const String searchHistoryBox = 'search_history_box';

  Box<List<String>> get _box => Hive.box<List<String>>(searchHistoryBox);

  List<String> getHistory() {
    return _box.get(searchHistoryKey) ?? <String>[];
  }

  Future<void> save(String query) async {
    final value = query.trim();
    if (value.isEmpty) return;

    final items = getHistory();

    items.remove(value);
    items.insert(0, value);

    if (items.length > _maxItems) {
      items.removeLast();
    }

    await _box.put(searchHistoryKey, items);
  }

  Future<void> remove(String query) async {
    final items = getHistory();
    items.remove(query);
    await _box.put(searchHistoryKey, items);
  }

  Future<void> clear() async {
    await _box.put(searchHistoryKey, const <String>[]);
  }
}
