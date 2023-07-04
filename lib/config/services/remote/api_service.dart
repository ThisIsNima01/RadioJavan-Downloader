import 'package:dio/dio.dart';
import 'package:rj_downloader/config/global/constants/api_constants.dart';
import 'package:rj_downloader/config/global/constants/app_constants.dart';
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
      String mediaFormat,
      CancelToken cancelToken) async {
    if (mediaFormat == '.mp4') {
      await Utils.requestMainPermissions();
    }

    await Utils.createDirectory(
        Utils.getDirectoryNameByMediaFormat(mediaFormat));

    await dio.download(
      mediaFormat == '.mp4' ? media.videoLink! : media.audioLink,
      '${AppConstants.appDownloadedMediaPath}/${Utils.getDirectoryNameByMediaFormat(mediaFormat)}/${media.artist} - ${media.song}$mediaFormat',
      onReceiveProgress: (count, total) {
        onReceiveProgress(count, total);
      },
      cancelToken: cancelToken,
      deleteOnError: true,
    );

    Utils.scanNewMedia();
  }
}
