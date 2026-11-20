import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:moz_updated_version/core/animations/page_animations/fade_animation.dart';
import 'package:moz_updated_version/core/animations/page_animations/scale_animation.dart';
import 'package:moz_updated_version/core/animations/page_animations/slide_animation.dart';
import 'package:moz_updated_version/core/animations/page_animations/up_transition.dart';

enum NavigationAnimation { none, up, slide, fade, scale }

Route<T> navigationPageRoute<T>({
  required WidgetBuilder builder,
  RouteSettings? settings,
  bool maintainState = true,
  bool fullscreenDialog = false,
}) {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return CupertinoPageRoute<T>(
      builder: builder,
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }

  return MaterialPageRoute<T>(
    builder: builder,
    settings: settings,
    maintainState: maintainState,
    fullscreenDialog: fullscreenDialog,
  );
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? navigateTo(
    Widget page, {
    NavigationAnimation animation = NavigationAnimation.fade,
    AxisDirection slideAxis = AxisDirection.right,
  }) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return navigatorKey.currentState?.push(
        navigationPageRoute(builder: (_) => page),
      );
    }

    switch (animation) {
      case NavigationAnimation.up:
        return navigatorKey.currentState?.push(MozUptransition(page));
      case NavigationAnimation.slide:
        return navigatorKey.currentState?.push(
          MozSlideTransition(page, direction: slideAxis),
        );
      case NavigationAnimation.fade:
        return navigatorKey.currentState?.push(MozFadeRoute(page));
      case NavigationAnimation.scale:
        return navigatorKey.currentState?.push(MozScaletransition(page));
      case NavigationAnimation.none:
        return navigatorKey.currentState?.push(
          navigationPageRoute(builder: (_) => page),
        );
    }
  }

  Future<dynamic>? replaceWith(Widget page) {
    return navigatorKey.currentState?.pushReplacement(
      navigationPageRoute(builder: (_) => page),
    );
  }

  void goBack() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    }
  }
}
