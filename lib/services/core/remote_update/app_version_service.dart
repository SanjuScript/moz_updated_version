import 'package:package_info_plus/package_info_plus.dart';

class AppVersionService {
  static Future<int> getBuildNumber() async {
    final info = await PackageInfo.fromPlatform();
    return int.parse(info.buildNumber);
  }
}
