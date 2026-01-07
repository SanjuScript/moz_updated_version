import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> getDownloadDir() async {
  final baseDir = await getExternalStorageDirectory();
  final downloadDir = Directory('${baseDir!.path}/MozMusic/Downloads');

  if (!await downloadDir.exists()) {
    await downloadDir.create(recursive: true);
  }

  return downloadDir.path;
}
