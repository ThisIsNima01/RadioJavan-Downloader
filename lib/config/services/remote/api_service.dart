import 'package:dio/dio.dart';
import 'package:rj_downloader/config/global/constants/api_constants.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';
import 'package:rj_downloader/data/models/music.dart';

import '../../../data/models/media.dart';

class ApiService {
  static Dio dio = Dio(BaseOptions(baseUrl: ApiConstants.apiUrl));

  static Future<List<Music>> getMusicFromServer(String musicName) async {
    try {
      var response = await dio.get('q=$musicName');

      List<Music> musicList = response.data['result']['top']
          .map<Music>(
            (jsonMapObject) => Music.fromJson(jsonMapObject),
          )
          .toList();

      return musicList;
    } catch (e) {
      return [];
    }
  }

  static Future<void> downloadMedia(
      Media media,
      Function(int count, int total) onReceiveProgress,
      String mediaType,
      CancelToken cancelToken) async {
    await Utils.requestMainPermissions();

    await Utils.createDirectory(Utils.getDirectoryNameByMediaFormat(mediaType));

    await ApiService.dio.download(
      mediaType == '.mp4' ? media.videoLink! : media.audioLink,
      '/storage/emulated/0/Music/rj/${Utils.getDirectoryNameByMediaFormat(mediaType)}/${media.artist} - ${media.song}$mediaType',
      onReceiveProgress: (count, total) {
        onReceiveProgress(count, total);
      },
      cancelToken: cancelToken,
      deleteOnError: true,
    );

    Utils.scanNewMedia();
  }
}
