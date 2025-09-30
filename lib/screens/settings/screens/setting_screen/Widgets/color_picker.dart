import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/themes/cubit/theme_cubit.dart';

class ColorPickerSheet extends StatelessWidget {
  final ValueChanged<Color> onColorSelected;

  const ColorPickerSheet({super.key, required this.onColorSelected});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> colors = [
      {"color": const Color.fromARGB(255, 145, 94, 234), "name": "Purple"},
      {"color": Colors.redAccent, "name": "Red"},
      {"color": Colors.pinkAccent, "name": "Pink"},
      {"color": Colors.green, "name": "Green"},
      {"color": Colors.blue, "name": "Blue"},
      {"color": Colors.orangeAccent, "name": "Orange"},
      {"color": Colors.teal, "name": "Teal"},
      {"color": Colors.indigo, "name": "Indigo"},
      {"color": Colors.amber, "name": "Amber"},
      {"color": Colors.cyan, "name": "Cyan"},
      {"color": Colors.brown, "name": "Brown"},
      {"color": Colors.lime, "name": "Lime"},
    ];

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 15),
          itemCount: colors.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final color = colors[index]["color"] as Color;
            final name = colors[index]["name"] as String;
            final isSelected = state.primaryColor == color;

            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withOpacity(0.6),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check, color: Colors.white, size: 28),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? color : null,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
