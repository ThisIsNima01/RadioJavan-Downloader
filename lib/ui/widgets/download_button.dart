import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/services/remote/api_service.dart';
import '../../data/models/media.dart';
import '../../data/providers/music_state_provider.dart';
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
