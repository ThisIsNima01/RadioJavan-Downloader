import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';
import 'package:rj_downloader/data/models/media.dart';

import '../config/global/constants/app_constants.dart';

class AudioPlayerControl extends StatefulWidget {
  const AudioPlayerControl(
      {Key? key,
      required this.audioPlayer,
      required this.isDownloaded,
      required this.media})
      : super(key: key);

  final AudioPlayer audioPlayer;
  final bool isDownloaded;
  final Media media;

  @override
  State<AudioPlayerControl> createState() => _AudioPlayerControlState();
}

class _AudioPlayerControlState extends State<AudioPlayerControl> {
  bool? isAudioInCache;

  @override
  void initState() {
    isAudioInCache = Utils.isAudioInCache(widget.media.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 66,
      child: StreamBuilder<PlayerState>(
        stream: widget.audioPlayer.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final processingState = playerState?.processingState;
          final playing = playerState?.playing;

          if ((processingState == ProcessingState.buffering ||
                  processingState == ProcessingState.loading) &&
              (!isAudioInCache! && !widget.isDownloaded)) {
            return SizedBox(
              height: 42,
              width: 42,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppConstants.primaryColor,
                ),
              ),
            );
          }
          if (!(playing ?? false)) {
            return IconButton(
              onPressed: () async {
                widget.audioPlayer.play();
              },
              iconSize: 50,
              color: AppConstants.primaryColor,
              icon: const Icon(Iconsax.play),
            );
          } else if (processingState != ProcessingState.completed) {
            return IconButton(
              onPressed: widget.audioPlayer.pause,
              iconSize: 50,
              color: AppConstants.primaryColor,
              icon: const Icon(Iconsax.pause),
            );
          }
          return IconButton(
            onPressed: widget.audioPlayer.load,
            iconSize: 50,
            color: AppConstants.primaryColor,
            icon: const Icon(Iconsax.play),
          );
        },
      ),
    );
  }
}
