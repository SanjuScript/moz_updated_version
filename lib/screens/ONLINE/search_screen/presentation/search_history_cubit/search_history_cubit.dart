import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/db/search_history/seach_history_ab_repo.dart';

part 'search_history_state.dart';

class SearchHistoryCubit extends Cubit<SearchHistoryState> {
  final SearchHistoryRepository _repo = SearchHistoryRepository.instance;

  SearchHistoryCubit() : super(const SearchHistoryState([])) {
    load();
  }

  void load() {
    final items = _repo.getHistory();
    emit(SearchHistoryState(List<String>.from(items)));
  }

  Future<void> add(String query) async {
    await _repo.save(query);
    load();
  }

  Future<void> remove(String query) async {
    await _repo.remove(query);
    load();
  }

  Future<void> clear() async {
    await _repo.clear();
    emit(const SearchHistoryState([]));
  }
}
