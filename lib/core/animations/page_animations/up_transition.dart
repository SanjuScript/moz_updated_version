import 'package:flutter/material.dart';

class MozUptransition extends PageRouteBuilder {
  final Widget page;

  MozUptransition(this.page)
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 550),
        reverseTransitionDuration: const Duration(milliseconds: 430),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation);

          final scaleAnimation = Tween<double>(
            begin: 0.92,
            end: 1.0,
          ).animate(curvedAnimation);

          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            ),
          );

          final backgroundScale = Tween<double>(begin: 1.0, end: 0.95).animate(
            CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOutCubic,
            ),
          );

          return Stack(
            children: [
              if (secondaryAnimation.status != AnimationStatus.dismissed)
                ScaleTransition(
                  scale: backgroundScale,
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 1.0, end: 0.7).animate(
                      CurvedAnimation(
                        parent: secondaryAnimation,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: Container(),
                  ),
                ),

              SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: ScaleTransition(scale: scaleAnimation, child: child),
                ),
              ),
            ],
          );
        },
      );
}
