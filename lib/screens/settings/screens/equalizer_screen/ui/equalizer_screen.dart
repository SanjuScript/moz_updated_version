import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/animations/custom_paint_animations/audio_wave.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/cubit/equalizer_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_appbar.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_bands_section.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_effect_control_card.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_preference_saver.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_preset_section.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_section_header_icons.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_visualizer_header.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/Widgets/custom_switch.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';
import 'package:moz_updated_version/services/equillizer_service.dart';

import '../../../../../services/core/app_services.dart';
import 'dart:math' as math;

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    // _fftTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  String _formatFrequency(int millihertz) {
    final hz = millihertz / 1000;
    if (hz >= 1000) {
      return '${(hz / 1000).toStringAsFixed(1)}k';
    }
    return '${hz.round()}';
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: EqualizerAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.1),
              Theme.of(context).primaryColor.withValues(alpha: 0.4),
            ],
          ),
        ),
        child: BlocConsumer<EqualizerCubit, EqualizerState>(
          listener: (context, state) {
            if (state is EqualizerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.red.shade900,
                ),
              );
            }

            // Initialize visualizer when state becomes loaded
            if (state is EqualizerLoaded) {
              // _initVisualizer();
            }
          },
          builder: (context, state) {
            if (state is EqualizerLoading || state is EqualizerInitial) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Loading Equalizer...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is EqualizerError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is! EqualizerLoaded) {
              return const SizedBox.shrink();
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              children: [
                VisualizerHeader(state: state, waveController: _waveController),
                const SizedBox(height: 24),

                EqualizerPresetsSection(
                  presets: state.presets,
                  currentPreset: state.data.currentPreset,
                ),

                const SizedBox(height: 24),

                EqualizerBandsSection(state: state),
                const SizedBox(height: 24),

                SectionHeader(icon: Icons.auto_awesome, title: "Audio Effects"),

                const SizedBox(height: 16),

                // Bass Boost
                EffectControlCard(
                  title: "Bass Boost",
                  icon: Icons.music_note,
                  enabled: state.data.bassBoost.enabled,
                  value: state.data.bassBoost.strength.toDouble(),
                  color: Colors.deepPurple,
                  onEnabledChanged: (v) =>
                      context.read<EqualizerCubit>().toggleBassBoost(v),
                  onValueChanged: (v) =>
                      context.read<EqualizerCubit>().setBassBoost(v),
                ),
                SizedBox(height: 16),

                EffectControlCard(
                  title: "Virtualizer",
                  subtitle: "3D Surround Effect",
                  icon: Icons.surround_sound,
                  enabled: state.data.virtualizer.enabled,
                  value: state.data.virtualizer.strength.toDouble(),
                  color: Colors.cyan,
                  onEnabledChanged: (v) =>
                      context.read<EqualizerCubit>().toggleVirtualizer(v),
                  onValueChanged: (v) =>
                      context.read<EqualizerCubit>().setVirtualizer(v),
                ),
                SizedBox(height: 16),

                EffectControlCard(
                  title: "Loudness Enhancer",
                  icon: Icons.volume_up,
                  enabled: state.data.loudness.enabled,
                  value: state.data.loudness.gain.toDouble(),
                  max: 3000,
                  color: Colors.orange,
                  onEnabledChanged: (v) =>
                      context.read<EqualizerCubit>().toggleLoudness(v),
                  onValueChanged: (v) =>
                      context.read<EqualizerCubit>().setLoudness(v),
                ),

                const SizedBox(height: 32),

                SectionHeader(icon: Icons.eco, title: "Environmental Reverb"),
                const SizedBox(height: 16),

                // Reverb WEIGHT control
                EffectControlCard(
                  title: "Room Level",
                  icon: Icons.home,
                  enabled: state.data.reverb.enabled,
                  value: 0,
                  color: Colors.green,
                  onEnabledChanged: (v) {
                    // context.read<EqualizerCubit>().toggleReverb(v),
                  },
                  onValueChanged: (v) => context
                      .read<EqualizerCubit>()
                      .setEnvironmentalReverbProperty("roomLevel", v.round()),
                ),
                const SizedBox(height: 16),

                // ===== VISUALIZER =====
                SectionHeader(icon: Icons.graphic_eq, title: "FFT Visualizer"),
                const SizedBox(height: 8),
                BlocBuilder<EqualizerCubit, EqualizerState>(
                  buildWhen: (p, n) =>
                      p is EqualizerLoaded &&
                      n is EqualizerLoaded &&
                      p.fft != n.fft,
                  builder: (context, state) {
                    final fft = (state as EqualizerLoaded).fft;
                    return Container(
                      height: 140,
                      child: CustomPaint(
                        painter: RadialVisualizerPainter(
                          fft,
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}

class RadialVisualizerPainter extends CustomPainter {
  final List<int> fft;
  final Color color;

  /// Static (no rotation). Keep it for future if you want to rotate.
  final double rotation; // radians

  /// How many bars around the circle
  final int barCount;

  /// Visual tuning knobs
  final double innerRadiusFactor; // 0..0.5 of min(size)
  final double barWidth;
  final double maxBarExtensionFactor; // 0..1 of min(size)
  final double glowBlurSigma;

  RadialVisualizerPainter(
    this.fft,
    this.color, {
    this.rotation = 0.0,
    this.barCount = 64,
    this.innerRadiusFactor = 0.28,
    this.barWidth = 6,
    this.maxBarExtensionFactor = 0.32,
    this.glowBlurSigma = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fft.isEmpty) return;

    final minSide = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);

    // geometry
    final innerR = minSide * innerRadiusFactor;
    final maxExt = minSide * maxBarExtensionFactor; // max bar height
    final sweep = (2 * math.pi) / barCount;

    // average FFT bins down to barCount
    final bins = fft.length ~/ 2;
    final step = math.max(1, bins ~/ barCount);
    final reduced = <double>[];
    for (int i = 0; i < bins; i += step) {
      double sum = 0;
      int end = math.min(bins, i + step);
      for (int j = i; j < end; j++) {
        sum += fft[j].abs();
      }
      reduced.add(sum / (end - i));
      if (reduced.length == barCount) break;
    }
    // pad if needed
    while (reduced.length < barCount) reduced.add(0);

    // paints
    final glowPaint = Paint()
      ..color = color.withOpacity(0.85)
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, glowBlurSigma);

    // gradient along each bar (root → tip)
    // we’ll create per-bar shader rect; cheap enough at 60 fps for 64 bars.
    Paint barPaintForRect(Rect r) => Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [color.withOpacity(0.95), color.withOpacity(0.25)],
      ).createShader(r);

    // optional thin inner ring (looks premium)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withOpacity(0.25);
    canvas.drawCircle(center, innerR, ringPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    for (int i = 0; i < barCount; i++) {
      // normalize mag (tweak 128..160 depending on your FFT scale)
      final m = reduced[i];
      final norm = (m / 130.0).clamp(0.0, 1.0);
      final h = (norm * maxExt).clamp(6.0, maxExt); // ensure visible

      canvas.save();
      canvas.rotate(i * sweep);

      // each bar is drawn "upwards" from the circle perimeter
      final rect = Rect.fromLTWH(-barWidth / 2, -(innerR + h), barWidth, h);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(barWidth));

      // glow first
      canvas.drawRRect(rrect, glowPaint);

      // fill with gradient
      canvas.drawRRect(rrect, barPaintForRect(rect));

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RadialVisualizerPainter old) {
    return old.fft != fft || old.color != color;
  }
}
