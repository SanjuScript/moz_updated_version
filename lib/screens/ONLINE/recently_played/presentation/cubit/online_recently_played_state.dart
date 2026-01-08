part of 'online_recently_played_cubit.dart';

abstract class OnlineRecentlyPlayedState extends Equatable {
  const OnlineRecentlyPlayedState();

  @override
  List<Object?> get props => [];
}

class OnlineRecentlyPlayedInitial extends OnlineRecentlyPlayedState {}

class OnlineRecentlyPlayedLoading extends OnlineRecentlyPlayedState {}

class OnlineRecentlyPlayedLoaded extends OnlineRecentlyPlayedState {
  final List<String> songIds;

  const OnlineRecentlyPlayedLoaded(this.songIds);

  @override
  List<Object?> get props => [songIds];
}

class OnlineRecentlyPlayedError extends OnlineRecentlyPlayedState {
  final String message;

  const OnlineRecentlyPlayedError(this.message);

  @override
  List<Object?> get props => [message];
}
