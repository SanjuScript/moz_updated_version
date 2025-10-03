import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/core/utils/repository/lyric_repository/lyric_repo.dart';
import 'package:moz_updated_version/services/service_locator.dart';

part 'lyrics_state.dart';

class LyricsCubit extends Cubit<LyricsState> {
  final LyricsRepository repository = sl<LyricsRepository>();

  LyricsCubit() : super(LyricsInitial());

  Future<void> getLyrics(String artist, String title) async {
    emit(LyricsLoading());
    try {
      final lyrics = await repository.fetchLyrics(artist, title);
      if (lyrics != null && lyrics.isNotEmpty) {
        emit(LyricsLoaded(lyrics));
      } else {
        emit(const LyricsError("Lyrics not found"));
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
