import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/search_history_cubit/search_history_cubit.dart';

class SearchHistoryWidget extends StatefulWidget {
  final void Function(String item) onTap;
  const SearchHistoryWidget({super.key, required this.onTap});

  @override
  State<SearchHistoryWidget> createState() => _SearchHistoryWidgetState();
}

class _SearchHistoryWidgetState extends State<SearchHistoryWidget> {
  bool _expanded = false;
  static const int _collapsedCount = 5;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchHistoryCubit, SearchHistoryState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = state.items;
        final visibleItems = _expanded
            ? items
            : items.take(_collapsedCount).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Recent Searches', Icons.history),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleItems.length,
              itemBuilder: (context, index) {
                final query = visibleItems[index];

                return InkWell(
                  onTap: () => widget.onTap(query),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.history, size: 20, color: Colors.grey),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            query,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.grey,
                          onPressed: () {
                            context.read<SearchHistoryCubit>().remove(query);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // 🔽 SHOW MORE / LESS
            if (items.length > _collapsedCount)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        _expanded ? 'Show less searches' : 'Show more searches',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.purple.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: Colors.purple.shade400,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.purple),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
