abstract class ISleepTimerRepository {
  void startTrackTimer(
    int trackCount,
    void Function() onFinished,
    void Function(int) onUpdate,
  );

  void startCountdownTimer(
    int minutes,
    void Function() onFinished,
    void Function(int) onUpdate,
  );

  void stopTimer();

  int get remainingSeconds;

  int get tracksLeft;
}
