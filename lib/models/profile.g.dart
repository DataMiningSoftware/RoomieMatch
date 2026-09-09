// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 2;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile()
      ..firstName = fields[0] as String
      ..lastName = fields[1] as String
      ..age = fields[2] as int
      ..birthday = fields[3] as String
      ..gender = fields[4] as String
      ..latitude = fields[5] as String
      ..longitude = fields[6] as String
      ..distance = fields[7] as int
      ..budget = fields[8] as int
      ..schoolJob = fields[9] as String
      ..description = fields[10] as String
      ..allergies = fields[11] as String;
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.firstName)
      ..writeByte(1)
      ..write(obj.lastName)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.birthday)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.distance)
      ..writeByte(8)
      ..write(obj.budget)
      ..writeByte(9)
      ..write(obj.schoolJob)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.allergies);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
