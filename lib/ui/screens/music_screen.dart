import 'dart:io';
import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_cache/just_audio_cache.dart';
import 'package:provider/provider.dart';
import 'package:rj_downloader/config/global/constants/app_constants.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';
import 'package:rj_downloader/config/services/local/audio_player_config.dart';
import 'package:rj_downloader/data/models/media.dart';
import 'package:rj_downloader/data/providers/music_state_provider.dart';
import 'package:rj_downloader/ui/audio_player_control.dart';
import 'package:rxdart/streams.dart';
import 'package:skeletons/skeletons.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/position.dart';
import '../widgets/option_generator.dart';

class MusicScreen extends StatefulWidget {
  final Media media;
  final Function() onDownloadComplete;
  final AudioPlayer audioPlayer;
  final bool isAudioDownloaded;
  final bool isVideoDownloaded;

  const MusicScreen({
    Key? key,
    required this.media,
    required this.onDownloadComplete,
    required this.audioPlayer,
    required this.isAudioDownloaded,
    required this.isVideoDownloaded,
  }) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  AudioPlayer _audioPlayer = AudioPlayer();
  bool isDownloaded = false;
  bool isSame = false;
  bool isInCache = false;
  Directory? tempDir;
  FToast fToast = FToast();
  bool isLooping = AudioPlayerConfig.getIsLoop() ?? false;
  bool isVideoPlaying = false;

  Stream<PositionData> get _positionDataStream => CombineLatestStream.combine3(
      widget.audioPlayer.positionStream,
      widget.audioPlayer.bufferedPositionStream,
      widget.audioPlayer.durationStream,
      (a, b, c) => PositionData(a, b, c ?? Duration.zero));

  @override
  void initState() {
    fToast.init(context);
    _audioPlayer = widget.audioPlayer;
    ProgressiveAudioSource? audioSource;

    isInCache = Utils.isAudioInCache(widget.media.id);

    if (!isInCache) {
      widget.audioPlayer.cacheFile(
          url: widget.media.audioLink,
          path: '${AppConstants.appTempDir}/cached-${widget.media.id}.mp3');
    }

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
          Utils.requestPlayingMediaPermissions();

          _audioPlayer.setAudioSource(
            AudioSource.file(
              '/storage/emulated/0/Music/rj/audio/${widget.media.artist} - ${widget.media.song}.mp3',
              tag: MediaItem(
                id: widget.media.id.toString(),
                album: widget.media.artist,
                title: widget.media.song,
                artUri: Uri.parse(widget.media.photo),
                artist: widget.media.artist,
              ),
            ),
          );
        } else {
          if (isSame) {
            return;
          }
          if (isInCache) {
            _audioPlayer.setAudioSource(
              AudioSource.file(
                '${AppConstants.appTempDir}/cached-${widget.media.id}.mp3',
                tag: MediaItem(
                  id: widget.media.id.toString(),
                  album: widget.media.artist,
                  title: widget.media.song,
                  artUri: Uri.parse(widget.media.photo),
                  artist: widget.media.artist,
                ),
              ),
            );
            return;
          }

          _audioPlayer.setAudioSource(
            AudioSource.uri(
              Uri.parse(widget.media.audioLink),
              tag: MediaItem(
                id: widget.media.id.toString(),
                album: widget.media.artist,
                title: widget.media.song,
                artUri: Uri.parse(widget.media.photo),
              ),
            ),
          );
        }
      });
    });

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
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            actions: [
              if (widget.media.videoLink != null &&
                  !widget.isVideoDownloaded) ...{
                IconButton(
                  onPressed: () {
                    setState(() {
                      isVideoPlaying = !isVideoPlaying;
                      if (!isVideoPlaying) {
                        widget.audioPlayer.play();
                      }
                    });
                  },
                  icon: const Icon(Iconsax.video),
                ),
              },
              IconButton(
                onPressed: () async {
                  await AudioPlayerConfig.setIsLoop(!isLooping);
                  setState(() {
                    _audioPlayer.setLoopMode(AudioPlayerConfig.getIsLoop()!
                        ? LoopMode.all
                        : LoopMode.off);
                    isLooping = AudioPlayerConfig.getIsLoop()!;
                  });

                  fToast.showToast(
                    toastDuration: const Duration(seconds: 3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Loop Mode ${isLooping ? 'Enabled' : 'Disabled'}',
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'pm'),
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Iconsax.repeat,
                  color: isLooping ? Colors.amberAccent : null,
                ),
              ),
            ],
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Iconsax.arrow_left, size: 30)),
            title: const Text(
              'Download Media',
              style: TextStyle(fontFamily: 'pb', fontSize: 18),
            ),
            backgroundColor: AppConstants.primaryColor,
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
                          child: isVideoPlaying
                              ? VidePlayer(url: widget.media.videoLink ?? '')
                              : Container(
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
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              widget.media.song,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'pb',
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              widget.media.artist,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: 'pm',
                                  color: Colors.black54),
                            ),
                          ],
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
                                    AppConstants.primaryColor.withOpacity(0.3),
                                bufferedBarColor: isDownloaded
                                    ? Colors.transparent
                                    : Colors.black.withOpacity(0.3),
                                progressBarColor: AppConstants.primaryColor,
                                thumbColor: AppConstants.primaryColor,
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

class VidePlayer extends StatefulWidget {
  final String url;

  const VidePlayer({super.key, required this.url});

  @override
  State<VidePlayer> createState() => _VidePlayerState();
}

class _VidePlayerState extends State<VidePlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _chewieController = ChewieController(
        autoInitialize: true,
        autoPlay: true,
        allowMuting: true,
        allowedScreenSleep: false,
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 16 / 9);

    _videoPlayerController!.addListener(() {
      if (_videoPlayerController!.value.isInitialized && !isPlaying) {
        setState(() {
          isPlaying = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    _chewieController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: isPlaying
          ? Chewie(
              controller: _chewieController!,
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                    borderRadius: BorderRadius.circular(20),

                  ),
                ),
                const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
    );
  }
}
