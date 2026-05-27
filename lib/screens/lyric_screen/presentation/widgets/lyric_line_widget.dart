import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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

    final double opacity = isActive
        ? 1.0
        : isPast
        ? 0.3
        : isNext
        ? 0.7
        : (1.0 / (distance + 1)).clamp(0.2, 0.6);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: opacity),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, animatedOpacity, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: isActive ? 1.0 : 1.0, end: isActive ? 1.15 : 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: Opacity(
                opacity: animatedOpacity,
                child: GestureDetector(
                  onTap: () {
                    if (line.timestamp != null) {
                      onTap(line.timestamp!);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall!.copyWith(
                        fontSize: 20,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isActive
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark ? Colors.white70 : Colors.black54),
                        height: 1.4,
                      ),
                      child: Text(
                        line.text,
                        textAlign: TextAlign.center,
                        maxLines: null,
                        softWrap: true,
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

class LyricLine extends Equatable {
  final String text;
  final int? timestamp;

  const LyricLine({required this.text, this.timestamp});

  bool get hasTimestamp => timestamp != null;

  @override
  List<Object?> get props => [text, timestamp];

  @override
  String toString() => 'LyricLine(text: $text, timestamp: $timestamp)';

  LyricLine copyWith({String? text, int? timestamp}) {
    return LyricLine(
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
