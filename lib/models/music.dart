class Music {
  String? link;
  String? photo;
  String? thumbnail;
  String? artist;
  String? song;
  String? type;
  String? hqLink;
  String? hdLink;

  Music(
      this.link, this.photo, this.thumbnail, this.artist, this.song, this.type,this.hqLink,this.hdLink);

  factory Music.fromJson(Map<String, dynamic> jsonMapObject) {
    return Music(
      jsonMapObject['link'],
      jsonMapObject['photo'],
      jsonMapObject['thumbnail'],
      jsonMapObject['artist'],
      jsonMapObject['song'],
      jsonMapObject['type'],
      jsonMapObject['hq_link'],
      jsonMapObject['hd_link'],
    );
  }
}
