// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_preference_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LanguagePreferenceAdapter extends TypeAdapter<LanguagePreference> {
  @override
  final int typeId = 4;

  @override
  LanguagePreference read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LanguagePreference(
      selectedLanguages: (fields[0] as List).cast<String>(),
      lastUpdated: fields[1] as DateTime,
      isOnboardingComplete: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LanguagePreference obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.selectedLanguages)
      ..writeByte(1)
      ..write(obj.lastUpdated)
      ..writeByte(2)
      ..write(obj.isOnboardingComplete);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguagePreferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
