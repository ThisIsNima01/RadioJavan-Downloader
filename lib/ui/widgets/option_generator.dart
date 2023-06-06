import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rj_downloader/ui/widgets/play_button.dart';

import '../../config/global/utils/utils.dart';
import '../../data/models/media.dart';
import '../../data/providers/music_state_provider.dart';
import 'download_button.dart';
import 'download_progress_bar.dart';

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