import 'package:flutter/material.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/Widgets/custom_switch.dart';

class EffectControlCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool enabled;
  final double value;
  final Color color;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double> onValueChanged;
  final double min;
  final double max;

  const EffectControlCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.enabled,
    required this.value,
    required this.color,
    required this.onEnabledChanged,
    required this.onValueChanged,
    this.min = 0,
    this.max = 1000,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
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
          width: 1.4,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.22),
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
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildSlider(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(colors: [color, color.withValues(alpha: 0.7)])
                : null,
            color: enabled ? null : Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: enabled ? color : null,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: enabled ? color : null,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        CustomSwitch(
          value: enabled,
          color: color,
          onChanged: onEnabledChanged,
          // activeColor: color,
          // activeTrackColor: color.withValues(alpha: 0.4),
        ),
      ],
    );
  }

  Widget _buildSlider(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1 : .45,
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Intensity",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: enabled ? color : null,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: enabled
                      ? LinearGradient(
                          colors: [color, color.withValues(alpha: 0.6)],
                        )
                      : null,
                  color: enabled ? null : Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${(value / max * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              thumbColor: color,
              activeColor: color,
              onChanged: enabled ? onValueChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}
