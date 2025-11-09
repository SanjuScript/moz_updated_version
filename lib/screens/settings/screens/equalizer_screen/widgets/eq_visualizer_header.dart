import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/animations/custom_paint_animations/audio_wave.dart';
import '../cubit/equalizer_cubit.dart';

class VisualizerHeader extends StatelessWidget {
  final EqualizerLoaded state;
  final AnimationController waveController;

  const VisualizerHeader({
    super.key,
    required this.state,
    required this.waveController,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return AnimatedBuilder(
      animation: waveController,
      builder: (context, _) {
        return Container(
          height: size.height * .15,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: WaveformPainter(
                    animation: waveController,
                    color: Theme.of(context).colorScheme.primary,
                    enabled: state.data.enabled,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.graphic_eq,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.data.enabled
                            ? 'Equalizer Active'
                            : 'Equalizer Inactive',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
