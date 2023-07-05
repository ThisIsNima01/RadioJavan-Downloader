import 'package:hive/hive.dart';

part 'media.g.dart';

@HiveType(typeId: 0)
class Media extends HiveObject{
  @HiveField(0)
  int id;
  @HiveField(1)
  String audioLink;
  @HiveField(2)
  String? videoLink;
  @HiveField(3)
  String artist;
  @HiveField(4)
  String song;
  @HiveField(5)
  String photo;
  @HiveField(6)
  double duration;

  Media({
    required this.audioLink,
    this.videoLink,
    required this.artist,
    required this.song,
    required this.photo,
    required this.duration,
    required this.id,
  });
}
