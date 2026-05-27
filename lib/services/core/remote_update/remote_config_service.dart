import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'remote_config_keys.dart';

class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(hours: 1),
      ),
    );

    await _remoteConfig.fetchAndActivate();
  }

  int get minAppVersion =>
      _remoteConfig.getInt(RemoteConfigKeys.minAppVersionCode);

  bool get forceUpdateEnabled =>
      _remoteConfig.getBool(RemoteConfigKeys.forceUpdateEnabled);

  String get updateTitle =>
      _remoteConfig.getString(RemoteConfigKeys.updateTitle);

  String get updateDescription =>
      _remoteConfig.getString(RemoteConfigKeys.updateDescription);

  String get updateButtonText =>
      _remoteConfig.getString(RemoteConfigKeys.updateButtonText);

  String get updateUrl => _remoteConfig.getString(RemoteConfigKeys.updateUrl);
}
