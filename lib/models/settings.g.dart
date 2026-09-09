// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 3;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings()
      ..notifPauseAll = fields[0] as bool
      ..notifMessages = fields[1] as bool
      ..notifNewMatch = fields[2] as bool
      ..sleepMode = fields[3] as bool
      ..sleepStartTime = fields[4] as String
      ..sleepEndTime = fields[5] as String
      ..sleepChooseDays = (fields[6] as List).cast<bool>()
      ..accountPrivacy = fields[7] as bool;
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.notifPauseAll)
      ..writeByte(1)
      ..write(obj.notifMessages)
      ..writeByte(2)
      ..write(obj.notifNewMatch)
      ..writeByte(3)
      ..write(obj.sleepMode)
      ..writeByte(4)
      ..write(obj.sleepStartTime)
      ..writeByte(5)
      ..write(obj.sleepEndTime)
      ..writeByte(6)
      ..write(obj.sleepChooseDays)
      ..writeByte(7)
      ..write(obj.accountPrivacy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
