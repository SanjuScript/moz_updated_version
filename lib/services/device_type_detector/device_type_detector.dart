import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

class DeviceDetector {
  static final _deviceInfo = DeviceInfoPlugin();

  static Future<DeviceType> getDeviceType(BuildContext context) async {
    final media = MediaQuery.of(context);
    final shortestSide = media.size.shortestSide;

    // -------- DESKTOP --------
    if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return DeviceType.desktop;
    }

    // -------- ANDROID SPECIAL MODES --------
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;

      final uiMode = androidInfo.systemFeatures.contains(
        'android.software.leanback',
      );

      final isCar = androidInfo.systemFeatures.contains(
        'android.hardware.type.automotive',
      );

      if (isCar) return DeviceType.car;
      if (uiMode) return DeviceType.tv;
    }

    // -------- iOS / iPadOS --------
    if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;

      if (iosInfo.model.toLowerCase().contains("carplay")) {
        return DeviceType.car;
      }
    }

    // -------- MOBILE vs TABLET --------
    if (shortestSide >= 600) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
}

enum DeviceType { mobile, tablet, desktop, tv, car }
