import 'dart:developer';
import 'package:flutter/widgets.dart';

class MozLifecycleHandler with WidgetsBindingObserver {
  static final MozLifecycleHandler _instance = MozLifecycleHandler._internal();

  factory MozLifecycleHandler() => _instance;

  MozLifecycleHandler._internal();

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // The foreground service handles audio lifecycle.
      // Calling stop() here causes premature audio shutdown on OEM skins that
      // report detached aggressively.
      log(
        'App detached: audio continues via foreground service',
        name: 'LIFECYCLE',
      );
    }
  }
}
