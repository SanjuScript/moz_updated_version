import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:moz_updated_version/services/download/audio_download_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

class DownloadManager {
  final _service = AudioDownloadService();
  final Map<String, CancelToken> _cancelTokens = {};

  Future<void> startDownload({
    required SongModel song,
    required void Function(double) onProgress,
    required void Function() onComplete,
    required void Function() onError,
  }) async {
    final token = CancelToken();
    _cancelTokens[song.id.toString()] = token;

    try {
      await _service.downloadSong(
        song: song,
        onProgress: onProgress,
        cancelToken: token,
      );
      onComplete();
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        log('Download cancelled: ${song.title}');
        return;
      }
      log('Dio error: ${e.message}');
      onError();
    } on PlatformException catch (e) {
      log(' Platform error (metadata): ${e.message}');
      onError();
    } catch (e, s) {
      log('Unknown error', error: e, stackTrace: s);
      onError();
    } finally {
      _cancelTokens.remove(song.id.toString());
    }
  }

  void cancel(String songId) {
    _cancelTokens[songId]?.cancel();
    _cancelTokens.remove(songId);
  }
}
