class Media {
  String audioLink;
  String? videoLink;
  String artist;
  String song;
  String photo;
  double duration;

  Media({
    required this.audioLink,
    this.videoLink,
    required this.artist,
    required this.song,
    required this.photo,
    required this.duration,
  });
}
