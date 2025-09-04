part of 'audio_bloc.dart';

abstract class AudioEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSongs extends AudioEvent {}

class PlaySong extends AudioEvent {
  final SongModel song;
  final List<SongModel> playlist;

  PlaySong(this.song, this.playlist);

  @override
  List<Object?> get props => [song, playlist];
}

//play audio from external source
class PlayExternalSong extends AudioEvent {
  final String path;
  PlayExternalSong(this.path);
}

class PauseSong extends AudioEvent {}

class ResumeSong extends AudioEvent {}

class StopSong extends AudioEvent {}

class NextSong extends AudioEvent {}

class PreviousSong extends AudioEvent {}

class SeekSong extends AudioEvent {
  final Duration position;
  SeekSong(this.position);

  @override
  List<Object?> get props => [position];
}
