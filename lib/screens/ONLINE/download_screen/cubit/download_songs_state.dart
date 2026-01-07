part of 'download_songs_cubit.dart';

abstract class DownloadSongsState extends Equatable {
  const DownloadSongsState();

  @override
  List<Object?> get props => [];
}

class DownloadSongsLoading extends DownloadSongsState {}

class DownloadSongsLoaded extends DownloadSongsState {
  final List<DownloadedSongModel> songs;

  const DownloadSongsLoaded(this.songs);

  @override
  List<Object?> get props => [songs];
}

class DownloadSongsEmpty extends DownloadSongsState {}
