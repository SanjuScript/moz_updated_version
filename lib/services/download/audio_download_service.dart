import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:moz_updated_version/data/db/download_songs/repository/download_repo.dart';
import 'package:moz_updated_version/data/model/download_song/download_song_model.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AudioDownloadService {
  final Dio _dio = Dio();

  Future<void> downloadSong({
    required SongModel song,
    required void Function(double) onProgress,
    required CancelToken cancelToken,
  }) async {
    final musicDir = Directory('/storage/emulated/0/Music/MozMusic');
    final appDir = await getExternalStorageDirectory();
    final artworkDir = Directory('${appDir!.path}/artwork');

    if (!musicDir.existsSync()) {
      musicDir.createSync(recursive: true);
    }
    if (!artworkDir.existsSync()) {
      artworkDir.createSync(recursive: true);
    }

    final safeTitle = safeFileName(song.title);
    final filePath = p.join(musicDir.path, '$safeTitle.mp3');

    log('⬇️ Downloading audio to: $filePath');

    /// 1️⃣ Download audio
    await _dio.download(
      song.getMap['_data'],
      filePath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress(received / total);
        }
      },
      options: Options(
        responseType: ResponseType.stream,
        followRedirects: true,
      ),
    );

    /// 2️⃣ Download artwork
    String? artworkPath;
    final artworkUrl = song.getMap['image'];

    if (artworkUrl != null && artworkUrl.toString().isNotEmpty) {
      try {
        final safeArtworkName = safeFileName(song.title);
        artworkPath = p.join(artworkDir.path, '$safeArtworkName.jpg');

        await _dio.download(
          artworkUrl,
          artworkPath,
          options: Options(responseType: ResponseType.bytes),
        );

        log('🖼 Artwork saved: $artworkPath');
      } catch (e) {
        log('⚠️ Artwork download failed: $e');
        artworkPath = null;
      }
    }

    /// 3️⃣ Resolve MediaStore ID (acceptable for now)
    final q = OnAudioQuery();
    final songs = await q.querySongs(path: musicDir.path);

    final Map<String, int> pathToId = {for (final s in songs) s.data: s.id};

    final int? songId = pathToId[filePath];

    if (songId == null) {
      log('❌ Song not found in MediaStore');
      return;
    }

    final downloadModel = DownloadedSongModel(
      id: songId,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album,
      genre: song.genre,
      duration: song.duration,
      filePath: filePath,
      artworkPath: artworkPath,
      downloadedAt: DateTime.now(),
      fileSize: File(filePath).lengthSync(),
      pid: song.getMap['pid'],
    );

    await DownloadSongRepository.addSong(downloadModel);

    log('✅ Download saved to Hive');
  }
}

/// ✅ Proper filename sanitizer
String safeFileName(String name) {
  return name
      .replaceAll('&quot;', '')
      .replaceAll('&amp;', '')
      .replaceAll(RegExp(r'[\\/:"*?<>|]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
