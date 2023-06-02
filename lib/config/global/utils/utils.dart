import 'dart:io';

import 'package:dio/dio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rj_downloader/media.dart';

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
            '/storage/emulated/0/Music/rj/${getDirectoryNameByMediaFormat(mediaType)}/${music.artist} - ${music.song}$mediaType')
        .exists();
  }

  static downloadMusic(
      Media media, Function(int count, int total) onReceiveProgress, String mediaType, CancelToken cancelToken) async {
    // var status = await Permission.storage.status;
    //
    // if (!status.isGranted) {
    //   await Permission.storage.request();
    // }

    await _requestPermission();

    // if (!await isDirectoryCreated(getDirectoryNameByMediaFormat(mediaType))){
    //   await createDirectory(getDirectoryNameByMediaFormat(mediaType));
    // }
    
    await createDirectory(getDirectoryNameByMediaFormat(mediaType));

    await ApiService.dio.download(
      mediaType == '.mp4' ? media.videoLink! : media.audioLink!,
      '/storage/emulated/0/Music/rj/${getDirectoryNameByMediaFormat(mediaType)}/${media.artist} - ${media.song}$mediaType',
      onReceiveProgress: (count, total) {
        onReceiveProgress(count, total);
      },cancelToken: cancelToken,deleteOnError: true,
    );

    scanNewMedia();
  }

  // static String getMediaFormat(Media media) =>
  //     music.type == 'video' ? '.m3u' : '.mp3';

  // static requestStoragePermission() async {
  //   var status = await Permission.storage.request();
  //
  //   if (status.isGranted) {
  //     // Permission granted, you can proceed with file operations
  //   } else if (status.isDenied) {
  //     // Permission denied
  //   } else if (status.isPermanentlyDenied) {
  //     // Permission permanently denied, open app settings
  //     openAppSettings();
  //   }
  // }

 // static Future<bool> isDirectoryCreated(String dirName) async{
 //   return await Directory('/storage/emulated/0/Music/rj/$dirName').exists();
 //  }

  static Future<void> createDirectory(String dirName) async{

    if (!await Directory('/storage/emulated/0/Music/rj').exists()) {
      await Directory('/storage/emulated/0/Music/rj').create();
    }


    if (!await Directory('/storage/emulated/0/Music/rj/$dirName').exists()) {
     await Directory('/storage/emulated/0/Music/rj/$dirName').create();
    }


  }

  static String getDirectoryNameByMediaFormat(String mediaFormat) => mediaFormat == '.mp4' ? 'video' : 'audio';

  static Future<bool> _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
      Permission.storage,
    ].request();

    if (statuses[Permission.manageExternalStorage]!.isDenied ||
        statuses[Permission.storage]!.isDenied) {
      return false;
    }
    return true;
  }

  static Future<bool> handlePlayingMediaPermissions() async => await Permission.audio.request().isGranted && await Permission.videos.request().isGranted;
}
