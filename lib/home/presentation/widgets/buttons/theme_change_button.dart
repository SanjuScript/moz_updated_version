import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';
import 'package:moz_updated_version/core/themes/custom_theme.dart';

class ChangeThemeButtonWidget extends StatelessWidget {
  final bool visibility;
  final bool changeIcon;
  const ChangeThemeButtonWidget({
    super.key,
    this.visibility = false,
    this.changeIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark = state.themeData == CustomThemes.darkThemeMode;

        if (changeIcon) {
          return Switch(
            value: isDark,
            onChanged: (_) {
              isDark
                  ? context.read<ThemeCubit>().setLightMode()
                  : context.read<ThemeCubit>().setDarkMode();
            },
          );
        } else {
          return InkWell(
            onTap: () {
              isDark
                  ? context.read<ThemeCubit>().setLightMode()
                  : context.read<ThemeCubit>().setDarkMode();
            },
            borderRadius: BorderRadius.circular(10),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: isDark ? Colors.white : Colors.black,
            ),
          );
        }
      },
    );
  }
}
