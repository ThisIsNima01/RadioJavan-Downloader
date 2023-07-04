import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rj_downloader/config/global/constants/app_constants.dart';
import 'package:rj_downloader/config/services/local/audio_player_config.dart';
import 'package:rj_downloader/ui/screens/splash_screen.dart';
import 'package:skeletons/skeletons.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    preloadArtwork: true,
  );
  await AudioPlayerConfig.initSharedPrefs();

  Directory tempDir = await getTemporaryDirectory();
  AppConstants.appTempDir = tempDir.path;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const SkeletonTheme(
      shimmerGradient: LinearGradient(
        colors: [
          Color(0xffb3d3ff),
          Color(0xffd9e9ff),
          Color(0xffb3d3ff),
        ],
      ),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
