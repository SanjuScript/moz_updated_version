import 'dart:async';
import 'package:flutter/services.dart';

class ExternalAudioService {
  static const MethodChannel _channel = MethodChannel('com.mozmusic.app/external_audio_handler');
  
  final StreamController<String> _controller = StreamController<String>.broadcast();

  /// Stream of audio file paths opened from outside the app
  Stream<String> get audioFileStream => _controller.stream;

  ExternalAudioService() {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onAudioOpened') {
        final String? path = call.arguments as String?;
        if (path != null && path.isNotEmpty) {
          _controller.add(path);
        }
      }
    });
  }

  /// Retrieve any audio path that triggered the cold-launch of the app
  Future<String?> getInitialAudio() async {
    try {
      final String? path = await _channel.invokeMethod<String>('getInitialAudio');
      return path;
    } catch (e) {
      // Return null if call fails or is not implemented on the platform
      return null;
    }
  }

  void dispose() {
    _controller.close();
  }
}
