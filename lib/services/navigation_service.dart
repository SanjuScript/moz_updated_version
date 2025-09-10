import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/animations/page_animations/fade_animation.dart';
import 'package:moz_updated_version/core/animations/page_animations/scale_animation.dart';
import 'package:moz_updated_version/core/animations/page_animations/slide_animation.dart';
import 'package:moz_updated_version/core/animations/page_animations/up_transition.dart';

enum NavigationAnimation { none, up, slide, fade, scale }

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? navigateTo(
    Widget page, {
    NavigationAnimation animation = NavigationAnimation.none,
  }) {
    switch (animation) {
      case NavigationAnimation.up:
        return navigatorKey.currentState?.push(MozUptransition(page));
      case NavigationAnimation.slide:
        return navigatorKey.currentState?.push(MozSlideTransition(page));
      case NavigationAnimation.fade:
        return navigatorKey.currentState?.push(MozFadeRoute(page));
      case NavigationAnimation.scale:
        return navigatorKey.currentState?.push(MozScaletransition(page));
      case NavigationAnimation.none:
        return navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => page),
        );
    }
  }

  Future<dynamic>? replaceWith(Widget page) {
    return navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }
}
