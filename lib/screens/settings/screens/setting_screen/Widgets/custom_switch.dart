import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class CustomSwitch extends StatelessWidget {
  final bool? value;
  final void Function(bool)? onChanged;
  const CustomSwitch({super.key, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value!,
      onChanged: onChanged,
      trackOutlineWidth: const WidgetStatePropertyAll(0),
      activeColor: Colors.pink.shade300,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.withValues(alpha:0.6),
      activeTrackColor: Colors.pink.shade100,
    );
  }
}
