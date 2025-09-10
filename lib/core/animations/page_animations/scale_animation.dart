import 'package:flutter/material.dart';

class MozScaletransition extends PageRouteBuilder {
  final Widget page;
  MozScaletransition(this.page)
    : super(
        pageBuilder: (context, animation, anotherAnimation) => page,
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, anotherAnimation, child) {
          animation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
            reverseCurve: Curves.easeInOut,
          );
          return ScaleTransition(
            scale: animation,
            alignment: Alignment.topRight,
            child: child,
          );
        },
      );
}
