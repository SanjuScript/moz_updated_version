import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:moz_updated_version/core/animations/custom_paint_animations/particle_animations.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/cubit/sleeptimer_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/widgets/buttons/mode_button.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';

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
          ParticleBackground(color: Theme.of(context).primaryColor),
          Padding(
            padding: const EdgeInsets.all(25),
            child: BlocBuilder<SleepTimerCubit, SleepTimerState>(
              builder: (context, state) {
                final cubit = context.read<SleepTimerCubit>();

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LiquidGlassLayer(
                      settings: LiquidGlassSettings(
                        thickness: 40,
                        ambientStrength: 1.6,
                      ),
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 25),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            boxShadow: context.read<ThemeCubit>().isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                        48,
                                        0,
                                        0,
                                        0,
                                      ).withValues(alpha: 0.05),
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
                                  // ChangeThemeButtonWidget(),
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
                                          activeColor: Theme.of(
                                            context,
                                          ).primaryColor,
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
                                          activeColor: Theme.of(
                                            context,
                                          ).primaryColor,
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
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
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
                                        : Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.3),
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
