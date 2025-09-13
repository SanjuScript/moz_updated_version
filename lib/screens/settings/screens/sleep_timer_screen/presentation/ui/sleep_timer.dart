import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/cubit/sleeptimer_cubit.dart';

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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: BlocBuilder<SleepTimerCubit, SleepTimerState>(
            builder: (context, state) {
              final cubit = context.read<SleepTimerCubit>();

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main Card
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Sleep Timer",
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 30),

                        // Mode toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _modeButton(
                              context,
                              "Track",
                              true,
                              state.isTrackMode,
                              state.isRunning,
                            ),
                            const SizedBox(width: 20),
                            _modeButton(
                              context,
                              "Timer",
                              false,
                              state.isTrackMode,
                              state.isRunning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Slider
                        state.isTrackMode
                            ? Column(
                                children: [
                                  Text(
                                    "${state.trackCount.toInt()} Tracks",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Slider(
                                    min: 1,
                                    max: 20,
                                    divisions: 19,
                                    value: state.isRunning
                                        ? state.tracksLeft
                                              .clamp(1, 20)
                                              .toDouble() // clamp to avoid 0
                                        : state.trackCount
                                              .clamp(1, 20)
                                              .toDouble(),
                                    activeColor: Colors.pinkAccent,
                                    inactiveColor: Colors.white24,
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
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Slider(
                                    min: 1,
                                    max: 120,
                                    value: state.isRunning
                                        ? (state.remainingSeconds / 60)
                                              .clamp(1, 120)
                                              .toDouble() // clamp to avoid 0
                                        : state.timerMinutes.clamp(1, 120),
                                    activeColor: Colors.pinkAccent,
                                    inactiveColor: Colors.white24,
                                    onChanged: state.isRunning
                                        ? null
                                        : cubit.setTimerMinutes,
                                  ),
                                ],
                              ),
                        const SizedBox(height: 30),

                        // Remaining display
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

                        // Start / Stop Button
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
                                  color: Colors.pinkAccent.withOpacity(0.3),
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _modeButton(
    BuildContext context,
    String label,
    bool isTrack,
    bool isTrackMode,
    bool isRunning,
  ) {
    final cubit = context.read<SleepTimerCubit>();
    final isSelected = isTrackMode == isTrack;

    return GestureDetector(
      onTap: isRunning ? null : () => cubit.setTrackMode(isTrack),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.pinkAccent : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.pinkAccent : Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
