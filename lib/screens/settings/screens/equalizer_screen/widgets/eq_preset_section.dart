import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_section_header_icons.dart';
import '../cubit/equalizer_cubit.dart';

class EqualizerPresetsSection extends StatelessWidget {
  final List<String> presets;
  final int? currentPreset;

  const EqualizerPresetsSection({
    super.key,
    required this.presets,
    required this.currentPreset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(icon: Icons.tune, title: "Sound Presets"),

            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.asMap().entries.map((entry) {
                final i = entry.key;
                final name = entry.value;
                final isSelected = currentPreset == i;

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (i * 50)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, anim, child) {
                    final clampedAnim = anim.clamp(0.0, 1.0);
                    return Transform.scale(
                      scale: 0.8 + (0.2 * clampedAnim),
                      child: Opacity(opacity: clampedAnim, child: child),
                    );
                  },
                  child: _minimalPresetChip(context, i, name, isSelected),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _minimalPresetChip(
    BuildContext context,
    int index,
    String text,
    bool selected,
  ) {
    return GestureDetector(
      onTap: () => context.read<EqualizerCubit>().applyPreset(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
                : Colors.grey,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: selected ? 6 : 4,
              height: selected ? 6 : 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      )
                    : null,
                color: selected ? null : Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Theme.of(context).colorScheme.primary : null,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
