part of 'allsongs_cubit.dart';

sealed class AllsongsState extends Equatable {
  const AllsongsState();

  @override
  List<Object> get props => [];
}

final class AllsongsInitial extends AllsongsState {}

class AllSongsLoading extends AllsongsState {}

class AllSongsLoaded extends AllsongsState {
  final List<SongModel> songs;
  const AllSongsLoaded(this.songs);

  @override
  List<Object> get props => [songs];
}

class AllSongsError extends AllsongsState {
  final String message;
  const AllSongsError(this.message);

  @override
  List<Object> get props => [message];
}
