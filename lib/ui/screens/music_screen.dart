import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_file/open_file.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';
import 'package:rj_downloader/config/services/remote/api_service.dart';
import 'package:rj_downloader/data/models/media.dart';
import 'package:rj_downloader/data/providers/music_state_provider.dart';

class MusicScreen extends StatefulWidget {
  Media media;
  Function() onDownloadComplete;

  MusicScreen({Key? key, required this.media, required this.onDownloadComplete})
      : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
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
            title: const Text(
              'Download Media',
              style: TextStyle(fontFamily: 'pb', fontSize: 18),
            ),
            backgroundColor: Utils.primaryColor,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(widget.media.photo),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
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
                const SizedBox(
                  height: 24,
                ),
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: MediaQuery.of(context).size.width * .5,
                    height: 150,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: double.infinity,
                        ),
                        ChangeNotifierProvider(
                          create: (context) => MusicStateProvider(),
                          builder: (context, child) =>
                              Consumer<MusicStateProvider>(
                            builder: (context, value, child) => OptionGenerator(
                              musicState: value,
                              media: widget.media,
                              mediaType: '.mp3',
                              onDownloadComplete: widget.onDownloadComplete,
                            ),
                          ),
                        ),
                        if (widget.media.videoFormat != null) ...{
                          const SizedBox(
                            height: 20,
                          ),
                        },
                        if (widget.media.videoLink != null) ...{
                          ChangeNotifierProvider(
                            create: (context) => MusicStateProvider(),
                            builder: (context, child) =>
                                Consumer<MusicStateProvider>(
                              builder: (context, value, child) =>
                                  OptionGenerator(
                                musicState: value,
                                media: widget.media,
                                mediaType: '.mp4',
                                onDownloadComplete: widget.onDownloadComplete,
                              ),
                            ),
                          ),
                        },
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

class OptionGenerator extends StatefulWidget {
  Media media;
  MusicStateProvider musicState;
  String mediaType;
  Function() onDownloadComplete;

  OptionGenerator(
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
        if (widget.musicState.isDownloaded) ...{
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
  DownloadProgressBar({
    super.key,
    required this.widget,
    required this.cancelToken,
  });

  OptionGenerator widget;
  CancelToken cancelToken;

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
        style: TextStyle(fontSize: 11, fontFamily: 'pb'),
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
  Media media;
  String mediaType;

  PlayButton({Key? key, required this.media, required this.mediaType})
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
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(14)),
        child: Center(
          child: Row(
            children: [
              Icon(mediaType == '.mp4' ? Iconsax.video : Iconsax.music,
                  color: Colors.white, size: 20),
              const SizedBox(
                width: 8,
              ),
              Text(
                'Play ${Utils.getDirectoryNameByMediaFormat(mediaType).capitalizeFirst}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DownloadButton extends StatelessWidget {
  Media media;
  MusicStateProvider provider;
  String mediaType;
  CancelToken cancelToken;
  Function() onDownloadComplete;

  DownloadButton(
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
            provider.isDownloaded = true;
            provider.isDownloading = false;
          }
        }, mediaType, cancelToken);
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(14)),
        child: Center(
          child: Row(
            children: [
              const Icon(Iconsax.document_download,
                  color: Colors.white, size: 20),
              const SizedBox(
                width: 8,
              ),
              Text(
                'Download ${Utils.getDirectoryNameByMediaFormat(mediaType).capitalizeFirst}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
