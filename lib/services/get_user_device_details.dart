import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class DeviceInfoService {
  static final _deviceInfo = DeviceInfoPlugin();

  static Future<Map<String, dynamic>> getDeviceData() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final timezone = await FlutterTimezone.getLocalTimezone();

    if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;

      return {
        "platform": "android",
        "brand": android.brand,
        "model": android.model,
        "manufacturer": android.manufacturer,
        "device": android.device,
        "androidVersion": android.version.release,
        "sdkInt": android.version.sdkInt,
        "isPhysicalDevice": android.isPhysicalDevice,
        "appVersion": packageInfo.version,
        "buildNumber": packageInfo.buildNumber,
        "timezone": timezone.toString(),
        "createdAt": FieldValue.serverTimestamp(),
      };
    }

    if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;

      return {
        "platform": "ios",
        "model": ios.utsname.machine,
        "name": ios.name,
        "systemName": ios.systemName,
        "systemVersion": ios.systemVersion,
        "isPhysicalDevice": ios.isPhysicalDevice,
        "appVersion": packageInfo.version,
        "buildNumber": packageInfo.buildNumber,
        "timezone": timezone.toString(),
        "createdAt": FieldValue.serverTimestamp(),
      };
    }

    return {};
  }
}
