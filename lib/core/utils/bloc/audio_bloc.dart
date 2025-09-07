import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repo.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repository.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';
part 'audio_event.dart';
part 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepository _repository = sl<AudioRepository>();
  AudioBloc() : super(AudioInitial()) {
    on<PlaySong>(_onPlaySong);
    on<PauseSong>(_onPauseSong);
    on<ResumeSong>(_onResumeSong);
    on<StopSong>(_onStopSong);
    on<NextSong>(_onNextSong);
    on<PreviousSong>(_onPreviousSong);
    on<SeekSong>(_onSeekSong);
    on<PlayExternalSong>(_onPlayExternalSong);
  }

  Future<void> _onPlayExternalSong(
    PlayExternalSong event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await _repository.setPlaylist([]);

      await _repository.playExternal(event.path);

      emit(SongPlayingExternal(event.path));
    } catch (e) {
      emit(AudioError("Failed to play external song: $e"));
    }
  }

  Future<void> _onPlaySong(PlaySong event, Emitter<AudioState> emit) async {
    try {
      await _repository.setPlaylist(
        event.playlist,
        startIndex: event.playlist.indexOf(event.song),
      );
      emit(SongPlaying(event.song));
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onPauseSong(PauseSong event, Emitter<AudioState> emit) async {
    try {
      if (state is SongPlaying) {
        final song = (state as SongPlaying).currentSong;
        await _repository.pause();
        emit(SongPaused(song));
      }
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onResumeSong(ResumeSong event, Emitter<AudioState> emit) async {
    if (state is SongPaused) {
      final song = (state as SongPaused).currentSong;
      await _repository.play();
      emit(SongPlaying(song));
    }
  }

  Future<void> _onStopSong(StopSong event, Emitter<AudioState> emit) async {
    await _repository.stop();
    emit(AudioInitial());
  }

  Future<void> _onNextSong(NextSong event, Emitter<AudioState> emit) async {
    await _repository.next();
  }

  Future<void> _onPreviousSong(
    PreviousSong event,
    Emitter<AudioState> emit,
  ) async {
    await _repository.previous();
  }

  Future<void> _onSeekSong(SeekSong event, Emitter<AudioState> emit) async {
    await _repository.seek(event.position);
  }

  

  // @override
  // void onChange(Change<AudioState> change) {
  //   super.onChange(change);
  //   log(change.toString());
  // }

  // @override
  // void onError(Object error, StackTrace stackTrace) {
  //   super.onError(error, stackTrace);
  //   log(stackTrace.toString());
  // }
}
