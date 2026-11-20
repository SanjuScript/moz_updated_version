import 'dart:async';
import 'package:flutter/services.dart';

class ExternalAudioService {
  static const MethodChannel _channel = MethodChannel(
    'com.mozmusic.app/external_audio_handler',
  );

  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _siriController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of audio file paths opened from outside the app
  Stream<String> get audioFileStream => _controller.stream;
  Stream<Map<String, dynamic>> get siriActionStream => _siriController.stream;

  ExternalAudioService() {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onAudioOpened') {
        final String? path = call.arguments as String?;
        if (path != null && path.isNotEmpty) {
          _controller.add(path);
        }
      } else if (call.method == 'onSiriAction') {
        final arguments = call.arguments;
        if (arguments is Map && _siriController.hasListener) {
          final action = Map<String, dynamic>.from(arguments);
          final actionId = action['siriActionID']?.toString();
          if (actionId != null && actionId.isNotEmpty) {
            await _acknowledgeSiriAction(actionId);
          }
          _siriController.add(action);
        }
      }
    });
  }

  /// Retrieve any audio path that triggered the cold-launch of the app
  Future<String?> getInitialAudio() async {
    try {
      final String? path = await _channel.invokeMethod<String>(
        'getInitialAudio',
      );
      return path;
    } catch (e) {
      // Return null if call fails or is not implemented on the platform
      return null;
    }
  }

  /// Takes a Siri request saved by the native app before Flutter was ready.
  Future<Map<String, dynamic>?> getPendingSiriAction() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'getPendingSiriAction',
      );
      return result == null ? null : Map<String, dynamic>.from(result);
    } catch (_) {
      return null;
    }
  }

  /// Completes Siri's media request after playback has actually started.
  Future<void> completeSiriMediaRequest({
    required String requestId,
    required bool success,
  }) async {
    try {
      await _channel.invokeMethod<void>('completeSiriMedia', {
        'requestId': requestId,
        'success': success,
      });
    } catch (_) {
      // App Intents don't attach a media request ID, so this is only a
      // best-effort acknowledgement for direct SiriKit media requests.
    }
  }

  Future<void> _acknowledgeSiriAction(String actionId) async {
    try {
      await _channel.invokeMethod<void>('acknowledgeSiriAction', {
        'siriActionID': actionId,
      });
    } catch (_) {
      // The durable native request remains available for the startup poll.
    }
  }

  void dispose() {
    _controller.close();
    _siriController.close();
  }
}
