import 'package:flutter/material.dart';
import 'dart:math' as math;

class EqualizerBars extends StatefulWidget {
  const EqualizerBars({super.key});

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (index) {
              final delay = index * 0.1;
              final height =
                  8.0 +
                  (math.sin((_controller.value + delay) * math.pi * 2) * 15);
              return Container(
                width: 4,
                height: height + 15,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [const Color(0xFF6C63FF), const Color(0xFFFF6584)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animation;

  WavePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF6C63FF).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = const Color(0xFFFF6584).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    final path2 = Path();

    // First wave
    path1.moveTo(0, size.height * 0.5);
    for (double i = 0; i < size.width; i++) {
      path1.lineTo(
        i,
        size.height * 0.5 +
            math.sin(
                  (i / size.width * 2 * math.pi) + (animation * 2 * math.pi),
                ) *
                50,
      );
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    // Second wave
    path2.moveTo(0, size.height * 0.6);
    for (double i = 0; i < size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.6 +
            math.sin(
                  (i / size.width * 2 * math.pi) +
                      (animation * 2 * math.pi) +
                      math.pi,
                ) *
                40,
      );
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
