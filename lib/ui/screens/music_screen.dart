import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_cache/just_audio_cache.dart';
import 'package:open_file/open_file.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';
import 'package:rj_downloader/config/services/remote/api_service.dart';
import 'package:rj_downloader/data/models/media.dart';
import 'package:rj_downloader/data/providers/music_state_provider.dart';
import 'package:rj_downloader/ui/audio_player_control.dart';
import 'package:rxdart/streams.dart';

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
  // final AudioPlayer _audioPlayer = AudioPlayer();
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
          setState(() {
            isDownloaded = true;
          });

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
                        )),
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

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  const PositionData(this.position, this.bufferedPosition, this.duration);
}

class OptionGenerator extends StatefulWidget {
  final Media media;
  final MusicStateProvider musicState;
  final String mediaType;
  final Function() onDownloadComplete;

  const OptionGenerator(
      {Key? key,
      required this.media,
      required this.musicState,
      required this.mediaType,
      required this.onDownloadComplete})
      : super(key: key);

  @override
  State<OptionGenerator> createState() => _OptionGeneratorState();
}

class _OptionGeneratorState extends State<OptionGenerator> {
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    Utils.checkIfFileExistsAlready(widget.media, widget.mediaType)
        .then((result) {
      setState(() {
        if (result) {
          widget.musicState.isDownloaded = true;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.musicState.isDownloaded && widget.mediaType == '.mp4') ...{
          PlayButton(
            mediaType: widget.mediaType,
            media: widget.media,
          )
        },
        if (!widget.musicState.isDownloaded &&
            !widget.musicState.isDownloading) ...{
          DownloadButton(
              media: widget.media,
              provider: widget.musicState,
              mediaType: widget.mediaType,
              cancelToken: cancelToken,
              onDownloadComplete: widget.onDownloadComplete),
        },
        if (widget.musicState.isDownloading) ...{
          DownloadProgressBar(widget: widget, cancelToken: cancelToken),
        },
      ],
    );
  }
}

class DownloadProgressBar extends StatefulWidget {
  final OptionGenerator widget;
  final CancelToken cancelToken;
  const DownloadProgressBar({
    super.key,
    required this.widget,
    required this.cancelToken,
  });

  @override
  State<DownloadProgressBar> createState() => _DownloadProgressBarState();
}

class _DownloadProgressBarState extends State<DownloadProgressBar> {
  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 20,
      curve: Curves.easeIn,
      backgroundColor: Utils.primaryColor.withOpacity(0.3),
      percent: widget.widget.musicState.progressPercent,
      progressColor: Utils.primaryColor,
      center: Text(
        '${widget.widget.musicState.progressText}%',
        style: const TextStyle(fontSize: 11, fontFamily: 'pb'),
      ),
    );
  }

  @override
  void dispose() {
    if (!widget.widget.musicState.isDownloaded) {
      widget.cancelToken.cancel('Quited While Downloading');
    }
    super.dispose();
  }
}

class PlayButton extends StatelessWidget {
  final Media media;
  final String mediaType;

  const PlayButton({Key? key, required this.media, required this.mediaType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await Utils.handlePlayingMediaPermissions()) {
          await OpenFile.open(
              '/storage/emulated/0/Music/rj/${Utils.getDirectoryNameByMediaFormat(mediaType)}/${media.artist} - ${media.song}$mediaType');
        }
      },
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              mediaType == '.mp3' ? Iconsax.music : Iconsax.video,
              size: 32,
            ),
            const Text(
              'Play',
              style: TextStyle(
                  fontFamily: 'pb', fontSize: 12, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class DownloadButton extends StatelessWidget {
  final Media media;
  final MusicStateProvider provider;
  final String mediaType;
  final CancelToken cancelToken;
  final Function() onDownloadComplete;

  const DownloadButton(
      {Key? key,
      required this.media,
      required this.provider,
      required this.mediaType,
      required this.cancelToken,
      required this.onDownloadComplete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        provider.isDownloading = true;

        await ApiService.downloadMedia(media, (count, total) {
          provider.progressText = ((count / total) * 100).toStringAsFixed(0);
          provider.progressPercent = (count / total);

          if (count == total) {
            onDownloadComplete();
            // FToast fToast = FToast();
            // fToast.init(context);

            // fToast.showToast(
            //   toastDuration: const Duration(seconds: 3),
            //   child: Container(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //     decoration: BoxDecoration(
            //       color: Colors.green,
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: Text(
            //       '${Utils.getDirectoryNameByMediaFormat(mediaType).capitalizeFirst} Downloaded Successfully',
            //       style: const TextStyle(color: Colors.white, fontFamily: 'pm'),
            //     ),
            //   ),
            // );
            provider.isDownloaded = true;
            provider.isDownloading = false;
          }
        }, mediaType, cancelToken);
      },
      child: Column(
        children: [
          Icon(
            mediaType == '.mp3' ? Iconsax.music : Iconsax.video,
            size: 32,
          ),
          const Text(
            'Download',
            style: TextStyle(fontFamily: 'pb', fontSize: 10),
          ),
        ],
      ),
    );
  }
}
