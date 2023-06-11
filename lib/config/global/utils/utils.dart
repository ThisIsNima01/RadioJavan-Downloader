import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    audioQuery.scanMedia('/storage/emulated/0/Music/rj/audio');
  }

  static Future<
      bool> checkIfFileExistsAlready(Media music, String mediaType) => File(
          '/storage/emulated/0/Music/rj/${getDirectoryNameByMediaFormat(mediaType)}/${music.artist} - ${music.song}$mediaType')
      .exists();

  static Future<void> createDirectory(String dirName) async {
    if (!await Directory('/storage/emulated/0/Music/rj').exists()) {
      await Directory('/storage/emulated/0/Music/rj').create();
    }

    if (!await Directory('/storage/emulated/0/Music/rj/cached').exists()) {
      await Directory('/storage/emulated/0/Music/rj/cached').create();
    }

    if (!await Directory('/storage/emulated/0/Music/rj/$dirName').exists()) {
      await Directory('/storage/emulated/0/Music/rj/$dirName').create();
    }
  }

  static String getDirectoryNameByMediaFormat(String mediaFormat) =>
      mediaFormat == '.mp4' ? 'video' : 'audio';

  static Future<bool> requestMainPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    if (statuses[Permission.storage]!.isDenied) {
      return false;
    }
    return true;
  }

  static Future<bool> handlePlayingMediaPermissions() async =>
      await Permission.audio.request().isGranted &&
      await Permission.videos.request().isGranted;

  static bool isAudioInCache(int mediaId) => File('/storage/emulated/0/Music/rj/cached/cached-$mediaId.mp3').existsSync();

  static bool isMediaPlaying(AudioPlayer audioPlayer) => audioPlayer.playing;

  static showPlayingStateToast(
          bool isMediaDownloaded, bool isMediaInCache, FToast fToast) =>
      fToast.showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            !isMediaDownloaded && !isMediaInCache
                ? 'Now Streaming Online'
                : 'Now Playing Offline',
            style: const TextStyle(color: Colors.white, fontFamily: 'pm'),
          ),
        ),
      );
}
