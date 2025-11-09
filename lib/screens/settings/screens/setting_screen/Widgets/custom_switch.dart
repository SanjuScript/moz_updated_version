import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool? value;
  final void Function(bool)? onChanged;
  final Color? color;

  const CustomSwitch({super.key, this.value, this.onChanged, this.color});

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value ?? false,
      onChanged: onChanged,
      activeTrackColor: color ?? Theme.of(context).primaryColor,
      inactiveTrackColor: Colors.grey.withValues(alpha: 0.6),
    );
  }
}
