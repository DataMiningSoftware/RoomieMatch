// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PreferenceAdapter extends TypeAdapter<Preference> {
  @override
  final int typeId = 4;

  @override
  Preference read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Preference()
      ..personality = fields[0] as int
      ..guestsOver = fields[1] as int
      ..loudNoise = fields[2] as int
      ..cleanliness = fields[3] as int
      ..smoke = fields[4] as int
      ..guestsFeeling = fields[5] as int
      ..sociality = fields[6] as int
      ..loudTv = fields[7] as int
      ..contributeCleaning = fields[8] as int
      ..roommateSmoke = fields[9] as int;
  }

  @override
  void write(BinaryWriter writer, Preference obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.personality)
      ..writeByte(1)
      ..write(obj.guestsOver)
      ..writeByte(2)
      ..write(obj.loudNoise)
      ..writeByte(3)
      ..write(obj.cleanliness)
      ..writeByte(4)
      ..write(obj.smoke)
      ..writeByte(5)
      ..write(obj.guestsFeeling)
      ..writeByte(6)
      ..write(obj.sociality)
      ..writeByte(7)
      ..write(obj.loudTv)
      ..writeByte(8)
      ..write(obj.contributeCleaning)
      ..writeByte(9)
      ..write(obj.roommateSmoke);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
