import 'package:hive/hive.dart';

class SettingsManager {
  static const String _boxName = 'settings';
  static const String _imageQualityKey = 'image_quality';
  static const String _audioQualityKey = 'audio_quality';
  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  static String getImageQuality() {
    return _box?.get(_imageQualityKey, defaultValue: 'high') ?? 'medium';
  }

  static String getAudioQuality() {
    return _box?.get(_audioQualityKey, defaultValue: 'high') ?? 'medium';
  }

  static Future<void> setImageQuality(String quality) async {
    await _box?.put(_imageQualityKey, quality);
  }

  static Future<void> setAudioQuality(String quality) async {
    await _box?.put(_audioQualityKey, quality);
  }

  static String getImageResolution() {
    final quality = getImageQuality();
    switch (quality) {
      case 'low':
        return '50x50';
      case 'medium':
        return '150x150';
      default:
        return '500x500';
    }
  }

  static bool shouldUse320kbps() {
    return getAudioQuality() == 'high';
  }

  static String getAudioSuffix() {
    final quality = getAudioQuality();
    switch (quality) {
      case 'low':
        return '_96';
      case 'high':
        return '_320';
      default:
        return '_160';
    }
  }

  static Future<void> close() async {
    await _box?.close();
  }

  static Future<void> clearAll() async {
    await _box?.clear();
  }
}
