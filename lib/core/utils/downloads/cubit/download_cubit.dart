import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/core/utils/downloads/download_manager.dart';
import 'package:moz_updated_version/core/utils/downloads/download_model.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'download_state.dart';

class DownloadCubit extends Cubit<List<DownloadTaskState>> {
  DownloadCubit() : super([]);

  final _manager = DownloadManager();

  void download(SongModel song) {
    emit([
      ...state,
      DownloadTaskState(song: song, progress: 0, status: DownloadStatus.queued),
    ]);

    _manager.startDownload(
      song: song,
      onProgress: (p) {
        _update(song.id.toString(), p, DownloadStatus.downloading);
      },
      onComplete: () {
        _update(song.id.toString(), 1, DownloadStatus.completed);
      },
      onError: () {
        _update(song.id.toString(), 0, DownloadStatus.failed);
      },
    );
  }

  void cancel(String songId) {
    _manager.cancel(songId);
    _update(songId, null, DownloadStatus.cancelled);
  }

  void _update(String id, double? progress, DownloadStatus status) {
    emit(
      state.map((e) {
        if (e.song.id == id) {
          return e.copyWith(progress: progress ?? e.progress, status: status);
        }
        return e;
      }).toList(),
    );
  }
}
