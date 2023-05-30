import 'package:flutter/cupertino.dart';

import 'models/music.dart';

class MusicListProvider extends ChangeNotifier {
  List<Music> _musicList = [];

  List<Music> get musicList => _musicList;

  set musicList(List<Music> musicList){
    _musicList = musicList.where((element) => element.type == 'mp3' || element.type == 'video').toList();
    notifyListeners();
  }
}