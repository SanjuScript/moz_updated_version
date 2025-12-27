import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/db/download_songs/repository/download_repo.dart';
import 'package:moz_updated_version/data/model/download_song/download_song_model.dart';

part 'download_songs_state.dart';

class DownloadSongsCubit extends Cubit<DownloadSongsState> {
  DownloadSongsCubit() : super(DownloadSongsLoading());

  void loadDownloadedSongs() {
    emit(DownloadSongsLoading());

    final songs = DownloadSongRepository.getAllSongs();

    final validSongs = <DownloadedSongModel>[];

    for (final song in songs) {
      if (File(song.filePath).existsSync()) {
        validSongs.add(song);
      } else {
        DownloadSongRepository.deleteSong(song.id);
      }
    }

    if (validSongs.isEmpty) {
      emit(DownloadSongsEmpty());
    } else {
      emit(DownloadSongsLoaded(validSongs));
    }
  }
}
