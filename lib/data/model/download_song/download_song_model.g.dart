// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_song_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadedSongModelAdapter extends TypeAdapter<DownloadedSongModel> {
  @override
  final int typeId = 5;

  @override
  DownloadedSongModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadedSongModel(
      id: fields[0] as int,
      title: fields[1] as String,
      artist: fields[2] as String,
      album: fields[3] as String?,
      genre: fields[4] as String?,
      duration: fields[5] as int?,
      filePath: fields[6] as String,
      artworkPath: fields[7] as String?,
      downloadedAt: fields[9] as DateTime,
      fileSize: fields[10] as int?,
      pid: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadedSongModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.album)
      ..writeByte(4)
      ..write(obj.genre)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.filePath)
      ..writeByte(7)
      ..write(obj.artworkPath)
      ..writeByte(9)
      ..write(obj.downloadedAt)
      ..writeByte(10)
      ..write(obj.fileSize)
      ..writeByte(11)
      ..write(obj.pid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadedSongModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
