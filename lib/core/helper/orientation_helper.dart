import 'package:flutter/services.dart';
import 'package:moz_updated_version/services/device_type_detector/device_type_detector.dart';

void setOrientation(DeviceType type) {
  switch (type) {
    case DeviceType.mobile:
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      break;

    case DeviceType.tablet:
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      break;

    case DeviceType.tv:
    case DeviceType.desktop:
    case DeviceType.car:
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      break;
  }
}
