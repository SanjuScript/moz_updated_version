import 'package:flutter/material.dart';

class LyricsContentSection extends StatelessWidget {
  final String lyrics;
  const LyricsContentSection({super.key, required this.lyrics});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lines = lyrics.split('\n').where((e) => e.trim().isNotEmpty).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .03)
            : Colors.black.withValues(alpha: .02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: .05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lyrics,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Lyrics',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...lines.asMap().entries.map((e) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (e.key * 30)),
              tween: Tween(begin: 0, end: 1),
              builder: (context, v, child) => Opacity(
                opacity: v,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - v)),
                  child: child,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  e.value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                    letterSpacing: 0.3,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
