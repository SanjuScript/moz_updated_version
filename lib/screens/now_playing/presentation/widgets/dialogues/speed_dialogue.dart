import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/cubit/player_settings_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/froasted_dialogue.dart';

void showSpeedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => FrostedDialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<PlayerSettingsCubit, PlayerSettingsState>(
          builder: (context, state) {
            double currentSpeed = 1.0;
            currentSpeed = state.speed;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Speed Controls",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 20),

                _buildSpeedSelector(context, "0.5x", 0.5, currentSpeed == 0.5),

                _buildSpeedSelector(context, "0.8x", 0.8, currentSpeed == 0.8),

                _buildSpeedSelector(context, "1.0x", 1.0, currentSpeed == 1.0),

                _buildSpeedSelector(context, "1.5x", 1.5, currentSpeed == 1.5),

                _buildSpeedSelector(context, "2.0x", 2.0, currentSpeed == 2.0),

                const SizedBox(height: 20),
                _buildCloseButton(context),
              ],
            );
          },
        ),
      ),
    ),
  );
}

Widget _buildSpeedSelector(
  BuildContext context,
  String label,
  double value,
  bool isSelected,
) {
  return SizedBox(
    height: 50,
    width: double.infinity,
    child: TextButton(
      onPressed: () {
        final cubit = BlocProvider.of<PlayerSettingsCubit>(
          context,
          listen: false,
        );
        cubit.setSpeed(value);
        Navigator.pop(context);
      },
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.transparent,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          color: isSelected
              ? Colors.pinkAccent
              : Theme.of(context).unselectedWidgetColor,
        ),
      ),
    ),
  );
}

Widget _buildCloseButton(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          "Close",
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).disabledColor,
          ),
        ),
      ),
    ],
  );
}
