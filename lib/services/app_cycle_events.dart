import 'package:flutter/widgets.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/core/app_services.dart';

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
      sl<MozAudioHandler>().stop();
    }
  }
}
