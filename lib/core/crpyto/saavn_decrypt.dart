import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_des/dart_des.dart';

class SaavnDecrypt {
  static String decode(String input) {
    const String key = '38346591';

    final DES desECB = DES(key: key.codeUnits);

    final Uint8List encrypted = base64.decode(input);
    final List<int> decrypted = desECB.decrypt(encrypted);

    final String decoded = utf8
        .decode(decrypted, allowMalformed: true)
        .replaceAll(RegExp(r'\.mp4.*'), '.mp4')
        .replaceAll(RegExp(r'\.m4a.*'), '.m4a')
        .replaceAll(RegExp(r'\.mp3.*'), '.mp3')
        .replaceAll('http:', 'https:');

    return decoded;
  }
}
