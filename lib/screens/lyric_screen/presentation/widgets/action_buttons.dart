import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const ActionButton({
    required this.isDark,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onTap),
    );
  }
}

class ArtistChip extends StatelessWidget {
  final String artist;
  final bool isDark;
  final ThemeData theme;

  const ArtistChip({
    required this.artist,
    required this.isDark,
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.08),
                ]
              : [
                  Colors.black.withValues(alpha: 0.06),
                  Colors.black.withValues(alpha: 0.03),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_rounded, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              artist,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
