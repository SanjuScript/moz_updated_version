import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/cubit/player_settings_cubit.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerSettingsCubit, PlayerSettingsState>(
      builder: (context, state) {
        final cubit = context.read<PlayerSettingsCubit>();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 🔀 Shuffle
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: state.shuffle ? Colors.pinkAccent : Colors.grey,
              ),
              onPressed: cubit.toggleShuffle,
            ),

            // 🔁 Repeat
            IconButton(
              icon: Icon(
                state.repeatMode == RepeatMode.off
                    ? Icons.repeat
                    : state.repeatMode == RepeatMode.all
                        ? Icons.repeat
                        : Icons.repeat_one,
                color: state.repeatMode == RepeatMode.off
                    ? Colors.grey
                    : Colors.pinkAccent,
              ),
              onPressed: cubit.changeRepeatMode,
            ),

            // ⏩ Speed Button
            IconButton(
              icon: const Icon(Icons.speed, color: Colors.grey),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text("Playback Speed"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<double>(
                            value: state.speed,
                            items: const [
                              DropdownMenuItem(value: 0.5, child: Text("0.5x")),
                              DropdownMenuItem(value: 1.0, child: Text("1.0x")),
                              DropdownMenuItem(value: 1.25, child: Text("1.25x")),
                              DropdownMenuItem(value: 1.5, child: Text("1.5x")),
                              DropdownMenuItem(value: 2.0, child: Text("2.0x")),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                cubit.setSpeed(val);
                                Navigator.pop(ctx); // close dialog
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            // 🔊 Volume Button
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.grey),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    double tempVolume = state.volume;
                    return AlertDialog(
                      title: const Text("Volume"),
                      content: StatefulBuilder(
                        builder: (context, setStateSB) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Slider(
                                min: 0,
                                max: 1,
                                divisions: 10,
                                value: tempVolume,
                                onChanged: (val) {
                                  setStateSB(() => tempVolume = val);
                                  cubit.setVolume(val);
                                },
                              ),
                              Text(" ${(tempVolume * 100).toInt()}%"),
                            ],
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Close"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
