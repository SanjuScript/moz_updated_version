import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/cubit/equalizer_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_appbar.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_bands_section.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_effect_control_card.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_preset_section.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_section_header_icons.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_visualizer_header.dart';

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
              ],
            );
          },
        ),
      ),
    );
  }
}
