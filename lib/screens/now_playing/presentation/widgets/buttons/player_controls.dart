import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/cubit/player_settings_cubit.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/dialogues/speed_dialogue.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/dialogues/volume_dialogue.dart';

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
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: state.shuffle ? Colors.pinkAccent : Colors.grey,
              ),
              onPressed: cubit.toggleShuffle,
            ),

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

            IconButton(
              icon: StreamBuilder(
                stream: audioHandler.speedStream,
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.data != null &&
                      asyncSnapshot.data! != 1.0) {
                    return const Icon(Icons.speed, color: Colors.pinkAccent);
                  }
                  return const Icon(Icons.speed, color: Colors.grey);
                },
              ),
              onPressed: () {
                showSpeedDialog(context);
              },
            ),

            IconButton(
              icon: StreamBuilder(
                stream: audioHandler.volumeStream,
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.data != null &&
                      asyncSnapshot.data! != 1.0) {
                    return const Icon(
                      Icons.volume_up,
                      color: Colors.pinkAccent,
                    );
                  }
                  return const Icon(Icons.volume_up, color: Colors.grey);
                },
              ),
              onPressed: () {
                showVolumeDialog(context);
              },
            ),
          ],
        );
      },
    );
  }
}
