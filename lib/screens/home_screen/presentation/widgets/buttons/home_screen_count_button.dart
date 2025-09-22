import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';

class HomePageButtons extends StatelessWidget {
  final Color color;
  final Widget child;

  const HomePageButtons({
    super.key,
    this.color = const Color.fromARGB(255, 241, 73, 171),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.2),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        buildWhen: (prev, curr) => prev.isDark != curr.isDark,
        builder: (context, state) {
          return Container(
            width: MediaQuery.sizeOf(context).width * 0.28,
            margin: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 8,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .9),
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(15),
              boxShadow: !state.isDark
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: .9),
                        spreadRadius: 2,
                        offset: const Offset(2, -2),
                      ),
                      BoxShadow(
                        color: color,
                        blurRadius: 8,
                        offset: const Offset(-2, 2),
                      ),
                    ]
                  : [],
            ),
            child: child,
          );
        },
      ),
    );
  }
}
