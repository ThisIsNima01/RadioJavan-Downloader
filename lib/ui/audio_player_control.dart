import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';

class AudioPlayerControl extends StatelessWidget {
   AudioPlayerControl({Key? key, required this.audioPlayer, required this.isDownloaded})
      : super(key: key);

  final AudioPlayer audioPlayer;
  bool isFirstTime = true;
  bool isDownloaded;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (!(playing ?? false)) {
          return IconButton(
            onPressed: (){
              FToast fToast = FToast();
              if (isFirstTime) {
                if (!isDownloaded){
                fToast.showToast(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Now Streaming Online',
                      style: TextStyle(color: Colors.white, fontFamily: 'pm'),
                    ),
                  ),
                );
                } else {
                  fToast.showToast(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Now Playing Offline',
                        style: TextStyle(color: Colors.white, fontFamily: 'pm'),
                      ),
                    ),
                  );
                }
                isFirstTime = false;
              }
              audioPlayer.play();
            },
            iconSize: 50,
            color: Utils.primaryColor,
            icon: const Icon(Iconsax.play),
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            onPressed: audioPlayer.pause,
            iconSize: 50,
            color: Utils.primaryColor,
            icon: const Icon(Iconsax.pause),
          );
        }
        return IconButton(
          onPressed: audioPlayer.load,
          iconSize: 50,
          color: Utils.primaryColor,
          icon: const Icon(Iconsax.play),
        );;
      },
    );
  }
}
