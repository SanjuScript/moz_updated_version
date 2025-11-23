import 'package:flutter/material.dart';

class AnimatedRemoveButton extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const AnimatedRemoveButton({
    super.key,
    required this.selectedCount,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final icColor = iconColor ?? Colors.white;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: selectedCount > 0 ? onTap : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: icColor),
            const SizedBox(width: 8),
            Text(
              "Remove ($selectedCount)",
              style: TextStyle(color: icColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
