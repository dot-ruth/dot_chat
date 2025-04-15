// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interests_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InterestsModelAdapter extends TypeAdapter<InterestsModel> {
  @override
  final int typeId = 2;

  @override
  InterestsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterestsModel()..interests = (fields[0] as List).cast<dynamic>();
  }

  @override
  void write(BinaryWriter writer, InterestsModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.interests);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterestsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
