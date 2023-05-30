import 'package:dio/dio.dart';
import 'package:rj_downloader/config/global/constants/api_constants.dart';
import 'package:rj_downloader/models/music.dart';

class ApiService {
  static Dio dio = Dio(BaseOptions(baseUrl: ApiConstants.apiUrl));

  Future<List<Music>> getMusicFromServer(String musicName) async {
    try {
      var response = await dio.get('q=$musicName');

      List<Music> musicList = response.data['result']['top']
          .map<Music>(
            (jsonMapObject) => Music.fromJson(jsonMapObject),
          )
          .toList();

      return musicList;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
