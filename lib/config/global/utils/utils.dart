import 'dart:io';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rj_downloader/media.dart';

import '../../../models/music.dart';
import '../../services/remote/api_service.dart';

class Utils {
  static scanNewMedia() async {
    await Permission.storage.request().isGranted;
    OnAudioQuery audioQuery = OnAudioQuery();
    audioQuery.scanMedia('/storage/emulated/0/Music/rj');
    // File file = File('/storage/emulated/0/Download/test.mp3');
    // try {
    //   if (file.existsSync()) {
    //     audioQuery
    //         .scanMedia('/storage/emulated/0/Download'); // Scan the media 'path'
    //   }
    // } catch (e) {
    //   debugPrint('$e');
    // }
  }

  static Future<bool> checkIfFileExistsAlready(Media music, String mediaType) async {
    return File(
            '/storage/emulated/0/Music/rj/${music.artist} - ${music.song}$mediaType')
        .exists();
  }

  static downloadMusic(
      Media media, Function(int count, int total) onReceiveProgress, String mediaType) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    // String downloadLink = getMediaFormat(music) == 'video' ? music.hqLink! : music.link!;
    // print(downloadLink);
    await ApiService.dio.download(
      mediaType == '.mp4' ? media.videoLink! : media.audioLink!,
      '/storage/emulated/0/Music/rj/${media.artist} - ${media.song}$mediaType',
      onReceiveProgress: (count, total) {
        onReceiveProgress(count, total);
      },
    );

    scanNewMedia();
  }

  // static String getMediaFormat(Media media) =>
  //     music.type == 'video' ? '.m3u' : '.mp3';

  static requestStoragePermission() async {
    var status = await Permission.storage.request();

    if (status.isGranted) {
      // Permission granted, you can proceed with file operations
    } else if (status.isDenied) {
      // Permission denied
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      openAppSettings();
    }
  }
}
