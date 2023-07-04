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
            // FToast fToast = FToast();
            // fToast.init(context);
            //
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
