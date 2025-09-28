import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/cubit/player_settings_cubit.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/screens/playlist_screen/presentation/widgets/froasted_dialogue.dart';
import 'package:moz_updated_version/services/service_locator.dart';

void showSpeedDialog(BuildContext context) {
  if (sl<ThemeCubit>().isIos) {
    showCupertinoDialog(
      context: context,
      builder: (_) => FrostedDialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _SpeedContent(isIos: true),
        ),
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (_) => FrostedDialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _SpeedContent(isIos: false),
        ),
      ),
    );
  }
}

class _SpeedContent extends StatelessWidget {
  final bool isIos;
  const _SpeedContent({required this.isIos});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerSettingsCubit, PlayerSettingsState>(
      builder: (context, state) {
        double currentSpeed = state.speed;

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

            _buildSpeedSelector(
              context,
              "0.5x",
              0.5,
              currentSpeed == 0.5,
              isIos,
            ),
            _buildSpeedSelector(
              context,
              "0.8x",
              0.8,
              currentSpeed == 0.8,
              isIos,
            ),
            _buildSpeedSelector(
              context,
              "1.0x",
              1.0,
              currentSpeed == 1.0,
              isIos,
            ),
            _buildSpeedSelector(
              context,
              "1.5x",
              1.5,
              currentSpeed == 1.5,
              isIos,
            ),
            _buildSpeedSelector(
              context,
              "2.0x",
              2.0,
              currentSpeed == 2.0,
              isIos,
            ),

            const SizedBox(height: 20),
            _buildCloseButton(context, isIos),
          ],
        );
      },
    );
  }
}

Widget _buildSpeedSelector(
  BuildContext context,
  String label,
  double value,
  bool isSelected,
  bool isIos,
) {
  final cubit = BlocProvider.of<PlayerSettingsCubit>(context, listen: false);

  return SizedBox(
    height: 50,
    width: double.infinity,
    child: isIos
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              cubit.setSpeed(value);
              Navigator.pop(context);
            },
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : CupertinoColors.systemGrey,
              ),
            ),
          )
        : TextButton(
            onPressed: () {
              cubit.setSpeed(value);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.transparent,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).unselectedWidgetColor,
              ),
            ),
          ),
  );
}

Widget _buildCloseButton(BuildContext context, bool isIos) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      isIos
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Close",
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            )
          : TextButton(
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
