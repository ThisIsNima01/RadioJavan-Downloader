import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../config/global/constants/app_constants.dart';
import '../../config/global/utils/utils.dart';
import 'option_generator.dart';

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
      backgroundColor: AppConstants.primaryColor.withOpacity(0.3),
      percent: widget.widget.musicState.progressPercent,
      progressColor: AppConstants.primaryColor,
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