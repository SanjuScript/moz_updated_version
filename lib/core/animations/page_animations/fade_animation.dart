import 'package:flutter/material.dart';

class MozFadeRoute extends PageRouteBuilder {
  final Widget page;

  MozFadeRoute(this.page)
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}
