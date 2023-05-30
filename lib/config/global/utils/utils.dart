import 'dart:io';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

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

  static Future<bool> checkIfFileExistsAlready(Music music) async {
    return File(
            '/storage/emulated/0/Music/rj/${music.artist} - ${music.song}${getMediaFormat(music)}')
        .exists();
  }

  static downloadMusic(
      Music music, Function(int count, int total) onReceiveProgress) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    await ApiService.dio.download(
      getMediaFormat(music) == 'video' ? music.hqLink! : music.link!,
      '/storage/emulated/0/Music/rj/${music.artist} - ${music.song}${getMediaFormat(music)}',
      onReceiveProgress: (count, total) {
        onReceiveProgress(count, total);
      },
    );

    scanNewMedia();
  }

  static String getMediaFormat(Music music) =>
      music.type == 'video' ? '.mp4' : '.mp3';

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
