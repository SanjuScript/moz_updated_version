import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  final double radius;
  final Color color;
  Offset velocity;
  double phase;
  double pulseSpeed;
  double maxRadius;
  double orbitRadius;
  double orbitSpeed;
  Offset orbitCenter;
  double glowIntensity;

  Particle({
    required this.position,
    required this.radius,
    required this.color,
    required this.velocity,
  }) : phase = Random().nextDouble() * 2 * pi,
       pulseSpeed = 0.8 + Random().nextDouble() * 2.0,
       maxRadius = radius,
       orbitRadius = 20 + Random().nextDouble() * 40,
       orbitSpeed = 0.3 + Random().nextDouble() * 0.7,
       orbitCenter = position,
       glowIntensity = 0.5 + Random().nextDouble() * 0.5;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final ui.FragmentShader? shader;
  final Color baseColor;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.baseColor,
    this.shader,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (shader != null) {
      _paintWithShader(canvas, size);
    } else {
      _paintFallback(canvas, size);
    }
  }

  void _paintWithShader(Canvas canvas, Size size) {
    // Set shader uniforms (minimal - just screen size and time!)
    shader!.setFloat(0, size.width);
    shader!.setFloat(1, size.height);
    shader!.setFloat(2, animationValue);

    // Apply color tint
    final paint = Paint()
      ..shader = shader
      ..colorFilter = ColorFilter.mode(
        baseColor.withValues(alpha: 0.9),
        BlendMode.modulate,
      );

    canvas.drawRect(Offset.zero & size, paint);
  }

  void _paintFallback(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Optimized connections
    final connectionPaint = Paint()
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final dx = particles[i].position.dx - particles[j].position.dx;
        final dy = particles[i].position.dy - particles[j].position.dy;
        final distSq = dx * dx + dy * dy;

        if (distSq < 22500) {
          final distance = sqrt(distSq);
          final opacity = pow((1 - distance / 150), 2) * 0.35;

          connectionPaint.color = particles[i].color.withValues(alpha: opacity);
          canvas.drawLine(
            particles[i].position,
            particles[j].position,
            connectionPaint,
          );
        }
      }
    }

    // Draw particles
    for (var p in particles) {
      final pulseValue = sin(animationValue * p.pulseSpeed + p.phase);
      final currentRadius = p.maxRadius * (0.8 + pulseValue * 0.2);

      // Outer glow layers
      paint.color = p.color.withValues(alpha: 0.08);
      canvas.drawCircle(p.position, currentRadius * 4, paint);

      paint.color = p.color.withValues(alpha: 0.15);
      canvas.drawCircle(p.position, currentRadius * 2.5, paint);

      // Core gradient
      final gradient = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.8),
          p.color.withValues(alpha: 1.0),
          p.color.withValues(alpha: 0.6),
          p.color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );

      paint.shader = gradient.createShader(
        Rect.fromCircle(center: p.position, radius: currentRadius * 1.5),
      );
      canvas.drawCircle(p.position, currentRadius * 1.5, paint);
      paint.shader = null;
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
  final Random _random = Random();
  int _frameCount = 0;
  ui.FragmentShader? _shader;
  bool _shaderFailed = false;

  @override
  void initState() {
    super.initState();
    _initParticles();
    _loadShader();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 365),
    )..addListener(_updateParticles);

    _controller.repeat();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/particles.frag',
      );
      if (mounted) {
        setState(() {
          _shader = program.fragmentShader();
        });
      }
    } catch (e) {
      _shaderFailed = true;
      debugPrint('Shader not available, using CPU fallback: $e');
    }
  }

  void _initParticles() {
    particles = List.generate(widget.numberOfParticles, (index) {
      final speed = 0.4 + _random.nextDouble() * 1.0;
      final angle = _random.nextDouble() * 2 * pi;

      return Particle(
        position: Offset(
          _random.nextDouble() * 400,
          _random.nextDouble() * 800,
        ),
        radius: _random.nextDouble() * 3.5 + 2.5,
        color: widget.color.withValues(alpha: 0.6 + _random.nextDouble() * 0.4),
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
      );
    });
  }

  void _updateParticles() {
    if (!mounted) return;

    _frameCount++;
    final animationValue = _frameCount * 0.025;

    // Only update physics if using CPU fallback
    if (_shader == null && !_shaderFailed) return;

    if (_shader == null) {
      final size = MediaQuery.of(context).size;

      for (int i = 0; i < particles.length; i++) {
        var p = particles[i];

        // Orbital motion
        final orbitAngle = animationValue * p.orbitSpeed + p.phase;
        final orbitX = cos(orbitAngle) * p.orbitRadius * 0.3;
        final orbitY = sin(orbitAngle) * p.orbitRadius * 0.3;

        // Interaction forces
        double forceX = 0;
        double forceY = 0;

        for (int j = 0; j < particles.length; j++) {
          if (i == j) continue;
          final other = particles[j];
          final dx = other.position.dx - p.position.dx;
          final dy = other.position.dy - p.position.dy;
          final distSq = dx * dx + dy * dy;

          if (distSq < 10000 && distSq > 0) {
            final dist = sqrt(distSq);
            final forceMag = (100 - dist) / 1000;
            forceX -= dx / dist * forceMag;
            forceY -= dy / dist * forceMag;
          }
        }

        // Update position
        final newX = p.position.dx + p.velocity.dx + orbitX * 0.1 + forceX;
        final newY = p.position.dy + p.velocity.dy + orbitY * 0.1 + forceY;

        // Wrap around
        const margin = 50.0;
        var finalX = newX;
        var finalY = newY;

        if (newX > size.width + margin) {
          finalX = -margin;
        } else if (newX < -margin) {
          finalX = size.width + margin;
        }

        if (newY > size.height + margin) {
          finalY = -margin;
        } else if (newY < -margin) {
          finalY = size.height + margin;
        }

        p.position = Offset(finalX, finalY);
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: ParticlePainter(
          particles: particles,
          animationValue: _frameCount * 0.025,
          baseColor: widget.color,
          shader: _shader,
        ),
      ),
    );
  }
}
