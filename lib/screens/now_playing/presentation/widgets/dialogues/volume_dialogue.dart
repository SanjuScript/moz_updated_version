import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/cubit/player_settings_cubit.dart';

class VolumeDialog extends StatefulWidget {
  const VolumeDialog({super.key});

  @override
  State<VolumeDialog> createState() => _VolumeDialogState();
}

class _VolumeDialogState extends State<VolumeDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _tempVolume;

  @override
  void initState() {
    super.initState();
    final state = context.read<PlayerSettingsCubit>().state;
    _tempVolume = state.volume;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 18).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _sigma => _animation.value;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerSettingsCubit>();

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: .8),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Text(
                      "Volume Control",
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 20),

                    // Smooth slider
                    StatefulBuilder(
                      builder: (context, setStateSB) {
                        return Column(
                          children: [
                            Slider(
                              min: 0,
                              max: 1,
                              value: _tempVolume,
                              onChanged: (val) {
                                setStateSB(() => _tempVolume = val);
                                cubit.setVolume(val);
                              },
                            ),
                            Text(
                              " ${((_tempVolume * 100).toInt())}%",
                              style: TextStyle(
                                fontFamily: 'coolvetica',
                                fontSize: 16,
                                color: Theme.of(context).unselectedWidgetColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    _buildCloseButton(context),
                  ],
                ),
              ),
            ),
          );
        },
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
              fontFamily: 'coolvetica',
              fontSize: 16,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ),
      ],
    );
  }
}

void showVolumeDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor:  Theme.of(context).hintColor.withValues(alpha: .2),
    builder: (_) => const VolumeDialog(),
  );
}
