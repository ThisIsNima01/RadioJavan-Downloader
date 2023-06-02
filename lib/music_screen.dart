import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_file/open_file.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';
import 'package:rj_downloader/download_notification.dart';
import 'package:rj_downloader/media.dart';
import 'package:rj_downloader/music_state_provider.dart';

class MusicScreen extends StatefulWidget {
  Media media;
  Function() onDownloadComplete;

  MusicScreen({Key? key, required this.media, required this.onDownloadComplete})
      : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  Color primaryColor = Color(0xffE21221);

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
            backgroundColor: primaryColor,
          ),
          body: Column(
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
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                widget.media.artist,
                maxLines: 1,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white60),
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  ChangeNotifierProvider(
                    create: (context) => MusicStateProvider(),
                    builder: (context, child) => Consumer<MusicStateProvider>(
                      builder: (context, value, child) => OptionGenerator(
                        musicState: value,
                        media: widget.media,
                        mediaType: '.mp3',
                        onDownloadComplete: widget.onDownloadComplete,
                      ),
                    ),
                  ),
                  if (widget.media.videoLink != null) ...{
                    ChangeNotifierProvider(
                      create: (context) => MusicStateProvider(),
                      builder: (context, child) => Consumer<MusicStateProvider>(
                        builder: (context, value, child) => OptionGenerator(
                          musicState: value,
                          media: widget.media,
                          mediaType: '.mp4',
                          onDownloadComplete: widget.onDownloadComplete,
                        ),
                      ),
                    ),
                  },
                ],
              )
            ],
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
    // print('${widget.media.song} ${widget.media.artist} ${widget.music.type}');

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
    return Container(
      margin: const EdgeInsets.only(left: 40),
      child: CircularPercentIndicator(
        radius: 26,
        lineWidth: 4,
        progressColor: Colors.red,
        backgroundColor: Colors.red.withOpacity(0.3),
        percent: widget.widget.musicState.progressPercent,
        center: Text(
          '${widget.widget.musicState.progressText}%',
          style: const TextStyle(color: Colors.white),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(left: 20),
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

        await Utils.downloadMusic(media, (count, total) {
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(left: 20),
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
