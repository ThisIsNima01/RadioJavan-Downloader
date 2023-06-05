import 'dart:io';
import 'dart:ui';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_cache/just_audio_cache.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rj_downloader/data/models/media.dart';


class Utils {
  static Color primaryColor = const Color(0xffE21221);

  static scanNewMedia() async {
    await Permission.storage.request().isGranted;
    OnAudioQuery audioQuery = OnAudioQuery();
    audioQuery.scanMedia('/storage/emulated/0/Music/rj');
  }

  static Future<bool> checkIfFileExistsAlready(
      Media music, String mediaType) async {
    return File(
            '/storage/emulated/0/Music/rj/${getDirectoryNameByMediaFormat(mediaType)}/${music.artist} - ${music.song}$mediaType')
        .exists();
  }

  static Future<void> createDirectory(String dirName) async {
    if (!await Directory('/storage/emulated/0/Music/rj').exists()) {
      await Directory('/storage/emulated/0/Music/rj').create();
    }

    if (!await Directory('/storage/emulated/0/Music/rj/$dirName').exists()) {
      await Directory('/storage/emulated/0/Music/rj/$dirName').create();
    }
  }

  static String getDirectoryNameByMediaFormat(String mediaFormat) =>
      mediaFormat == '.mp4' ? 'video' : 'audio';

  static Future<bool> requestMainPermissions() async {
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

  static Future<bool> handlePlayingMediaPermissions() async =>
      await Permission.audio.request().isGranted &&
      await Permission.videos.request().isGranted;

  static Future<bool> isAudioInCache(AudioPlayer audioPlayer, String url) async => await audioPlayer.existedInLocal(url: url);

  static String currentAudioSourceUri = '';
}
