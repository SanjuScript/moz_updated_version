part of 'audio_bloc.dart';

sealed class AudioEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlaySong extends AudioEvent {
  final SongModel song;
  final List<SongModel> playlist;
  final int? playlistKey;

  PlaySong(this.song, this.playlist, {this.playlistKey});

  @override
  List<Object?> get props => [song, playlist, playlistKey];
}

//play audio from external source
class PlayExternalSong extends AudioEvent {
  final String path;
  PlayExternalSong(this.path);
  @override
  List<Object?> get props => [path];
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
