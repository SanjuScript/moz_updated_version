import 'dart:developer';
import 'package:flutter/services.dart';

class EqualizerService {
  static const MethodChannel _channel = MethodChannel(
    'com.mozmusic.app/equalizer',
  );

  // Initialize equalizer with audio session ID
  Future<bool> initialize(int audioSessionId) async {
    try {
      final result = await _channel.invokeMethod('initialize', {
        'audioSessionId': audioSessionId,
      });
      return result ?? false;
    } catch (e) {
      log('Error initializing equalizer: $e');
      return false;
    }
  }

  // Enable/Disable equalizer
  Future<void> setEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setEnabled', {'enabled': enabled});
    } catch (e) {
      log('Error setting equalizer enabled: $e');
    }
  }

  // Get number of bands
  Future<int> getNumberOfBands() async {
    try {
      final result = await _channel.invokeMethod('getNumberOfBands');
      return result ?? 5;
    } catch (e) {
      log('Error getting number of bands: $e');
      return 5;
    }
  }

  // Get band level range [min, max]
  Future<List<int>> getBandLevelRange() async {
    try {
      final result = await _channel.invokeMethod('getBandLevelRange');
      return List<int>.from(result ?? [-1500, 1500]);
    } catch (e) {
      log('Error getting band level range: $e');
      return [-1500, 1500];
    }
  }

  // Get center frequency for a band (in millihertz)
  Future<int> getCenterFreq(int band) async {
    try {
      final result = await _channel.invokeMethod('getCenterFreq', {
        'band': band,
      });
      return result ?? 0;
    } catch (e) {
      log('Error getting center frequency: $e');
      return 0;
    }
  }

  // Set band level
  Future<void> setBandLevel(int band, int level) async {
    try {
      await _channel.invokeMethod('setBandLevel', {
        'band': band,
        'level': level,
      });
    } catch (e) {
      log('Error setting band level: $e');
    }
  }

  // Get current band level
  Future<int> getBandLevel(int band) async {
    try {
      final result = await _channel.invokeMethod('getBandLevel', {
        'band': band,
      });
      return result ?? 0;
    } catch (e) {
      log('Error getting band level: $e');
      return 0;
    }
  }

  // Get available presets
  Future<List<String>> getPresets() async {
    try {
      final result = await _channel.invokeMethod('getPresets');
      return List<String>.from(result ?? []);
    } catch (e) {
      log('Error getting presets: $e');
      return [];
    }
  }

  // Use preset
  Future<void> usePreset(int presetIndex) async {
    try {
      await _channel.invokeMethod('usePreset', {'preset': presetIndex});
    } catch (e) {
      log('Error using preset: $e');
    }
  }

  // Bass Boost
  Future<void> setBassBoost(int strength) async {
    try {
      await _channel.invokeMethod('setBassBoost', {'strength': strength});
    } catch (e) {
      log('Error setting bass boost: $e');
    }
  }

  Future<void> setBassBoostEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setBassBoostEnabled', {'enabled': enabled});
    } catch (e) {
      log('Error setting bass boost enabled: $e');
    }
  }

  // Virtualizer
  Future<void> setVirtualizer(int strength) async {
    try {
      await _channel.invokeMethod('setVirtualizer', {'strength': strength});
    } catch (e) {
      log('Error setting virtualizer: $e');
    }
  }

  Future<void> setVirtualizerEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setVirtualizerEnabled', {
        'enabled': enabled,
      });
    } catch (e) {
      log('Error setting virtualizer enabled: $e');
    }
  }

  // Reverb
  Future<void> setReverb(int preset) async {
    try {
      await _channel.invokeMethod('setReverb', {'preset': preset});
    } catch (e) {
      log('Error setting reverb: $e');
    }
  }

  Future<void> setReverbEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setReverbEnabled', {'enabled': enabled});
    } catch (e) {
      log('Error setting reverb enabled: $e');
    }
  }

  // Loudness Enhancer (requires API 19+)
  Future<void> setLoudnessGain(int gain) async {
    try {
      await _channel.invokeMethod('setLoudnessGain', {'gain': gain});
    } catch (e) {
      log('Error setting loudness gain: $e');
    }
  }

  Future<void> setLoudnessEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setLoudnessEnabled', {'enabled': enabled});
    } catch (e) {
      log('Error setting loudness enabled: $e');
    }
  }

  // ============= Environmental Reverb =============
  Future<bool> initEnvironmentalReverb(int audioSessionId) async {
    try {
      final r = await _channel.invokeMethod('initEnvironmentalReverb', {
        'audioSessionId': audioSessionId,
      });
      return r == true;
    } catch (e) {
      log('Error init env reverb: $e');
      return false;
    }
  }

  Future<void> setEnvironmentalReverbProperty(
    String property,
    int value,
  ) async {
    try {
      await _channel.invokeMethod('setEnvironmentalReverbProperty', {
        'property': property,
        'value': value,
      });
    } catch (e) {
      log('Error set env reverb property: $e');
    }
  }

  // ============= Visualizer =============

  Future<bool> initializeVisualizer(int audioSessionId) async {
    try {
      final r = await _channel.invokeMethod('initializeVisualizer', {
        'audioSessionId': audioSessionId,
      });
      return r == true;
    } catch (e) {
      log('Error init visualizer: $e');
      return false;
    }
  }

  Future<List<int>> getWaveform() async {
    try {
      final r = await _channel.invokeMethod('getWaveform');
      return List<int>.from(r ?? []);
    } catch (e) {
      log('Error get waveform: $e');
      return [];
    }
  }

  Future<List<int>> getFft() async {
    try {
      final r = await _channel.invokeMethod('getFft');
      return List<int>.from(r ?? []);
    } catch (e) {
      log('Error get fft: $e');
      return [];
    }
  }

  // ============= Save/Load settings =============

  Future<Map<String, dynamic>> saveSettings() async {
    try {
      final r = await _channel.invokeMethod('saveSettings');
      return Map<String, dynamic>.from(r ?? {});
    } catch (e) {
      log('Error saving EQ settings: $e');
      return {};
    }
  }

  Future<bool> loadSettings(Map<String, dynamic> settings) async {
    try {
      final r = await _channel.invokeMethod('loadSettings', {
        'settings': settings,
      });
      return r == true;
    } catch (e) {
      log('Error loading EQ settings: $e');
      return false;
    }
  }

  // ============= extra getters =============

  Future<int> getBassBoostStrength() async {
    try {
      final r = await _channel.invokeMethod('getBassBoostStrength');
      return r ?? 0;
    } catch (e) {
      log('Error get bass strength: $e');
      return 0;
    }
  }

  Future<int> getVirtualizerStrength() async {
    try {
      final r = await _channel.invokeMethod('getVirtualizerStrength');
      return r ?? 0;
    } catch (e) {
      log('Error get virtualizer strength: $e');
      return 0;
    }
  }

  Future<int> getCurrentPreset() async {
    try {
      final r = await _channel.invokeMethod('getCurrentPreset');
      return r ?? -1;
    } catch (e) {
      log('Error get current preset: $e');
      return -1;
    }
  }

  Future<List<int>> getBandFreqRange(int band) async {
    try {
      final r = await _channel.invokeMethod('getBandFreqRange', {'band': band});
      return List<int>.from(r ?? [0, 0]);
    } catch (e) {
      log('Error get band freq range: $e');
      return [0, 0];
    }
  }

  // Release resources
  Future<void> release() async {
    try {
      await _channel.invokeMethod('release');
    } catch (e) {
      log('Error releasing equalizer: $e');
    }
  }
}
