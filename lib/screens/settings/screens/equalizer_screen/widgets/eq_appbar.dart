import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/cubit/equalizer_cubit.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/Widgets/custom_switch.dart';
import 'package:moz_updated_version/screens/song_list_screen/presentation/widgets/buttons/theme_change_button.dart';

class EqualizerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EqualizerAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Text(
        'Audio Equalizer',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Theme.of(context).primaryColor,
          fontSize: 20,
        ),
      ),

      actions: [
        BlocBuilder<EqualizerCubit, EqualizerState>(
          builder: (context, state) {
            if (state is EqualizerLoaded) {
              return AnimatedScale(
                scale: state.data.enabled ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          state.data.enabled
                              ? Icons.graphic_eq
                              : Icons.graphic_eq_outlined,
                          size: 18,
                          color: state.data.enabled
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white54,
                        ),
                      ),
                      CustomSwitch(
                        value: state.data.enabled,
                        onChanged: (value) {
                          context.read<EqualizerCubit>().toggleEqualizer(value);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
