import 'package:moz_updated_version/core/crpyto/saavn_decrypt.dart';

class SaavnFormatter {
  static Map<String, dynamic> formatSong(
    Map<String, dynamic> data, {
    bool includeLyrics = false,
    String? lyrics,
  }) {
    if (data['image'] is String) {
      data['image'] = (data['image'] as String).replaceAll(
        '150x150',
        '500x500',
      );
    }

    final encrypted = data['encrypted_media_url'];
    if (encrypted is String) {
      final decrypted = SaavnDecrypt.decode(encrypted);

      final is320 = data['320kbps'] == 'true';

      final mediaUrl = is320
          ? decrypted
          : decrypted.replaceAll('_320.mp4', '_160.mp4');

      data['media_url'] = mediaUrl;
      data['media_preview_url'] = mediaUrl.replaceAll('.mp4', '_96_p.mp4');
    }

    if (includeLyrics && lyrics != null) {
      data['lyrics'] = lyrics;
    }

    return data;
  }
}
