part of 'audio_bloc.dart';

sealed class AudioState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}

class SongPlayingExternal extends AudioState {
  final String path;

  SongPlayingExternal(this.path);

  @override
  List<Object?> get props => [path];
}

class SongPlaying extends AudioState {
  final SongModel currentSong;
  SongPlaying(this.currentSong);

  @override
  List<Object?> get props => [currentSong];
}

class SongPaused extends AudioState {
  final SongModel currentSong;
  SongPaused(this.currentSong);

  @override
  List<Object?> get props => [currentSong];
}

class AudioError extends AudioState {
  final String message;
  AudioError(this.message);

  @override
  List<Object?> get props => [message];
}
