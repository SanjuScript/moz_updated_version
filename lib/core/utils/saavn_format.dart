import 'package:moz_updated_version/core/crpyto/saavn_decrypt.dart';
import 'package:moz_updated_version/data/db/app_settings/app_settings_db.dart';
import 'package:html/parser.dart' as html_parser;

class SaavnFormatter {
  static Map<String, dynamic> formatSong(
    Map<String, dynamic> data, {
    bool includeLyrics = false,
    String? lyrics,
  }) {
    final imageQuality = SettingsManager.getImageQuality();
    final audioQuality = SettingsManager.getAudioQuality();

    if (data['title'] is String) {
      data['title'] = decodeHtml(data['title']);
    }

    if (data['song'] is String) {
      data['song'] = decodeHtml(data['song']);
    }

    if (data['album'] is String) {
      data['album'] = decodeHtml(data['album']);
    }

    if (data['singers'] is String) {
      data['singers'] = decodeHtml(data['singers']);
    }

    if (data['image'] is String) {
      data['image'] = getImageUrl(data['image'], quality: imageQuality);
    }

    final encrypted = data['encrypted_media_url'];
    if (encrypted is String) {
      final decrypted = SaavnDecrypt.decode(encrypted);
      final is320Available = data['320kbps'] == 'true';

      String mediaUrl;

      switch (audioQuality) {
        case 'low':
          mediaUrl = decrypted
              .replaceAll('_320.mp4', '_96.mp4')
              .replaceAll('_160.mp4', '_96.mp4');
          break;

        case 'high':
          mediaUrl = is320Available
              ? decrypted
              : decrypted.replaceAll('_320.mp4', '_160.mp4');
          break;

        default:
          mediaUrl = decrypted.replaceAll('_320.mp4', '_160.mp4');
      }

      data['media_url'] = mediaUrl;

      data['media_preview_url'] = decrypted
          .replaceAll('_320.mp4', '_96_p.mp4')
          .replaceAll('_160.mp4', '_96_p.mp4')
          .replaceAll('.mp4', '_96_p.mp4');
    }

    if (includeLyrics && lyrics != null) {
      data['lyrics'] = decodeHtml(lyrics);
    }

    return data;
  }

  static List<Map<String, dynamic>> formatSongs(
    List<Map<String, dynamic>> songs, {
    bool includeLyrics = false,
  }) {
    return songs
        .map((song) => formatSong(song, includeLyrics: includeLyrics))
        .toList();
  }
}

String decodeHtml(String? text) {
  if (text == null || text.isEmpty) return '';
  return html_parser.parse(text).documentElement?.text ?? text;
}

String getImageUrl(String? imageUrl, {String quality = 'high'}) {
  if (imageUrl == null || imageUrl.isEmpty) return '';

  final url = imageUrl.trim().replaceAll('http:', 'https:');

  switch (quality) {
    case 'low':
      return url.replaceAll('500x500', '50x50').replaceAll('150x150', '50x50');

    case 'medium':
      return url
          .replaceAll('500x500', '150x150')
          .replaceAll('50x50', '150x150');

    case 'high':
    default:
      return url
          .replaceAll('50x50', '500x500')
          .replaceAll('150x150', '500x500');
  }
}
