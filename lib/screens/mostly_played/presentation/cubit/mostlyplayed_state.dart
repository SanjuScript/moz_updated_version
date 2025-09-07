part of 'mostlyplayed_cubit.dart';

sealed class MostlyplayedState extends Equatable {
  const MostlyplayedState();

  @override
  List<Object> get props => [];
}

class MostlyPlayedLoading extends MostlyplayedState {}

class MostlyPlayedLoaded extends MostlyplayedState {
  final List<SongModel> items;
  const MostlyPlayedLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class MostlyPlayedError extends MostlyplayedState {
  final String message;
  const MostlyPlayedError(this.message);
  @override
  List<Object> get props => [message];
}
