import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/services/download/audio_download_service.dart';
import 'package:moz_updated_version/services/navigation_service.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

class DownloadManager {
  final _service = AudioDownloadService();
  final Map<String, CancelToken> _cancelTokens = {};

  Future<void> startDownload({
    required SongModel song,
    required void Function(double) onProgress,
    required void Function() onComplete,
    required void Function() onError,
    required BuildContext context,
  }) async {
    final token = CancelToken();
    _cancelTokens[song.id.toString()] = token;

    AppSnackBar.info(context, "Download started");

    try {
      await _service.downloadSong(
        song: song,
        onProgress: onProgress,
        cancelToken: token,
      );
      onComplete();
      AppSnackBar.success(context, "Download Completed");
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        log('Download cancelled: ${song.title}');
        return;
      }
      log('Dio error: ${e.message}');
      AppSnackBar.warning(context, "Download cancelled");

      onError();
    } on PlatformException catch (e) {
      log(' Platform error (metadata): ${e.message}');
      onError();
    } catch (e, s) {
      log('Unknown error', error: e, stackTrace: s);
      onError();
      AppSnackBar.error(context, "Download failed");
    } finally {
      _cancelTokens.remove(song.id.toString());
    }
  }

  void cancel(String songId) {
    _cancelTokens[songId]?.cancel();
    _cancelTokens.remove(songId);
  }
}
