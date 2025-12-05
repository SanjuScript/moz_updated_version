import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/color_extractor.dart/cubit/artworkcolorextractor_cubit.dart';

class LyricLineWidget extends StatelessWidget {
  final LyricLine line;
  final int index;
  final int currentIndex;
  final AnimationController fadeController;
  final AnimationController scaleController;
  final Function(int) onTap;
  final bool isDark;
  final ThemeData theme;

  const LyricLineWidget({
    super.key,
    required this.line,
    required this.index,
    required this.currentIndex,
    required this.fadeController,
    required this.scaleController,
    required this.onTap,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final isPast = index < currentIndex;
    final isNext = index == currentIndex + 1;
    final distance = (index - currentIndex).abs();

    final opacity = isActive
        ? 1.0
        : isPast
        ? 0.3
        : isNext
        ? 0.7
        : (1.0 / (distance + 1)).clamp(0.4, 1.0);

    final artworkColor = context.read<ArtworkColorCubit>();

    final primary = isDark
        ? artworkColor.dominantColor
        : Theme.of(context).scaffoldBackgroundColor;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: opacity),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, animatedOpacity, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(
            begin: isActive ? 0.95 : 1.0,
            end: isActive ? 1.0 : 0.95,
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: animatedOpacity,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: GestureDetector(
                    onTap: () {
                      if (line.timestamp != null) {
                        onTap(line.timestamp!);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      child: Text(
                        line.text,
                        textAlign: TextAlign.left,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: isActive
                              ? 26
                              : isNext
                              ? 22
                              : 20,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : isNext
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? (isDark ? Colors.white : Colors.black87)
                              : isPast
                              ? (isDark ? Colors.white38 : Colors.black38)
                              : (isDark ? Colors.white70 : Colors.black54),
                          height: 1.4,
                          letterSpacing: isActive ? 0.1 : 0,
                          shadows: isActive
                              ? [
                                  Shadow(
                                    color: isDark
                                        ? primary.withValues(alpha: 0.5)
                                        : Theme.of(
                                            context,
                                          ).primaryColor.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Lyric Line Model
class LyricLine {
  final String text;
  final int? timestamp;

  LyricLine({required this.text, this.timestamp});
}
