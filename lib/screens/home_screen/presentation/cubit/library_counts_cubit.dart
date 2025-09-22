import 'package:bloc/bloc.dart';
part 'library_counts_state.dart';

class LibraryCountsCubit extends Cubit<LibraryCountsState> {
  LibraryCountsCubit() : super(const LibraryCountsState());

  void updateAllSongs(int count) => emit(state.copyWith(allSongs: count));

  void updateRecentlyPlayed(int count) =>
      emit(state.copyWith(recentlyPlayed: count));

  void updateMostlyPlayed(int count) =>
      emit(state.copyWith(mostlyPlayed: count));

  void updateFavorites(int count) => emit(state.copyWith(favorites: count));

  void updatePlaylists(int count) => emit(state.copyWith(playlists: count));
}
