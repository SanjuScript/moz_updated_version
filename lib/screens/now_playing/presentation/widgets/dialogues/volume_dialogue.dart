import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/cubit/player_settings_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/froasted_dialogue.dart';

void showVolumeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => FrostedDialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<PlayerSettingsCubit, PlayerSettingsState>(
          builder: (context, state) {
            double tempVolume = 1.0;
            tempVolume = state.volume;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Volume Control",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 20),

                StatefulBuilder(
                  builder: (context, setStateSB) {
                    return Column(
                      children: [
                        CupertinoSlider(
                          min: 0,
                          max: 1,
                          value: tempVolume,
                          onChanged: (val) {
                            setStateSB(() => tempVolume = val);
                            final cubit = BlocProvider.of<PlayerSettingsCubit>(
                              context,
                              listen: false,
                            );
                            cubit.setVolume(val);
                          },
                        ),
                        Text(
                          " ${((tempVolume * 100).toInt())}%",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
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
