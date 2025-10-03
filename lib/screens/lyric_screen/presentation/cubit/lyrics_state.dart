part of 'lyrics_cubit.dart';

abstract class LyricsState extends Equatable {
  const LyricsState();

  @override
  List<Object?> get props => [];
}

class LyricsInitial extends LyricsState {}

class LyricsLoading extends LyricsState {}

class LyricsLoaded extends LyricsState {
  final String lyrics;

  const LyricsLoaded(this.lyrics);

  @override
  List<Object?> get props => [lyrics];
}

class LyricsError extends LyricsState {
  final String message;

  const LyricsError(this.message);

  @override
  List<Object?> get props => [message];
}
