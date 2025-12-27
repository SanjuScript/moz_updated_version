import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'download_song_model.g.dart';

@HiveType(typeId: 5)
class DownloadedSongModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String? album;

  @HiveField(4)
  final String? genre;

  @HiveField(5)
  final int? duration;

  @HiveField(6)
  final String filePath;

  @HiveField(7)
  final String? artworkPath;

  @HiveField(9)
  final DateTime downloadedAt;

  @HiveField(10)
  final int? fileSize;

  @HiveField(11)
  final String? pid;

  DownloadedSongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.genre,
    this.duration,
    required this.filePath,
    this.artworkPath,
    required this.downloadedAt,
    this.fileSize,
    this.pid,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'genre': genre,
    'duration': duration,
    'filePath': filePath,
    'artworkPath': artworkPath,
    'downloadedAt': downloadedAt.toIso8601String(),
    'fileSize': fileSize,
    'pid': pid,
  };

  factory DownloadedSongModel.fromJson(Map<String, dynamic> json) =>
      DownloadedSongModel(
        id: json['id'],
        title: json['title'],
        artist: json['artist'],
        album: json['album'],
        pid: json['pid'],
        genre: json['genre'],
        duration: json['duration'],
        filePath: json['filePath'],
        artworkPath: json['artworkPath'],
        downloadedAt: DateTime.parse(json['downloadedAt']),
        fileSize: json['fileSize'],
      );
}
