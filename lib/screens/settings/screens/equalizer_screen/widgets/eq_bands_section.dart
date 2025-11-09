import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/data/model/equalizer_data.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/widgets/eq_section_header_icons.dart';
import '../cubit/equalizer_cubit.dart';

class EqualizerBandsSection extends StatelessWidget {
  final EqualizerLoaded state;

  const EqualizerBandsSection({super.key, required this.state});

  String _formatFrequency(int millihertz) {
    final hz = millihertz / 1000;
    if (hz >= 1000) return '${(hz / 1000).toStringAsFixed(1)}kHz';
    return '${hz.round()}Hz';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              icon: Icons.equalizer,
              title: "Frequency Bands",
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 280,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: state.data.bands.asMap().entries.map((entry) {
                  final band = entry.value;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _bandDBBadge(context, band.level),
                          const SizedBox(height: 8),
                          _bandSlider(context, band),
                          const SizedBox(height: 8),
                          _bandFreqBadge(_formatFrequency(band.centerFreq)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bandDBBadge(BuildContext context, int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        (level / 100).toStringAsFixed(1),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _bandSlider(BuildContext context, BandData band) {
    return Expanded(
      child: RotatedBox(
        quarterTurns: 3,
        child: SliderTheme(
          data: SliderThemeData(
            trackHeight: 32,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 14,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            activeTrackColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.8),
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
            thumbColor: Theme.of(context).colorScheme.primary,
            overlayColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: band.level.toDouble(),
            min: band.minLevel.toDouble(),
            max: band.maxLevel.toDouble(),
            onChanged: state.data.enabled
                ? (v) =>
                      context.read<EqualizerCubit>().setBandLevel(band.index, v)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _bandFreqBadge(String freq) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        freq,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}
