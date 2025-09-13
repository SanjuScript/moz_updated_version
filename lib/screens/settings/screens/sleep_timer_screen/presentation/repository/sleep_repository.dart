import 'dart:async';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/repository/sleep_ab_repo.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/service_locator.dart';

class SleepTimerRepository implements ISleepTimerRepository {
  final audioHandler = sl<MozAudioHandler>();

  Timer? _timer;
  int _remainingSeconds = 0;
  int _tracksLeft = 0;

  @override
  void startTrackTimer(
    int trackCount,
    void Function() onFinished,
    void Function(int) onUpdate,
  ) {
    _tracksLeft = trackCount;

    audioHandler.mediaItem.listen((media) {
      if (_tracksLeft > 0) {
        _tracksLeft--;
        onUpdate(_tracksLeft);
        if (_tracksLeft <= 0) {
          audioHandler.pause();
          _timer?.cancel();
          onFinished();
        }
      }
    });
  }

  @override
  void startCountdownTimer(
    int minutes,
    void Function() onFinished,
    void Function(int) onUpdate,
  ) {
    _remainingSeconds = minutes * 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _remainingSeconds--;
      onUpdate(_remainingSeconds);
      if (_remainingSeconds <= 0) {
        audioHandler.pause();
        t.cancel();
        onFinished();
      }
    });
  }

  @override
  void stopTimer() {
    _timer?.cancel();
  }

  @override
  int get remainingSeconds => _remainingSeconds;

  @override
  int get tracksLeft => _tracksLeft;
}
