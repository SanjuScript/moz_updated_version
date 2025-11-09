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

                SavePreferenceButton(
                  onSave: () {},
                  enabled: true,
                  onToggle: (onToggle) {},
                ),
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

  Widget _buildEffectSection(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required bool enabled,
    required double value,
    required Color color,
    required ValueChanged<bool> onEnabledChanged,
    required ValueChanged<double> onValueChanged,
    double min = 0,
    double max = 1000,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: enabled
            ? LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: enabled
            ? null
            : Theme.of(context).cardColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: enabled
              ? color.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: enabled
                        ? LinearGradient(
                            colors: [color, color.withValues(alpha: 0.7)],
                          )
                        : null,
                    color: enabled ? null : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: enabled
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: enabled ? color : null,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: enabled ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 200),
                  child: Transform.scale(
                    scale: 1.1,
                    child: Switch(
                      value: enabled,
                      onChanged: onEnabledChanged,
                      activeColor: color,
                      activeTrackColor: color.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: enabled ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Intensity',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: enabled
                              ? LinearGradient(
                                  colors: [color, color.withValues(alpha: 0.7)],
                                )
                              : null,
                          color: enabled
                              ? null
                              : Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(value / max * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 8,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                            elevation: 4,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 24,
                          ),
                          activeTrackColor: enabled ? color : Colors.grey,
                          inactiveTrackColor: enabled
                              ? color.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.2),
                          thumbColor: enabled ? color : Colors.grey,
                          overlayColor: enabled
                              ? color.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.2),
                          activeTickMarkColor: Colors.transparent,
                          inactiveTickMarkColor: Colors.transparent,
                        ),
                        child: Slider(
                          value: value.clamp(min, max),
                          min: min,
                          max: max,
                          divisions: 100,
                          onChanged: enabled ? onValueChanged : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
