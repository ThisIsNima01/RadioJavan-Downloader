class Music {
  dynamic link;
  dynamic photo;
  dynamic artist;
  dynamic song;
  dynamic type;
  dynamic duration;

  Music(
      this.link, this.photo,this.artist, this.song, this.type,this.duration);

  factory Music.fromJson(Map<String, dynamic> jsonMapObject) {
    return Music(
      jsonMapObject['link'],
      jsonMapObject['photo'],
      jsonMapObject['artist'],
      jsonMapObject['song'],
      jsonMapObject['type'],
      jsonMapObject['duration'],
    );
  }
}
