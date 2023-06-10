import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_cache/just_audio_cache.dart';
import 'package:provider/provider.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';
import 'package:rj_downloader/data/models/media.dart';
import 'package:rj_downloader/data/providers/music_state_provider.dart';
import 'package:rj_downloader/ui/audio_player_control.dart';
import 'package:rxdart/streams.dart';

import '../../data/models/position.dart';
import '../widgets/option_generator.dart';

class MusicScreen extends StatefulWidget {
  final Media media;
  final Function() onDownloadComplete;
  final AudioPlayer audioPlayer;

  const MusicScreen(
      {Key? key,
      required this.media,
      required this.onDownloadComplete,
      required this.audioPlayer})
      : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  AudioPlayer _audioPlayer = AudioPlayer();
  bool isDownloaded = false;
  bool isSame = false;

  Stream<PositionData> get _positionDataStream => CombineLatestStream.combine3(
      widget.audioPlayer.positionStream,
      widget.audioPlayer.bufferedPositionStream,
      widget.audioPlayer.durationStream,
      (a, b, c) => PositionData(a, b, c ?? Duration.zero));

  @override
  void initState() {
    FToast fToast = FToast();
    fToast.init(context);
    _audioPlayer = widget.audioPlayer;
    ProgressiveAudioSource? audioSource;
    if (_audioPlayer.audioSource != null) {
      audioSource = _audioPlayer.audioSource as ProgressiveAudioSource;
      isSame = audioSource.duration?.inSeconds.toString() ==
          widget.media.duration.toString().substring(0, 3);
    }

    Utils.checkIfFileExistsAlready(widget.media, '.mp3').then((result) {
      setState(() {
        if (result) {
          isDownloaded = true;

          if (isSame) {
            return;
          }
          _audioPlayer.setFilePath(
              '/storage/emulated/0/Music/rj/audio/${widget.media.artist} - ${widget.media.song}.mp3');
        } else {
          if (isSame) {
            return;
          }
          _audioPlayer.dynamicSet(
              url: widget.media.audioLink, pushIfNotExisted: true);
        }
      });
    });

    Utils.isAudioInCache(widget.audioPlayer, widget.media.audioLink).then(
        (value) => {Utils.showPlayingStateToast(isDownloaded, value, fToast)});

    if (!Utils.isMediaPlaying(_audioPlayer)) {
      _audioPlayer.play();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(widget.media.photo),
          fit: BoxFit.fill,
          // repeat: ImageRepeat.repeatY,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Iconsax.arrow_left, size: 30)),
            title: const Text(
              'Download Media',
              style: TextStyle(fontFamily: 'pb', fontSize: 18),
            ),
            backgroundColor: Utils.primaryColor,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            height: 280,
                            width: 280,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                    widget.media.photo),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          widget.media.song,
                          maxLines: 1,
                          style: const TextStyle(
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 12),
                              ],
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'pb',
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        widget.media.artist,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 12),
                            ],
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: 'pm',
                            color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: double.infinity,
                        ),
                        StreamBuilder<PositionData>(
                          stream: _positionDataStream,
                          builder: (context, snapshot) {
                            final positionData = snapshot.data;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ProgressBar(
                                barHeight: 6,
                                baseBarColor:
                                    Utils.primaryColor.withOpacity(0.3),
                                bufferedBarColor: isDownloaded
                                    ? Colors.transparent
                                    : Colors.black.withOpacity(0.3),
                                progressBarColor: Utils.primaryColor,
                                thumbColor: Utils.primaryColor,
                                progress:
                                    positionData?.position ?? Duration.zero,
                                total: positionData?.duration ?? Duration.zero,
                                buffered: positionData?.bufferedPosition ??
                                    Duration.zero,
                                onSeek: _audioPlayer.seek,
                              ),
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              child: ChangeNotifierProvider(
                                create: (context) => MusicStateProvider(),
                                builder: (context, child) =>
                                    Consumer<MusicStateProvider>(
                                  builder: (context, value, child) =>
                                      OptionGenerator(
                                    musicState: value,
                                    media: widget.media,
                                    mediaType: '.mp3',
                                    onDownloadComplete:
                                        widget.onDownloadComplete,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            AudioPlayerControl(
                              audioPlayer: _audioPlayer,
                              isDownloaded: isDownloaded,
                              media: widget.media,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            if (widget.media.videoLink == null) ...{
                              const SizedBox(width: 60)
                            },
                            if (widget.media.videoLink != null) ...{
                              SizedBox(
                                width: 60,
                                child: ChangeNotifierProvider(
                                  create: (context) => MusicStateProvider(),
                                  builder: (context, child) =>
                                      Consumer<MusicStateProvider>(
                                    builder: (context, value, child) =>
                                        OptionGenerator(
                                      musicState: value,
                                      media: widget.media,
                                      mediaType: '.mp4',
                                      onDownloadComplete:
                                          widget.onDownloadComplete,
                                    ),
                                  ),
                                ),
                              )
                            },
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
