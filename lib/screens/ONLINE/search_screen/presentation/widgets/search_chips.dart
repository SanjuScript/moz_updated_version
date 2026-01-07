import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/ONLINE/search_screen/presentation/cubit/jio_saavn_cubit.dart';

enum SearchFilter {
  allSongs,
  albums,
  artists;

  String get label {
    switch (this) {
      case SearchFilter.allSongs:
        return 'All Songs';
      case SearchFilter.albums:
        return 'Albums';
      case SearchFilter.artists:
        return 'Artists';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchFilter.allSongs:
        return Icons.music_note_rounded;
      case SearchFilter.albums:
        return Icons.album_rounded;
      case SearchFilter.artists:
        return Icons.person_rounded;
    }
  }
}

class SearchFilterChips extends StatelessWidget {
  const SearchFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<JioSaavnCubit, JioSaavnState>(
      builder: (context, state) {
        final selectedFilter = context.read<JioSaavnCubit>().currentFilter;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: SearchFilter.values.map((filter) {
                final isSelected = filter == selectedFilter;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildChip(
                    context: context,
                    filter: filter,
                    isSelected: isSelected,
                    theme: theme,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required SearchFilter filter,
    required bool isSelected,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<JioSaavnCubit>().changeFilter(filter);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : null,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter.icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              filter.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
