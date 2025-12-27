part of 'download_cubit.dart';

enum DownloadStatus { queued, downloading, completed, failed, cancelled }

class DownloadTaskState {
  final SongModel song;
  final double progress;
  final DownloadStatus status;

  const DownloadTaskState({
    required this.song,
    required this.progress,
    required this.status,
  });

  DownloadTaskState copyWith({double? progress, DownloadStatus? status}) {
    return DownloadTaskState(
      song: song,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }
}
