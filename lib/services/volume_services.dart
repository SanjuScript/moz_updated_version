import 'package:flutter/services.dart';

class VolumeService {
  static const MethodChannel _platform = MethodChannel(
    'com.mozmusic.app/volume',
  );

  static final VolumeService _instance = VolumeService._internal();
  factory VolumeService() => _instance;
  VolumeService._internal();

  int _currentVolume = 0;
  int _maxVolume = 15;

  Future<int> getCurrentVolume() async {
    try {
      final int volume = await _platform.invokeMethod('getCurrentVolume');
      _currentVolume = volume;
      return volume;
    } on PlatformException catch (e) {
      throw VolumeException('Failed to get current volume: ${e.message}');
    }
  }

  Future<int> getMaxVolume() async {
    try {
      final int maxVolume = await _platform.invokeMethod('getMaxVolume');
      _maxVolume = maxVolume;
      return maxVolume;
    } on PlatformException catch (e) {
      throw VolumeException('Failed to get max volume: ${e.message}');
    }
  }

  Future<void> setVolume(int volume) async {
    if (volume < 0 || volume > _maxVolume) {
      throw VolumeException('Volume must be between 0 and $_maxVolume');
    }

    try {
      await _platform.invokeMethod('setVolume', {'volume': volume});
      _currentVolume = volume;
    } on PlatformException catch (e) {
      throw VolumeException('Failed to set volume: ${e.message}');
    }
  }

  Future<void> increaseVolume([int amount = 1]) async {
    final newVolume = (_currentVolume + amount).clamp(0, _maxVolume);
    await setVolume(newVolume);
  }

  Future<void> decreaseVolume([int amount = 1]) async {
    final newVolume = (_currentVolume - amount).clamp(0, _maxVolume);
    await setVolume(newVolume);
  }

  double getVolumePercentage() {
    return (_currentVolume / _maxVolume * 100).clamp(0, 100);
  }

  Future<void> setVolumeByPercentage(double percentage) async {
    final volume = ((percentage / 100) * _maxVolume).round();
    await setVolume(volume);
  }

  bool isMuted() => _currentVolume == 0;

  int get currentVolume => _currentVolume;
  int get maxVolume => _maxVolume;
}

class VolumeException implements Exception {
  final String message;
  VolumeException(this.message);

  @override
  String toString() => 'VolumeException: $message';
}
