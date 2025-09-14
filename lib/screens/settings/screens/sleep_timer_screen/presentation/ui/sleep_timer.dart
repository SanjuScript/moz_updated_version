import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/animations/custom_paint_animations/particle_animations.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/cubit/sleeptimer_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/widgets/buttons/mode_button.dart';

class SleepTimerScreen extends StatelessWidget {
  const SleepTimerScreen({super.key});

  String _formatDuration(int totalSeconds) {
    final min = totalSeconds ~/ 60;
    final sec = totalSeconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ParticleBackground(),
          Padding(
            padding: const EdgeInsets.all(25),
            child: BlocBuilder<SleepTimerCubit, SleepTimerState>(
              builder: (context, state) {
                final cubit = context.read<SleepTimerCubit>();

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Sleep Timer",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 30),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ModeButton(
                                    label: "Track",
                                    isTrack: true,
                                    isTrackMode: state.isTrackMode,
                                    isRunning: state.isRunning,
                                  ),
                                  const SizedBox(width: 20),
                                  ModeButton(
                                    label: "Timer",
                                    isTrack: false,
                                    isTrackMode: state.isTrackMode,
                                    isRunning: state.isRunning,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              state.isTrackMode
                                  ? Column(
                                      children: [
                                        Text(
                                          "${state.trackCount.toInt()} Tracks",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(fontSize: 20),
                                        ),
                                        Slider(
                                          min: 1,
                                          max: 20,
                                          divisions: 19,
                                          value: state.isRunning
                                              ? state.tracksLeft
                                                    .clamp(1, 20)
                                                    .toDouble()
                                              : state.trackCount
                                                    .clamp(1, 20)
                                                    .toDouble(),
                                          activeColor: Colors.pinkAccent,
                                          inactiveColor: Colors.grey[300],
                                          onChanged: state.isRunning
                                              ? null
                                              : cubit.setTrackCount,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Text(
                                          "${state.timerMinutes.toInt()} min",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(fontSize: 20),
                                        ),
                                        Slider(
                                          min: 1,
                                          max: 120,
                                          value: state.isRunning
                                              ? (state.remainingSeconds / 60)
                                                    .clamp(1, 120)
                                                    .toDouble()
                                              : state.timerMinutes.clamp(
                                                  1,
                                                  120,
                                                ),
                                          activeColor: Colors.pinkAccent,
                                          inactiveColor: Colors.grey[300],
                                          onChanged: state.isRunning
                                              ? null
                                              : cubit.setTimerMinutes,
                                        ),
                                      ],
                                    ),
                              const SizedBox(height: 30),

                              if (state.isRunning)
                                Text(
                                  state.isTrackMode
                                      ? "Tracks left: ${state.tracksLeft}"
                                      : "Time left: ${_formatDuration(state.remainingSeconds)}",
                                  style: const TextStyle(
                                    color: Colors.pinkAccent,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(height: 30),

                              GestureDetector(
                                onTap: state.isRunning
                                    ? cubit.stopTimer
                                    : cubit.startTimer,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: state.isRunning
                                        ? Colors.redAccent
                                        : Colors.pinkAccent,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.pinkAccent.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    state.isRunning ? "Stop" : "Start",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
