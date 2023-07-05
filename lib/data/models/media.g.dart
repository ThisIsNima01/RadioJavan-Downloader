// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaAdapter extends TypeAdapter<Media> {
  @override
  final int typeId = 0;

  @override
  Media read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Media(
      audioLink: fields[1] as String,
      videoLink: fields[2] as String?,
      artist: fields[3] as String,
      song: fields[4] as String,
      photo: fields[5] as String,
      duration: fields[6] as double,
      id: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Media obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.audioLink)
      ..writeByte(2)
      ..write(obj.videoLink)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.song)
      ..writeByte(5)
      ..write(obj.photo)
      ..writeByte(6)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
