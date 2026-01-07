import 'package:flutter/material.dart';

class MozSearchBar extends StatelessWidget {
  final String hintText;
  final bool autoFocus;
  final void Function(String value) onChanged;
  final bool dummy;

  const MozSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = "Search songs, artists, albums...",
    this.autoFocus = false,
    this.dummy = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          autofocus: autoFocus,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 20,
            ),
          ),
          onChanged: (value) => onChanged(value.trim().toLowerCase()),
        ),
      ),
    );
  }
}
