part of 'audio_bloc.dart';

abstract class AudioState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}

class SongsLoading extends AudioState {}

class SongsLoaded extends AudioState {
  final List<SongModel> songs;
  final SongModel? currentSong;

  SongsLoaded(this.songs, {this.currentSong});

  @override
  List<Object?> get props => [songs, currentSong];
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
