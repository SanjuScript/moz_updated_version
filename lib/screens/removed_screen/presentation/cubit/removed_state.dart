part of 'removed_cubit.dart';

sealed class RemovedState extends Equatable {
  const RemovedState();

  @override
  List<Object> get props => [];
}

final class RemovedInitial extends RemovedState {}

class RemovedLoading extends RemovedState {}

class RemovedLoaded extends RemovedState {
  final List<SongModel> items;
  const RemovedLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class RemovedError extends RemovedState {
  final String message;
  const RemovedError(this.message);

  @override
  List<Object> get props => [message];
}
