import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/cubit/player_settings_cubit.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/dialogues/speed_dialogue.dart';
import 'package:moz_updated_version/screens/now_playing/presentation/widgets/dialogues/volume_dialogue.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/buttons/platform_button.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final isIos = sl<ThemeCubit>().isIos;

    return BlocBuilder<PlayerSettingsCubit, PlayerSettingsState>(
      builder: (context, state) {
        final cubit = context.read<PlayerSettingsCubit>();
        log(state.shuffle.toString());
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            PlatformButton(
              isIos: isIos,
              materialIcon: Icons.shuffle,
              cupertinoIcon: CupertinoIcons.shuffle,
              color: state.shuffle ? Theme.of(context).primaryColor : Colors.grey,
              onPressed: cubit.toggleShuffle,
            ),
            
            PlatformButton(
              isIos: isIos,
              materialIcon: state.repeatMode == RepeatMode.off
                  ? Icons.repeat
                  : state.repeatMode == RepeatMode.all
                  ? Icons.repeat
                  : Icons.repeat_one,
              cupertinoIcon: state.repeatMode == RepeatMode.off
                  ? CupertinoIcons.repeat
                  : state.repeatMode == RepeatMode.all
                  ? CupertinoIcons.repeat
                  : CupertinoIcons.repeat_1,
              color: state.repeatMode == RepeatMode.off
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
              onPressed: cubit.changeRepeatMode,
            ),
            
            StreamBuilder<double>(
              stream: audioHandler.speedStream,
              builder: (context, snapshot) {
                final speed = snapshot.data ?? 1.0;
                return PlatformButton(
                  isIos: isIos,
                  materialIcon: Icons.speed,
                  cupertinoIcon: CupertinoIcons.speedometer,
                  color: speed != 1.0 ? Theme.of(context).primaryColor : Colors.grey,
                  onPressed: () => showSpeedDialog(context),
                );
              },
            ),
            
            StreamBuilder<double>(
              stream: audioHandler.volumeStream,
              builder: (context, snapshot) {
                final volume = snapshot.data ?? 1.0;
                return PlatformButton(
                  isIos: isIos,
                  materialIcon: Icons.volume_up,
                  cupertinoIcon: CupertinoIcons.volume_up,
                  color: volume != 1.0 ? Theme.of(context).primaryColor : Colors.grey,
                  onPressed: () => showVolumeDialog(context),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
