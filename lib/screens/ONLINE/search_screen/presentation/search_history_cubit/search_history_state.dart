part of 'search_history_cubit.dart';

class SearchHistoryState extends Equatable {
  final List<String> items;

  const SearchHistoryState(this.items);

  @override
  List<Object> get props => [items];
}
