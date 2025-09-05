part of "recently_played_cubit.dart";


abstract class RecentlyPlayedState {}

class RecentlyPlayedLoading extends RecentlyPlayedState {}

class RecentlyPlayedLoaded extends RecentlyPlayedState {
  final List<SongModel> items;
  RecentlyPlayedLoaded(this.items);
}

class RecentlyPlayedError extends RecentlyPlayedState {
  final String message;
  RecentlyPlayedError(this.message);
}
