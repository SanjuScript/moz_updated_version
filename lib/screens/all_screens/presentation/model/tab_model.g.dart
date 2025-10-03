// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TabModelAdapter extends TypeAdapter<TabModel> {
  @override
  final int typeId = 2;

  @override
  TabModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TabModel(
      title: fields[0] as String,
      enabled: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TabModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.enabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
