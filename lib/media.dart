class Media {
  String? audioLink;
  String? videoLink;
  String? audioFormat;
  String? videoFormat;
  String artist;
  String song;
  String photo;

  Media(
      {this.audioLink,
      this.videoLink,
      required this.artist,
      required this.song,
      required this.photo,
      this.audioFormat,
      this.videoFormat});
}
