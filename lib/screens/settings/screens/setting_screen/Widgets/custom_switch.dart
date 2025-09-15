import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool? value;
  final void Function(bool)? onChanged;

  const CustomSwitch({super.key, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value ?? false,
      onChanged: onChanged,
      activeTrackColor: Colors.pink.shade300,
      inactiveTrackColor: Colors.grey.withValues(alpha: 0.6),
    );
  }
}
