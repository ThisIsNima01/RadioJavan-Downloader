import 'package:flutter/cupertino.dart';

import '../models/media.dart';

class MusicListProvider extends ChangeNotifier {
  List _musicList = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List get musicList => _musicList;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
  }

  set musicList(List musicList) {
    _musicList = musicList
        .where((element) => element.type == 'mp3' || element.type == 'video')
        .toList();

    List<Media> mediaList = [];

    if (_musicList.isNotEmpty) {
      for (var music in _musicList) {
        if (mediaList
            .where((element) =>
                element.artist == music.artist && element.song == music.song)
            .toList()
            .isEmpty) {
          if (music.type != 'video') {
            mediaList.add(
              Media(
                  artist: music.artist,
                  song: music.song,
                  photo: music.photo,
                  audioLink: music.link,
                  duration: music.duration,
                  id: music.id),
            );
          }
        } else {
          if (music.type == 'video') {
            int itemIndex = mediaList.indexWhere((item) =>
                item.artist == music.artist && item.song == music.song);
            mediaList[itemIndex].videoLink = music.link;
          }
        }
      }
    }

    _musicList = mediaList;

    notifyListeners();
  }
}
