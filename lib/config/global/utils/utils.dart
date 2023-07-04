import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rj_downloader/config/global/constants/app_constants.dart';
import 'package:rj_downloader/data/models/media.dart';

class Utils {

  static scanNewMedia() async {
    await Permission.storage.request().isGranted;
    OnAudioQuery audioQuery = OnAudioQuery();
    audioQuery.scanMedia(AppConstants.appDownloadedMediaPath);
  }

  static Future<
      bool> checkIfFileExistsAlready(Media music, String mediaType) => File(
          '${AppConstants.appDownloadedMediaPath}/${getDirectoryNameByMediaFormat(mediaType)}/${music.artist} - ${music.song}$mediaType')
      .exists();

  static Future<void> createDirectory(String dirName) async {
    if (!await Directory(AppConstants.appDownloadedMediaPath).exists()) {
      await Directory(AppConstants.appDownloadedMediaPath).create();
    }

    if (!await Directory('${AppConstants.appDownloadedMediaPath}/$dirName').exists()) {
      await Directory('${AppConstants.appDownloadedMediaPath}/$dirName').create();
    }
  }

  static String getDirectoryNameByMediaFormat(String mediaFormat) =>
      mediaFormat == '.mp4' ? 'video' : 'audio';

  static Future<bool> requestMainPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    if (statuses[Permission.storage]!.isDenied || statuses[Permission.manageExternalStorage]!.isDenied) {
      return false;
    }
    return true;
  }

  static Future<bool> requestPlayingMediaPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.audio,
      Permission.videos,
    ].request();

    if (statuses[Permission.audio]!.isDenied || statuses[Permission.videos]!.isDenied) {
      return false;
    }
    return true;
  }

  static bool isAudioInCache(int mediaId) {
    return File('${AppConstants.appTempDir}/cached-$mediaId.mp3').existsSync();
  }

  static bool isMediaPlaying(AudioPlayer audioPlayer) => audioPlayer.playing;

}
