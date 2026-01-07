import 'package:flutter/material.dart';

class AnimatedInstrumentalIndicator extends StatefulWidget {
  final bool isActive;

  const AnimatedInstrumentalIndicator({super.key, required this.isActive});

  @override
  State<AnimatedInstrumentalIndicator> createState() =>
      _AnimatedInstrumentalIndicatorState();
}

class _AnimatedInstrumentalIndicatorState
    extends State<AnimatedInstrumentalIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _wave1Animation;
  late Animation<double> _wave2Animation;
  late Animation<double> _wave3Animation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the main icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave animation for the bars
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _wave1Animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _wave2Animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    _wave3Animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      opacity: widget.isActive ? 1.0 : 0.4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated music note icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Icon(
                  Icons.music_note_rounded,
                  size: widget.isActive ? 28 : 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          // Animated sound wave bars
          if (widget.isActive)
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildWaveBar(_wave1Animation.value, 16),
                    const SizedBox(width: 3),
                    _buildWaveBar(_wave2Animation.value, 20),
                    const SizedBox(width: 3),
                    _buildWaveBar(_wave3Animation.value, 14),
                    const SizedBox(width: 3),
                    _buildWaveBar(_wave1Animation.value, 18),
                  ],
                );
              },
            ),

          const SizedBox(width: 12),

          // Text label
          Text(
            'Instrumental',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBar(double heightFactor, double maxHeight) {
    return Container(
      width: 3,
      height: maxHeight * heightFactor,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
