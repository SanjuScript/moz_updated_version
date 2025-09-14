import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/cubit/sleeptimer_cubit.dart';

class ModeButton extends StatelessWidget {
  final String label;
  final bool isTrack;
  final bool isTrackMode;
  final bool isRunning;

  const ModeButton({
    super.key,
    required this.label,
    required this.isTrack,
    required this.isTrackMode,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SleepTimerCubit>();
    final isSelected = isTrackMode == isTrack;

    return GestureDetector(
      onTap: isRunning ? null : () => cubit.setTrackMode(isTrack),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.pinkAccent : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.pinkAccent : Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
