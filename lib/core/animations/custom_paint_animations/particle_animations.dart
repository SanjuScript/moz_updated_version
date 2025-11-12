import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  final double radius;
  final Color color;
  Offset velocity;
  double pulsePhase;
  double pulseSpeed;

  Particle({
    required this.position,
    required this.radius,
    required this.color,
    required this.velocity,
    required this.pulsePhase,
    required this.pulseSpeed,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      // Calculate gentle pulsing size
      final pulse = sin(p.pulsePhase + animationValue * p.pulseSpeed);
      final currentRadius = p.radius + (pulse * p.radius * 0.2);

      // Outer soft glow
      final glowPaint = Paint()
        ..color = p.color.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(p.position, currentRadius * 3, glowPaint);

      // Middle glow layer
      final middleGlowPaint = Paint()
        ..color = p.color.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(p.position, currentRadius * 1.8, middleGlowPaint);

      // Main particle with radial gradient
      final gradientPaint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                p.color.withValues(alpha: 0.8),
                p.color.withValues(alpha: 0.5),
                p.color.withValues(alpha: 0.1),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(
              Rect.fromCircle(center: p.position, radius: currentRadius),
            );

      canvas.drawCircle(p.position, currentRadius, gradientPaint);

      // Bright center core
      final corePaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
      canvas.drawCircle(p.position, currentRadius * 0.25, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

class ParticleBackground extends StatefulWidget {
  final int numberOfParticles;
  final Color color;

  const ParticleBackground({
    super.key,
    this.numberOfParticles = 50,
    required this.color,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();
    final random = Random();

    particles = List.generate(widget.numberOfParticles, (index) {
      // Subtle color variations
      final c = widget.color;

      final colorVariation = Color.fromARGB(
        ((0.6 + random.nextDouble() * 0.4) * 255).round(),
        (c.r * 255).round(),
        (c.g * 255).round(),
        (c.b * 255).round(),
      );

      return Particle(
        position: Offset(random.nextDouble() * 400, random.nextDouble() * 800),
        radius: random.nextDouble() * 4 + 2,
        color: colorVariation,
        velocity: Offset(
          (random.nextDouble() - 0.5) * 1.5,
          (random.nextDouble() - 0.5) * 1.5,
        ),
        pulsePhase: random.nextDouble() * 2 * pi,
        pulseSpeed: 1.5 + random.nextDouble() * 2,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(updateParticles);

    _controller.repeat();
  }

  void updateParticles() {
    if (!mounted) return;

    final size = MediaQuery.of(context).size;

    for (var p in particles) {
      // Smooth continuous movement
      var newPos = p.position + p.velocity;

      // Seamless edge wrapping
      if (newPos.dx > size.width) newPos = Offset(0, newPos.dy);
      if (newPos.dx < 0) newPos = Offset(size.width, newPos.dy);
      if (newPos.dy > size.height) newPos = Offset(newPos.dx, 0);
      if (newPos.dy < 0) newPos = Offset(newPos.dx, size.height);

      p.position = newPos;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: ParticlePainter(
        particles: particles,
        animationValue: _controller.value * 2 * pi,
      ),
    );
  }
}
