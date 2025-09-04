import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/core/utils/repository/audio_repository/audio_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';
part 'audio_event.dart';
part 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepositoryImpl _repository;
  List<SongModel> _songs = [];

  AudioBloc(this._repository) : super(AudioInitial()) {
    on<LoadSongs>(_onLoadSongs);
    on<PlaySong>(_onPlaySong);
    on<PauseSong>(_onPauseSong);
    on<ResumeSong>(_onResumeSong);
    on<StopSong>(_onStopSong);
    on<NextSong>(_onNextSong);
    on<PreviousSong>(_onPreviousSong);
    on<SeekSong>(_onSeekSong);
    on<PlayExternalSong>(_onPlayExternalSong);
  }
  Future<void> _onLoadSongs(LoadSongs event, Emitter<AudioState> emit) async {
    emit(SongsLoading());
    try {
      _songs = await _repository.loadSongs();
      emit(SongsLoaded(_songs));
    } catch (e) {
      emit(AudioError(e.toString()));
    }
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
      emit(SongsLoaded(event.playlist, currentSong: event.song));
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onPauseSong(PauseSong event, Emitter<AudioState> emit) async {
    if (state is SongPlaying) {
      final song = (state as SongPlaying).currentSong;
      await _repository.pause();
      emit(SongPaused(song));
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
  //   print(change.toString());
  // }
}
