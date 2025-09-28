import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  final double radius;
  final Color color;
  Offset velocity;

  Particle({
    required this.position,
    required this.radius,
    required this.color,
    required this.velocity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      paint.color = p.color;
      canvas.drawCircle(p.position, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

class ParticleBackground extends StatefulWidget {
  final int numberOfParticles;
  final Color color;
  const ParticleBackground({super.key, this.numberOfParticles = 50, required this.color});

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

    particles = List.generate(
      widget.numberOfParticles,
      (index) => Particle(
        position: Offset(random.nextDouble() * 400, random.nextDouble() * 800),
        radius: random.nextDouble() * 4 + 2,
        color: widget.color.withValues(alpha: 0.6 + random.nextDouble() * 0.4),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 1.5,
          (random.nextDouble() - 0.5) * 1.5,
        ),
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(updateParticles);

    _controller.repeat();
  }

  void updateParticles() {
    final size = MediaQuery.of(context).size;

    for (var p in particles) {
      var newPos = p.position + p.velocity;

      // Wrap around edges
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
      painter: ParticlePainter(particles: particles),
    );
  }
}
