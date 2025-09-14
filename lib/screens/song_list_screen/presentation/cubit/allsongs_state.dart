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
  final bool isSelecting;
  final Set<String> selectedSongs;

  const AllSongsLoaded(
    this.songs, {
    this.isSelecting = false,
    this.selectedSongs = const {},
  });

  AllSongsLoaded copyWith({
    List<SongModel>? songs,
    bool? isSelecting,
    Set<String>? selectedSongs,
  }) {
    return AllSongsLoaded(
      songs ?? this.songs,
      isSelecting: isSelecting ?? this.isSelecting,
      selectedSongs: selectedSongs ?? this.selectedSongs,
    );
  }

  @override
  List<Object> get props => [songs, isSelecting, selectedSongs];
}

class AllSongsError extends AllsongsState {
  final String message;
  const AllSongsError(this.message);

  @override
  List<Object> get props => [message];
}
