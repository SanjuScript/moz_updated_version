import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveformPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final bool enabled;

  WaveformPainter({
    required this.animation,
    required this.color,
    required this.enabled,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled) return;

    final baseColor = color;
    final waveHeight = size.height * 0.32;
    final waveCount = 3;

    for (var i = 0; i < waveCount; i++) {
      final alpha = (0.15 + (i * 0.10)).clamp(0.05, 0.3);
      final paint = Paint()
        ..color = baseColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + (i * 0.8)
        ..strokeCap = StrokeCap.round;

      final path = Path();

      final phase = animation.value * 2 * math.pi;
      final freq = 1.4 + (i * 0.5);
      final amp =
          waveHeight * (1 - (i * 0.25)) * (0.7 + math.sin(phase + i) * 0.3);

      for (double x = 0; x <= size.width; x += 6) {
        final y =
            size.height / 2 +
            math.sin((x / size.width * 2 * math.pi * freq) + phase) * amp;

        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.enabled != enabled ||
        oldDelegate.color != color;
  }
}
