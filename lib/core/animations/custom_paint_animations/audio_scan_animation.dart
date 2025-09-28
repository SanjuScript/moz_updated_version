import 'dart:math';
import 'package:flutter/material.dart';

class AudioScanScreen extends StatefulWidget {
  const AudioScanScreen({super.key});

  @override
  State<AudioScanScreen> createState() => _AudioScanScreenState();
}

class _AudioScanScreenState extends State<AudioScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String statusText = "Scanning your audio files...";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.addListener(() {
      final progress = _controller.value;

      if (progress > 0.6 && progress < 0.95) {
        setState(() => statusText = "Almost done...");
      } else if (progress >= 0.95) {
        setState(() => statusText = "Finished!");
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.6;

    return Scaffold(
      appBar: AppBar(title: const Text("Scanning Audio")),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _WaterFillPainter(
                    Theme.of(context).primaryColor,
                    progress: _animation.value,
                  ),
                  size: Size(size, size),
                );
              },
            ),
            const SizedBox(height: 30),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                statusText,
                key: ValueKey(statusText),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterFillPainter extends CustomPainter {
  final double progress;
  final Color color;

  _WaterFillPainter(this.color, {required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = color.withOpacity(0.6);
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, circlePaint);

    final path = Path();
    final waterHeight = size.height * (1 - progress);
    final waveAmplitude = 8;
    final waveLength = size.width / 1.2;
    final wavePhase = progress * 2 * pi * 2;

    path.moveTo(0, waterHeight);

    for (double x = 0; x <= size.width; x++) {
      final y =
          waterHeight +
          sin((x / waveLength * 2 * pi) + wavePhase) * waveAmplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawPath(path, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WaterFillPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
