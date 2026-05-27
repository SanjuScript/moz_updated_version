import 'package:hive/hive.dart';

class SettingsManager {
  static const String _boxName = 'settings';
  static const String _imageQualityKey = 'image_quality';
  static const String _audioQualityKey = 'audio_quality';
  static const String _glassEffectKey = 'glass_status';
  static const String _keySkippedVersion = 'skipped_update_version';
  static const String _updateIconKey = 'update_icon_visible';

  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  //Image quality preference
  static String getImageQuality() {
    return _box?.get(_imageQualityKey, defaultValue: 'high') ?? 'medium';
  }

  static Future<void> setImageQuality(String quality) async {
    await _box?.put(_imageQualityKey, quality);
  }

  //Audio quality preference
  static String getAudioQuality() {
    return _box?.get(_audioQualityKey, defaultValue: 'high') ?? 'medium';
  }

  static Future<void> setAudioQuality(String quality) async {
    await _box?.put(_audioQualityKey, quality);
  }

  static bool shouldUse320kbps() {
    return getAudioQuality() == 'high';
  }

  //Glass style preference
  static bool getGlassStatus() {
    return _box?.get(_glassEffectKey, defaultValue: false) ?? false;
  }

  static Future<void> setGlassStatus(bool status) async {
    await _box?.put(_glassEffectKey, status);
  }

  //App update preference

  static Future<void> skipVersion(int version) async {
    await _box?.put(_keySkippedVersion, version);
    await setUpdateIconVisible(true);
  }

  static Future<void> clearSkip() async {
    await _box?.delete(_keySkippedVersion);
    await setUpdateIconVisible(false);
  }

  static int get skippedVersion =>
      _box?.get(_keySkippedVersion, defaultValue: -1);

  static bool get showUpdateIcon =>
      _box?.get(_updateIconKey, defaultValue: false) ?? false;

  static Future<void> setUpdateIconVisible(bool value) async {
    await _box?.put(_updateIconKey, value);
  }

  static Future<void> close() async {
    await _box?.close();
  }

  static Future<void> clearAll() async {
    await _box?.clear();
  }
}
