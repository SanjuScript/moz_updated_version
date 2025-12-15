import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/search_history_cubit/search_history_cubit.dart';

class SearchHistoryWidget extends StatelessWidget {
  final void Function(String item) onTap;
  const SearchHistoryWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchHistoryCubit, SearchHistoryState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.items.isNotEmpty)
              _buildSectionHeader('Recent Searches', Icons.history),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final query = state.items[index];

                return InkWell(
                  onTap: () => onTap(query),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.history, size: 20, color: Colors.grey),
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
