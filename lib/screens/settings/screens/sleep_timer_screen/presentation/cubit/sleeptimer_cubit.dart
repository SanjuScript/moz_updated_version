import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/repository/sleep_ab_repo.dart';
import 'package:moz_updated_version/services/service_locator.dart';

part 'sleeptimer_state.dart';

class SleepTimerCubit extends Cubit<SleepTimerState> {
  final repository = sl<ISleepTimerRepository>();

  SleepTimerCubit() : super(SleepTimerState.initial());

  void setTrackMode(bool isTrack) => emit(state.copyWith(isTrackMode: isTrack));

  void setTrackCount(double count) => emit(state.copyWith(trackCount: count));

  void setTimerMinutes(double minutes) =>
      emit(state.copyWith(timerMinutes: minutes));

  void startTimer() {
    if (state.isTrackMode) {
      emit(
        state.copyWith(isRunning: true, tracksLeft: state.trackCount.toInt()),
      );
      repository.startTrackTimer(
        state.trackCount.toInt(),
        _onFinished,
        _onUpdate,
      );
    } else {
      emit(
        state.copyWith(
          isRunning: true,
          remainingSeconds: (state.timerMinutes * 60).toInt(),
        ),
      );
      repository.startCountdownTimer(
        state.timerMinutes.toInt(),
        _onFinished,
        _onUpdate,
      );
    }
  }

  void stopTimer() {
    repository.stopTimer();
    emit(
      state.copyWith(
        isRunning: false,
        remainingSeconds: (state.timerMinutes * 60).toInt(),
        tracksLeft: state.trackCount.toInt(),
      ),
    );
  }

  void _onFinished() => emit(state.copyWith(isRunning: false));

  void _onUpdate(int value) {
    if (state.isTrackMode) {
      emit(state.copyWith(tracksLeft: value, isRunning: true));
    } else {
      emit(state.copyWith(remainingSeconds: value, isRunning: true));
    }
  }
}
