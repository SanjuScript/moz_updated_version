import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformButton extends StatelessWidget {
  final bool isIos;
  final IconData materialIcon;
  final IconData cupertinoIcon;
  final Color color;
  final double size;
  final VoidCallback onPressed;

  const PlatformButton({
    super.key,
    required this.isIos,
    required this.materialIcon,
    required this.cupertinoIcon,
    required this.color,
    required this.onPressed,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = PlatformIcon(
      isIos: isIos,
      materialIcon: materialIcon,
      cupertinoIcon: cupertinoIcon,
      color: color,
      size: size,
    );

    return isIos
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            child: iconWidget,
          )
        : IconButton(
            icon: iconWidget,
            onPressed: onPressed,
          );
  }
}

class PlatformIcon extends StatelessWidget {
  final bool isIos;
  final IconData materialIcon;
  final IconData cupertinoIcon;
  final Color color;
  final double size;

  const PlatformIcon({
    super.key,
    required this.isIos,
    required this.materialIcon,
    required this.cupertinoIcon,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      isIos ? cupertinoIcon : materialIcon,
      color: color,
      size: size,
    );
  }
}
