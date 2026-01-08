// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';

// class EqualizerServiceIos {
//   static const MethodChannel _channel = MethodChannel(
//     'com.mozmusic.app/equalizer',
//   );

//   // Initialize equalizer with audio session ID
//   Future<bool> initialize(int audioSessionId) async {
//     try {
//       final result = await _channel.invokeMethod('initialize', {
//         'audioSessionId': audioSessionId,
//       });
//       return result ?? false;
//     } catch (e) {
//       log('Error initializing equalizer: $e');
//       return false;
//     }
//   }

//   // Check if equalizer is supported on this platform
//   Future<bool> isSupported() async {
//     if (Platform.isIOS) {
//       // iOS requires AVAudioEngine integration with your audio player
//       // Return true if your player supports it
//       return true;
//     }
//     return Platform.isAndroid;
//   }

//   // Enable/Disable equalizer
//   Future<void> setEnabled(bool enabled) async {
//     try {
//       await _channel.invokeMethod('setEnabled', {'enabled': enabled});
//     } catch (e) {
//       log('Error setting equalizer enabled: $e');
//     }
//   }

//   // Get number of bands
//   Future<int> getNumberOfBands() async {
//     try {
//       final result = await _channel.invokeMethod('getNumberOfBands');
//       return result ?? (Platform.isIOS ? 10 : 5);
//     } catch (e) {
//       log('Error getting number of bands: $e');
//       return Platform.isIOS ? 10 : 5;
//     }
//   }

//   // Get band level range [min, max]
//   Future<List<int>> getBandLevelRange() async {
//     try {
//       final result = await _channel.invokeMethod('getBandLevelRange');
//       return List<int>.from(result ?? [-1500, 1500]);
//     } catch (e) {
//       log('Error getting band level range: $e');
//       return [-1500, 1500];
//     }
//   }

//   // Get center frequency for a band (in millihertz)
//   Future<int> getCenterFreq(int band) async {
//     try {
//       final result = await _channel.invokeMethod('getCenterFreq', {
//         'band': band,
//       });
//       return result ?? 0;
//     } catch (e) {
//       log('Error getting center frequency: $e');
//       return 0;
//     }
//   }

//   // Set band level
//   Future<void> setBandLevel(int band, int level) async {
//     try {
//       await _channel.invokeMethod('setBandLevel', {
//         'band': band,
//         'level': level,
//       });
//     } catch (e) {
//       log('Error setting band level: $e');
//     }
//   }

//   // Get current band level
//   Future<int> getBandLevel(int band) async {
//     try {
//       final result = await _channel.invokeMethod('getBandLevel', {
//         'band': band,
//       });
//       return result ?? 0;
//     } catch (e) {
//       log('Error getting band level: $e');
//       return 0;
//     }
//   }

//   // Get available presets
//   Future<List<String>> getPresets() async {
//     try {
//       final result = await _channel.invokeMethod('getPresets');
//       return List<String>.from(result ?? _getDefaultPresets());
//     } catch (e) {
//       log('Error getting presets: $e');
//       return _getDefaultPresets();
//     }
//   }

//   List<String> _getDefaultPresets() {
//     return [
//       'Normal',
//       'Classical',
//       'Dance',
//       'Flat',
//       'Folk',
//       'Heavy Metal',
//       'Hip Hop',
//       'Jazz',
//       'Pop',
//       'Rock',
//     ];
//   }

//   // Use preset
//   Future<void> usePreset(int presetIndex) async {
//     try {
//       await _channel.invokeMethod('usePreset', {'preset': presetIndex});
//     } catch (e) {
//       log('Error using preset: $e');
//     }
//   }

//   // Bass Boost (Limited on iOS - simulated with distortion + EQ)
//   Future<void> setBassBoost(int strength) async {
//     try {
//       await _channel.invokeMethod('setBassBoost', {'strength': strength});
//     } catch (e) {
//       log('Error setting bass boost: $e');
//     }
//   }

//   Future<void> setBassBoostEnabled(bool enabled) async {
//     try {
//       await _channel.invokeMethod('setBassBoostEnabled', {'enabled': enabled});
//     } catch (e) {
//       log('Error setting bass boost enabled: $e');
//     }
//   }

//   // Virtualizer (iOS uses Reverb for spatial effect)
//   Future<void> setVirtualizer(int strength) async {
//     try {
//       await _channel.invokeMethod('setVirtualizer', {'strength': strength});
//     } catch (e) {
//       log('Error setting virtualizer: $e');
//     }
//   }

//   Future<void> setVirtualizerEnabled(bool enabled) async {
//     try {
//       await _channel.invokeMethod('setVirtualizerEnabled', {
//         'enabled': enabled,
//       });
//     } catch (e) {
//       log('Error setting virtualizer enabled: $e');
//     }
//   }

//   // Reverb
//   Future<void> setReverb(int preset) async {
//     try {
//       await _channel.invokeMethod('setReverb', {'preset': preset});
//     } catch (e) {
//       log('Error setting reverb: $e');
//     }
//   }

//   Future<void> setReverbEnabled(bool enabled) async {
//     try {
//       await _channel.invokeMethod('setReverbEnabled', {'enabled': enabled});
//     } catch (e) {
//       log('Error setting reverb enabled: $e');
//     }
//   }

//   // Loudness Enhancer (iOS uses volume boost)
//   Future<void> setLoudnessGain(int gain) async {
//     try {
//       await _channel.invokeMethod('setLoudnessGain', {'gain': gain});
//     } catch (e) {
//       log('Error setting loudness gain: $e');
//     }
//   }

//   Future<void> setLoudnessEnabled(bool enabled) async {
//     try {
//       await _channel.invokeMethod('setLoudnessEnabled', {'enabled': enabled});
//     } catch (e) {
//       log('Error setting loudness enabled: $e');
//     }
//   }

//   // Release resources
//   Future<void> release() async {
//     try {
//       await _channel.invokeMethod('release');
//     } catch (e) {
//       log('Error releasing equalizer: $e');
//     }
//   }
// }
